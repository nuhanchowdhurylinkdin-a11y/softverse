import 'dart:io';

class NetworkPairingService {
  NetworkPairingService._();

  static const int defaultPort = 80;

  static Future<bool> testConnection(
    String ip, {
    int port = defaultPort,
    Duration timeout = const Duration(seconds: 2),
  }) async {
    try {
      final socket = await Socket.connect(ip, port, timeout: timeout);
      socket.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<String?> _localSubnetBase() async {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLoopback: false,
    );
    for (final iface in interfaces) {
      for (final address in iface.addresses) {
        if (address.isLoopback) continue;
        final parts = address.address.split('.');
        if (parts.length == 4) {
          return '${parts[0]}.${parts[1]}.${parts[2]}';
        }
      }
    }
    return null;
  }

  static Future<List<String>> scanLocalSubnet({
    int port = defaultPort,
    Duration perHostTimeout = const Duration(milliseconds: 300),
  }) async {
    final base = await _localSubnetBase();
    if (base == null) return [];

    final found = <String>[];
    const batchSize = 32;
    for (var start = 1; start <= 254; start += batchSize) {
      final end = (start + batchSize - 1).clamp(1, 254);
      final batch = [for (var i = start; i <= end; i++) '$base.$i'];
      final results = await Future.wait(
        batch.map((ip) async {
          final reachable = await testConnection(
            ip,
            port: port,
            timeout: perHostTimeout,
          );
          return reachable ? ip : null;
        }),
      );
      found.addAll(results.whereType<String>());
    }
    return found;
  }
}
