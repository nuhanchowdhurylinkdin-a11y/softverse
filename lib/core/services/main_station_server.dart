import 'dart:convert';
import 'dart:io';

class MainStationServer {
  MainStationServer._();

  static final instance = MainStationServer._();
  static const port = 8787;

  final _kdsOrders = <String, Map<String, dynamic>>{};
  final _kdsSockets = <WebSocket>{};
  HttpServer? _server;

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
    final key = id.trim();
    if (key.isEmpty) return false;

    final order = _kdsOrders.remove(key);
    final completed = {
      ...?order,
      'id': key,
      'status': 'completed',
      'completedAt': DateTime.now().toIso8601String(),
    };
    _broadcast({'type': 'order_completed', 'id': key, 'order': completed});
    return true;
  }

  Future<void> _handle(HttpRequest request) async {
    if (request.method == 'GET' &&
        request.uri.path == '/kds/orders/stream' &&
        WebSocketTransformer.isUpgradeRequest(request)) {
      final socket = await WebSocketTransformer.upgrade(request);
      _kdsSockets.add(socket);
      socket.add(
        jsonEncode({'type': 'orders', 'orders': _kdsOrders.values.toList()}),
      );
      socket.done.whenComplete(() => _kdsSockets.remove(socket));
      return;
    }

    request.response.headers.contentType = ContentType.json;

    if (request.method == 'GET' && request.uri.path == '/health') {
      return _json(request, {'success': true, 'status': 'ok'});
    }

    if (request.method == 'GET' && request.uri.path == '/kds/orders') {
      return _json(request, {
        'success': true,
        'orders': _kdsOrders.values.toList(),
      });
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
    for (final socket in _kdsSockets.toList()) {
      if (socket.readyState == WebSocket.open) {
        socket.add(message);
      } else {
        _kdsSockets.remove(socket);
      }
    }
  }
}
