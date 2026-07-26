import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/helpers/app_helper.dart';
import '../models/app_device_model.dart';
import '../services/network_pairing_service.dart';
import 'apps_controller.dart';

class AddAppDeviceController extends GetxController {
  final AppsController _appsController = Get.find<AppsController>();

  AppDeviceType get type => Get.arguments as AppDeviceType;

  final nameController = TextEditingController();
  final ipController = TextEditingController();

  final isScanning = false.obs;
  final isPairing = false.obs;
  final isPaired = false.obs;
  final foundDevices = <String>[].obs;

  Future<void> scanNetwork() async {
    isScanning.value = true;
    foundDevices.clear();
    try {
      final results = await NetworkPairingService.scanLocalSubnet();
      foundDevices.assignAll(results);
      if (results.isEmpty) {
        AppHelperFunctions.showWarningSnackBar(
          'No reachable devices found on this network.',
        );
      }
    } finally {
      isScanning.value = false;
    }
  }

  void selectIp(String ip) {
    ipController.text = ip;
    isPaired.value = false;
  }

  Future<void> togglePairing() async {
    if (isPaired.value) {
      isPaired.value = false;
      return;
    }

    final ip = ipController.text.trim();
    if (ip.isEmpty) {
      AppHelperFunctions.showWarningSnackBar(
        'Enter or search for an IP address first.',
      );
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
        'Enter a name and an IP address to continue.',
      );
      return;
    }

    _appsController.addDevice(
      AppDeviceModel(
        id: '${type.name}-${DateTime.now().millisecondsSinceEpoch}',
        type: type,
        name: name,
        ipAddress: ip,
        isPaired: isPaired.value,
      ),
    );
    Get.back();
  }

  @override
  void onClose() {
    nameController.dispose();
    ipController.dispose();
    super.onClose();
  }
}
