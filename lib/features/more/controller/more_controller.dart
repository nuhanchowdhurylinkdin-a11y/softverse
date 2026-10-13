import 'package:get/get.dart';

import '../../../core/services/feature_settings.dart';
import '../../../core/services/storage_service.dart';
import '../../app_lock/controller/app_lock_controller.dart';
import '../../auth/controller/auth_controller.dart';
import '../../customer/controller/customer_controller.dart';
import '../../store/controller/store_controller.dart';
import '../../../routes/app_routes.dart';

class MoreController extends GetxController {
  // The logged-in staff member, not a hardcoded placeholder profile.
  String get profileName => StorageService.fullName ?? 'Softverse User';
  String get profileRole => _capitalize(StorageService.role);
  /// Live POS device name - follows renames made on the website.
  String get posLabel => Get.isRegistered<StoreController>()
      ? Get.find<StoreController>().currentPosName.value ?? ''
      : StorageService.posDeviceName ?? '';

  String _capitalize(String? value) {
    if (value == null || value.isEmpty) return '';
    return value[0].toUpperCase() + value.substring(1);
  }

  @override
  void onInit() {
    super.onInit();
    loadFeatureVisibility();
  }

  // The More screen reads FeatureSettings.isEnabled(...) inside Obx(), so
  // it updates the moment the cache does.
  Future<void> loadFeatureVisibility() => FeatureSettings.refresh();

  void openShift() => Get.toNamed(AppRoute.getShiftManagementScreen());

  void openItem() => Get.toNamed(AppRoute.getItemsMenuScreen());

  void openTables() => Get.toNamed(AppRoute.getAddTableScreen());

  void openCustomer() {
    final controller = Get.find<CustomerController>();
    controller.showList();
    controller.fetchCustomers();
    Get.toNamed(AppRoute.getViewCustomerScreen());
  }

  void openPrinterSettings() => Get.toNamed(AppRoute.getPrinterListScreen());

  void openAppsSettings() => Get.toNamed(AppRoute.getAppsMenuScreen());

  void openGeneralSettings() =>
      Get.toNamed(AppRoute.getGeneralSettingsScreen());

  void openTaxesSettings() => Get.toNamed(AppRoute.getTaxListScreen());

  void openPinSettings() => Get.find<AppLockController>().openChangePin();

  void openSupport() => Get.toNamed(AppRoute.getSupportScreen());

  void openNotifications() {}

  void logout() => Get.find<AuthController>().logout();
}
