import 'package:get/get.dart';

import '../../../core/services/network_caller.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/constants/api_constants.dart';
import '../../../core/utils/helpers/app_helper.dart';
import '../models/pos_device_model.dart';

/// Backs the "Switch POS" screen - lets an owner/manager pick which of the
/// POS devices configured on the Business Admin dashboard this physical
/// till actually is. The selection is stored on the device itself (see
/// [StorageService.setPosDevice]), not tied to whoever is logged in, so it
/// survives logout and shows up for every cashier who uses this same phone.
class PosDeviceController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();
  final devices = <PosDeviceModel>[].obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final selectedDeviceId = Rxn<String>();
  final currentDeviceLabel = 'Not activated'.obs;

  @override
  void onInit() {
    super.onInit();
    _refreshSelection();
    fetchDevices();
  }

  void _refreshSelection() {
    selectedDeviceId.value = StorageService.posDeviceId;
    currentDeviceLabel.value = StorageService.posDeviceName ?? 'Not activated';
  }

  Future<bool> fetchDevices() async {
    isLoading.value = true;
    final response = await _networkCaller.getRequest(ApiConstants.posDevices);
    isLoading.value = false;

    if (!response.isSuccess || response.responseData is! Map) {
      if (response.statusCode == 403) {
        AppHelperFunctions.showErrorSnackBar(
          'Ask an owner or manager to set up POS devices for this business.',
        );
      } else {
        AppHelperFunctions.showErrorSnackBar(response.errorMessage);
      }
      return false;
    }

    final data = Map<String, dynamic>.from(response.responseData as Map);
    final rawDevices = data['devices'] is List
        ? List<dynamic>.from(data['devices'] as List)
        : <dynamic>[];
    devices.assignAll(
      rawDevices.whereType<Map>().map(
        (json) => PosDeviceModel.fromApi(Map<String, dynamic>.from(json)),
      ),
    );
    return true;
  }

  Future<bool> selectDevice(PosDeviceModel device) async {
    isSaving.value = true;
    final response = await _networkCaller.patchRequest(
      ApiConstants.posDevice(device.id),
      body: {'status': 'activated'},
    );
    isSaving.value = false;

    if (!response.isSuccess) {
      AppHelperFunctions.showErrorSnackBar(response.errorMessage);
      return false;
    }

    await StorageService.setPosDevice(id: device.id, name: device.name);
    _refreshSelection();
    AppHelperFunctions.showSuccessSnackBar(
      'This device is now set up as "${device.name}".',
    );
    await fetchDevices();
    return true;
  }
}
