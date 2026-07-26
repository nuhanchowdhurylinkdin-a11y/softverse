import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/helpers/app_helper.dart';
import '../models/app_device_model.dart';
import '../services/network_pairing_service.dart';
import 'apps_controller.dart';

class AppDeviceViewController extends GetxController {
  final AppsController _appsController = Get.find<AppsController>();

  String get deviceId => Get.arguments as String;

  late final AppDeviceModel device = _appsController.devices.firstWhere(
    (d) => d.id == deviceId,
  );

  late final nameController = TextEditingController(text: device.name);
  late final ipController = TextEditingController(text: device.ipAddress);

  final isPairing = false.obs;
  late final isPaired = device.isPaired.obs;

  Future<void> togglePairing() async {
    if (isPaired.value) {
      isPaired.value = false;
      return;
    }

    final ip = ipController.text.trim();
    if (ip.isEmpty) {
      AppHelperFunctions.showWarningSnackBar('Enter an IP address first.');
      return;
    }

    isPairing.value = true;
    try {
      final reachable = await NetworkPairingService.testConnection(ip);
      isPaired.value = reachable;
      if (reachable) {
        AppHelperFunctions.showSuccessSnackBar('Paired with $ip.');
      } else {
        AppHelperFunctions.showErrorSnackBar(
          'Could not reach $ip. Check the device is on the same network.',
        );
      }
    } finally {
      isPairing.value = false;
    }
  }

  void save() {
    final name = nameController.text.trim();
    final ip = ipController.text.trim();
    if (name.isEmpty || ip.isEmpty) {
      AppHelperFunctions.showWarningSnackBar(
        'Name and IP address cannot be empty.',
      );
      return;
    }
    _appsController.updateDeviceInfo(
      deviceId,
      name: name,
      ipAddress: ip,
      isPaired: isPaired.value,
    );
    Get.back();
  }

  void remove() {
    _appsController.removeDevice(deviceId);
    Get.back();
  }

  @override
  void onClose() {
    nameController.dispose();
    ipController.dispose();
    super.onClose();
  }
}
