import 'package:get/get.dart';

import '../../../core/services/network_caller.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/terminal_heartbeat_service.dart';
import '../../../core/utils/constants/api_constants.dart';
import '../../../core/utils/helpers/app_helper.dart';
import '../../store/controller/store_controller.dart';
import '../models/pos_device_model.dart';

/// Which POS device (set up by the business manager on the website) this
/// till is signed in as. Chosen at login, after the store; devices another
/// till is already using can't be picked.
class PosDeviceController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();
  final devices = <PosDeviceModel>[].obs;
  final isLoading = false.obs;
  final selectedDeviceId = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    selectedDeviceId.value = StorageService.posDeviceId;
  }

  Future<bool> fetchDevices() async {
    final storeId = StorageService.storeId;
    if (storeId == null) return false;
    isLoading.value = true;
    final response = await _networkCaller.getRequest(
      ApiConstants.terminalPosDevices(storeId, StorageService.terminalId),
    );
    isLoading.value = false;
    if (!response.isSuccess || response.responseData is! Map) return false;
    final raw = (response.responseData as Map)['devices'];
    devices.assignAll(
      raw is List
          ? raw.whereType<Map>().map(
              (json) => PosDeviceModel.fromApi(Map<String, dynamic>.from(json)),
            )
          : const <PosDeviceModel>[],
    );
    return true;
  }

  /// After the store is chosen: keeps this till's device if it's still
  /// free, picks the only free one automatically, otherwise asks.
  Future<void> ensureSelected({
    required Future<void> Function() openPicker,
  }) async {
    if (!await fetchDevices()) return;
    if (devices.isEmpty) {
      // The store has no POS devices set up - selling still works.
      await StorageService.clearPosDevice();
      _refresh();
      return;
    }
    final current = devices.firstWhereOrNull(
      (d) => d.id == StorageService.posDeviceId,
    );
    if (current != null && !current.inUse) {
      await _remember(current);
      return;
    }
    final free = devices.where((d) => !d.inUse).toList();
    if (free.length == 1) {
      await _remember(free.first);
      return;
    }
    await StorageService.clearPosDevice();
    _refresh();
    await openPicker();
  }

  Future<void> select(PosDeviceModel device) async {
    if (device.inUse) {
      AppHelperFunctions.showWarningSnackBar(
        '"${device.name}" is in use on another device',
      );
      return;
    }
    await _remember(device);
    Get.back();
    AppHelperFunctions.showSuccessSnackBar('POS: ${device.name}');
  }

  Future<void> _remember(PosDeviceModel device) async {
    await StorageService.setPosDevice(id: device.id, name: device.name);
    _refresh();
    // Claim it on the server straight away so another till sees it in use.
    if (Get.isRegistered<TerminalHeartbeatService>()) {
      Get.find<TerminalHeartbeatService>().beat();
    }
  }

  void _refresh() {
    selectedDeviceId.value = StorageService.posDeviceId;
    if (Get.isRegistered<StoreController>()) {
      Get.find<StoreController>().refreshCurrent();
    }
  }
}
