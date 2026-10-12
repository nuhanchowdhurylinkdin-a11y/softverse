import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';

import '../utils/constants/api_constants.dart';
import 'network_caller.dart';
import 'storage_service.dart';
import '../../features/store/controller/store_controller.dart';

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
      final response = await _networkCaller.postRequest(
        ApiConstants.terminalHeartbeat,
        body: {
          'deviceId': StorageService.terminalId,
          'posDeviceId': ?StorageService.posDeviceId,
          if (StorageService.posDeviceName != null)
            'deviceName': StorageService.posDeviceName,
          'platform': Platform.operatingSystem,
          'country': ?_regionCode(),
          'timezone': DateTime.now().timeZoneName,
        },
      );
      final data = response.responseData;
      if (response.isSuccess && data is Map && data['posDevice'] is Map) {
        await _applyPosDevice(
          Map<String, dynamic>.from(data['posDevice'] as Map),
        );
      }
    } catch (_) {
      // Offline or server down - the next beat simply starts a new session.
    }
  }

  /// Keeps this till's POS device in step with the website: a rename shows
  /// within a minute, and a device the manager disconnected sends the user
  /// back to choose the store and POS device again.
  Future<void> _applyPosDevice(Map<String, dynamic> device) async {
    if (device['id']?.toString() != StorageService.posDeviceId) return;
    if (device['active'] != true) {
      await StorageService.clearPosDevice();
      if (Get.isRegistered<StoreController>()) {
        await Get.find<StoreController>().ensureSelected(forcePicker: true);
      }
      return;
    }
    final name = device['name']?.toString();
    if (name != null &&
        name.isNotEmpty &&
        name != StorageService.posDeviceName) {
      await StorageService.setPosDevice(
        id: device['id'].toString(),
        name: name,
      );
      if (Get.isRegistered<StoreController>()) {
        Get.find<StoreController>().refreshCurrent();
      }
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
