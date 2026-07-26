import 'package:get/get.dart';

import '../../../core/utils/helpers/app_helper.dart';
import '../models/app_device_model.dart';
import '../services/network_pairing_service.dart';

class AppsController extends GetxController {
  final devices = <AppDeviceModel>[
    const AppDeviceModel(
      id: 'cds-1',
      type: AppDeviceType.cds,
      name: 'Pos - 1',
      ipAddress: '192.168.12.88',
      isPaired: true,
    ),
    const AppDeviceModel(
      id: 'cds-2',
      type: AppDeviceType.cds,
      name: 'Pos - 2',
      ipAddress: '192.168.12.89',
      isPaired: false,
    ),
    const AppDeviceModel(
      id: 'cds-3',
      type: AppDeviceType.cds,
      name: 'Pos - 3',
      ipAddress: '192.168.12.90',
      isPaired: false,
    ),
    const AppDeviceModel(
      id: 'kds-1',
      type: AppDeviceType.kds,
      name: 'KDS - 1',
      ipAddress: '192.168.12.91',
      isPaired: true,
    ),
    const AppDeviceModel(
      id: 'kds-2',
      type: AppDeviceType.kds,
      name: 'KDS - 2',
      ipAddress: '192.168.12.92',
      isPaired: false,
    ),
    const AppDeviceModel(
      id: 'kds-3',
      type: AppDeviceType.kds,
      name: 'KDS - 3',
      ipAddress: '192.168.12.93',
      isPaired: false,
    ),
  ].obs;

  final isPairing = false.obs;

  List<AppDeviceModel> devicesOfType(AppDeviceType type) =>
      devices.where((d) => d.type == type).toList();

  int _indexOf(String id) => devices.indexWhere((d) => d.id == id);

  void addDevice(AppDeviceModel device) => devices.add(device);

  void removeDevice(String id) => devices.removeWhere((d) => d.id == id);

  void updateDeviceInfo(
    String id, {
    required String name,
    required String ipAddress,
    bool? isPaired,
  }) {
    final index = _indexOf(id);
    if (index == -1) return;
    devices[index] = devices[index].copyWith(
      name: name,
      ipAddress: ipAddress,
      isPaired: isPaired,
    );
  }

  Future<void> togglePairing(String id) async {
    final index = _indexOf(id);
    if (index == -1) return;
    final device = devices[index];

    if (device.isPaired) {
      devices[index] = device.copyWith(isPaired: false);
      return;
    }

    isPairing.value = true;
    try {
      final reachable = await NetworkPairingService.testConnection(
        device.ipAddress,
      );
      if (reachable) {
        devices[index] = device.copyWith(isPaired: true);
        AppHelperFunctions.showSuccessSnackBar(
          'Paired with ${device.name} (${device.ipAddress}).',
        );
      } else {
        AppHelperFunctions.showErrorSnackBar(
          'Could not reach ${device.ipAddress}. Check the device is on the same network.',
        );
      }
    } finally {
      isPairing.value = false;
    }
  }
}
