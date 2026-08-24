import 'package:get/get.dart';

import '../../../core/services/feature_settings.dart';
import '../../../core/services/network_caller.dart';
import '../../../core/services/offline_database_service.dart';
import '../../../core/utils/constants/api_constants.dart';
import '../../auth/controller/auth_controller.dart';
import '../../customer/controller/customer_controller.dart';
import '../../../routes/app_routes.dart';

class MoreController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();
  final profileName = 'Liam Macey';
  final profileRole = 'Softvence';
  final posLabel = 'POS-1';
  final profileImageUrl = 'https://randomuser.me/api/portraits/men/32.jpg';

  @override
  void onInit() {
    super.onInit();
    loadFeatureVisibility();
  }

  // Refreshes the cache; the More screen reads FeatureSettings.isEnabled(...)
  // directly inside Obx(), so it updates the moment the cache does.
  Future<void> loadFeatureVisibility() async {
    final response = await _networkCaller.getRequest(
      ApiConstants.featureSettings,
    );
    if (!response.isSuccess || response.responseData is! Map) return;
    final data = Map<String, dynamic>.from(response.responseData as Map);
    await OfflineDatabaseService.saveCache('feature_settings', data);
    FeatureSettings.notifyChanged();
  }

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

  void openBackOffice() => Get.toNamed(AppRoute.getFeatureSettingsScreen());

  void openAppsIntegration() {}

  void openSupport() {}

  void switchPos() {}

  void openNotifications() {}

  void logout() => Get.find<AuthController>().logout();
}
