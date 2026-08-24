import 'dart:convert';
import 'dart:io';

import 'feature_settings.dart';

class MainStationServer {
  MainStationServer._();

  static final instance = MainStationServer._();
  static const port = 8787;

  final _kdsOrders = <String, Map<String, dynamic>>{};
  final _kdsSockets = <WebSocket, String>{};
  final _cdsSockets = <WebSocket, String>{};
  Map<String, dynamic>? _cdsCart;
  HttpServer? _server;

  /// IPs of currently-connected KDS devices (live, not a saved roster).
  List<String> get connectedKdsIps => _kdsSockets.values.toList();

  /// IPs of currently-connected CDS devices (live, not a saved roster).
  List<String> get connectedCdsIps => _cdsSockets.values.toList();

  Future<void> start() async {
    if (_server != null) return;
    _server = await HttpServer.bind(
      InternetAddress.anyIPv4,
      port,
      shared: true,
    );
    _server!.listen(_handle);
  }

  Future<String> localUrl() async {
    final interfaces = await NetworkInterface.list(
      includeLoopback: false,
      type: InternetAddressType.IPv4,
    );
    final address = interfaces
        .expand((network) => network.addresses)
        .map((address) => address.address)
        .firstOrNull;
    return address == null ? 'Connect to WiFi' : 'http://$address:$port';
  }

  Future<bool> addKdsOrder(Map<String, dynamic> order) async {
    final id = (order['id'] ?? order['orderId'])?.toString().trim();
    final items = order['items'];
    if (id == null || id.isEmpty || items is! List || items.isEmpty) {
      return false;
    }

    // ponytail: in-memory station queue; persist if KDS must survive POS restarts.
    _kdsOrders[id] = order;
    _broadcast({'type': 'order', 'order': order});
    return true;
  }

  Future<bool> completeKdsOrder(String id) async {
    return completeKdsOrderByKeys([id]);
  }

  Future<bool> completeKdsOrderByKeys(Iterable<String?> ids) async {
    final keys = ids
        .map((id) => id?.trim() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();
    if (keys.isEmpty) return false;

    final storedKey = _kdsOrders.keys.firstWhere((key) {
      final order = _kdsOrders[key];
      return keys.contains(key) ||
          keys.contains(order?['id']?.toString()) ||
          keys.contains(order?['checkoutId']?.toString()) ||
          keys.contains(order?['orderId']?.toString()) ||
          keys.contains(order?['orderNumber']?.toString()) ||
          keys.contains(order?['tableId']?.toString());
    }, orElse: () => keys.first);
    final order = _kdsOrders.remove(storedKey);
    final completed = {
      ...?order,
      'id': storedKey,
      'status': 'completed',
      'completedAt': DateTime.now().toIso8601String(),
    };
    _broadcast({
      'type': 'order_completed',
      'id': storedKey,
      'keys': keys.toList(),
      'order': completed,
    });
    return true;
  }

  Future<List<String>> completeAllKdsOrders() async {
    final ids = _kdsOrders.keys.toList();
    if (ids.isEmpty) return ids;
    _kdsOrders.clear();
    _broadcast({'type': 'orders_completed', 'ids': ids});
    return ids;
  }

  /// Live-updates the customer display with the cart currently being built.
  void updateCdsCart(Map<String, dynamic> cart) {
    _cdsCart = cart;
    _broadcastToCds({'type': 'cart_updated', 'cart': cart});
  }

  /// Holds the customer display on the final receipt (amount received / change).
  void completeCdsCheckout(Map<String, dynamic> cart) {
    _cdsCart = cart;
    _broadcastToCds({'type': 'checkout_completed', 'cart': cart});
  }

  /// Sends the customer display back to its waiting state.
  void clearCdsCart() {
    _cdsCart = null;
    _broadcastToCds({'type': 'cart_cleared'});
  }

  Future<void> _handle(HttpRequest request) async {
    if (request.method == 'GET' &&
        request.uri.path == '/kds/orders/stream' &&
        WebSocketTransformer.isUpgradeRequest(request)) {
      if (!FeatureSettings.isEnabled('kitchen_printers')) {
        request.response.statusCode = HttpStatus.serviceUnavailable;
        await request.response.close();
        return;
      }
      final ip = request.connectionInfo?.remoteAddress.address ?? 'unknown';
      final socket = await WebSocketTransformer.upgrade(request);
      _kdsSockets[socket] = ip;
      socket.add(
        jsonEncode({'type': 'orders', 'orders': _kdsOrders.values.toList()}),
      );
      socket.done.whenComplete(() => _kdsSockets.remove(socket));
      return;
    }

    if (request.method == 'GET' &&
        request.uri.path == '/cds/cart/stream' &&
        WebSocketTransformer.isUpgradeRequest(request)) {
      if (!FeatureSettings.isEnabled('customer_displays')) {
        request.response.statusCode = HttpStatus.serviceUnavailable;
        await request.response.close();
        return;
      }
      final ip = request.connectionInfo?.remoteAddress.address ?? 'unknown';
      final socket = await WebSocketTransformer.upgrade(request);
      _cdsSockets[socket] = ip;
      socket.add(jsonEncode({'type': 'cart_snapshot', 'cart': _cdsCart}));
      socket.done.whenComplete(() => _cdsSockets.remove(socket));
      return;
    }

    request.response.headers.contentType = ContentType.json;

    // /health stays open regardless of feature toggles — KDS/CDS pairing
    // (saving the main station URL) needs to succeed even if the feature is
    // currently off; only the live data streams above are actually gated.
    if (request.method == 'GET' && request.uri.path == '/health') {
      return _json(request, {'success': true, 'status': 'ok'});
    }

    if (request.method == 'GET' && request.uri.path == '/kds/orders') {
      if (!FeatureSettings.isEnabled('kitchen_printers')) {
        request.response.statusCode = HttpStatus.serviceUnavailable;
        return _json(request, {
          'success': false,
          'message': 'Kitchen printers is disabled.',
        });
      }
      return _json(request, {
        'success': true,
        'orders': _kdsOrders.values.toList(),
      });
    }

    if (request.method == 'POST' &&
        request.uri.path == '/kds/orders/complete-all') {
      if (!FeatureSettings.isEnabled('kitchen_printers')) {
        request.response.statusCode = HttpStatus.serviceUnavailable;
        return _json(request, {
          'success': false,
          'message': 'Kitchen printers is disabled.',
        });
      }
      final ids = await completeAllKdsOrders();
      return _json(request, {'success': true, 'ids': ids});
    }

    request.response.statusCode = HttpStatus.notFound;
    return _json(request, {'success': false, 'message': 'Not found'});
  }

  Future<void> _json(HttpRequest request, Map<String, Object?> data) async {
    request.response.write(jsonEncode(data));
    await request.response.close();
  }

  void _broadcast(Map<String, Object?> data) {
    final message = jsonEncode(data);
    for (final socket in _kdsSockets.keys.toList()) {
      if (socket.readyState == WebSocket.open) {
        socket.add(message);
      } else {
        _kdsSockets.remove(socket);
      }
    }
  }

  void _broadcastToCds(Map<String, Object?> data) {
    final message = jsonEncode(data);
    for (final socket in _cdsSockets.keys.toList()) {
      if (socket.readyState == WebSocket.open) {
        socket.add(message);
      } else {
        _cdsSockets.remove(socket);
      }
    }
  }
}
