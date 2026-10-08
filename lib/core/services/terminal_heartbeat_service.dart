import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';

import '../utils/constants/api_constants.dart';
import 'network_caller.dart';
import 'storage_service.dart';

/// Tells the server once a minute that this till is connected, so the
/// super manager can see which terminals are online, where and for how long.
class TerminalHeartbeatService extends GetxService {
  static const interval = Duration(minutes: 1);

  final NetworkCaller _networkCaller = NetworkCaller();
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _timer = Timer.periodic(interval, (_) => beat());
    unawaited(beat());
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  Future<void> beat() async {
    if (!StorageService.hasToken()) return;
    try {
      await _networkCaller.postRequest(
        ApiConstants.terminalHeartbeat,
        body: {
          'deviceId': StorageService.terminalId,
          if (StorageService.posDeviceName != null)
            'deviceName': StorageService.posDeviceName,
          'platform': Platform.operatingSystem,
          'country': ?_regionCode(),
          'timezone': DateTime.now().timeZoneName,
        },
      );
    } catch (_) {
      // Offline or server down - the next beat simply starts a new session.
    }
  }

  /// Device region from the locale, e.g. "en_US" -> "US".
  String? _regionCode() {
    final parts = Platform.localeName.split(RegExp('[_-]'));
    if (parts.length < 2) return null;
    final region = parts[1].split('.').first.toUpperCase();
    return RegExp(r'^[A-Z]{2}$').hasMatch(region) ? region : null;
  }
}
