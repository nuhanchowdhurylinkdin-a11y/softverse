import 'package:get/get.dart';

import '../../../core/services/network_caller.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/constants/api_constants.dart';
import '../../../core/utils/helpers/app_helper.dart';
import '../../../routes/app_routes.dart';
import '../../pos_device/controller/pos_device_controller.dart';

class StoreOption {
  final String id;
  final String name;

  const StoreOption({required this.id, required this.name});
}

/// Which store this till's sales belong to. A business with several active
/// stores must send a storeId with every checkout - without a way to pick
/// one, adding a second store made every sale fail.
class StoreController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();

  final stores = <StoreOption>[].obs;
  final isLoading = false.obs;
  final currentStoreId = RxnString();
  final currentStoreName = RxnString();
  final currentPosName = RxnString();

  @override
  void onInit() {
    super.onInit();
    refreshCurrent();
  }

  void refreshCurrent() {
    currentStoreId.value = StorageService.storeId;
    currentStoreName.value = StorageService.storeName;
    currentPosName.value = StorageService.posDeviceName;
  }

  Future<bool> fetchStores() async {
    isLoading.value = true;
    final response = await _networkCaller.getRequest(ApiConstants.checkoutStores);
    isLoading.value = false;
    if (!response.isSuccess || response.responseData is! Map) return false;
    final raw = (response.responseData as Map)['stores'];
    if (raw is! List) return false;
    stores.assignAll(
      raw.whereType<Map>().map(
        (json) => StoreOption(
          id: json['id']?.toString() ?? '',
          name: json['name']?.toString() ?? '',
        ),
      ),
    );
    return true;
  }

  Future<void> select(StoreOption store) async {
    await StorageService.setStore(id: store.id, name: store.name);
    refreshCurrent();
  }

  /// Called after login and whenever a sale is rejected for missing a store:
  /// a single available store is picked automatically, several stores open
  /// the picker, and a remembered store that no longer exists is forgotten.
  Future<void> ensureSelected({bool forcePicker = false}) async {
    final loaded = await fetchStores();
    if (!loaded) return;
    refreshCurrent();

    final saved = currentStoreId.value;
    final stillValid = saved != null && stores.any((s) => s.id == saved);
    if (!stillValid && saved != null) {
      await StorageService.clearStore();
      refreshCurrent();
    }

    if (stores.length == 1) {
      if (!stillValid) await select(stores.first);
    } else if (stores.isNotEmpty && (forcePicker || !stillValid)) {
      await Get.toNamed(AppRoute.getStoreSelectScreen());
    }
    // Then the POS device of that store.
    if (StorageService.storeId != null) await ensureDevice();
  }

  /// Asks for this till's POS device (after the store) unless it's still
  /// valid and free - also used when the website disconnects a device.
  Future<void> ensureDevice() {
    return Get.find<PosDeviceController>().ensureSelected(
      openPicker: () async {
        await Get.toNamed(AppRoute.getPosDeviceScreen());
      },
    );
  }

  Future<void> pick(StoreOption store) async {
    await select(store);
    Get.back();
    AppHelperFunctions.showSuccessSnackBar('Store: ${store.name}');
  }
}
