import 'package:get/get.dart';

import '../../../core/services/network_caller.dart';
import '../../../core/services/offline_database_service.dart';
import '../../../core/utils/constants/api_constants.dart';
import '../../auth/controller/auth_controller.dart';
import '../../../routes/app_routes.dart';

class MoreController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();
  final profileName = 'Liam Macey';
  final profileRole = 'Softvence';
  final posLabel = 'POS-1';
  final profileImageUrl = 'https://randomuser.me/api/portraits/men/32.jpg';
  final tableOptionsEnabled = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadFeatureVisibility();
  }

  Future<void> loadFeatureVisibility() async {
    final cached = OfflineDatabaseService.readCache<Map<String, dynamic>>(
      'feature_settings',
    );
    final cachedValue = _tableOptionsFromSettings(cached);
    if (cachedValue != null) tableOptionsEnabled.value = cachedValue;

    final response = await _networkCaller.getRequest(
      ApiConstants.featureSettings,
    );
    if (!response.isSuccess || response.responseData is! Map) return;
    final data = Map<String, dynamic>.from(response.responseData as Map);
    await OfflineDatabaseService.saveCache('feature_settings', data);
    tableOptionsEnabled.value = _tableOptionsFromSettings(data) ?? false;
  }

  void openShift() => Get.toNamed(AppRoute.getShiftManagementScreen());

  void openItem() => Get.toNamed(AppRoute.getItemsMenuScreen());

  void openTables() => Get.toNamed(AppRoute.getAddTableScreen());

  void openCustomer() => Get.toNamed(AppRoute.getViewCustomerScreen());

  void openPrinterSettings() => Get.toNamed(AppRoute.getPrinterListScreen());

  void openAppsSettings() => Get.toNamed(AppRoute.getAppsMenuScreen());

  void openGeneralSettings() =>
      Get.toNamed(AppRoute.getGeneralSettingsScreen());

  void openTaxesSettings() => Get.toNamed(AppRoute.getTaxListScreen());

  void openBackOffice() {}

  void openAppsIntegration() {}

  void openSupport() {}

  void switchPos() {}

  void openNotifications() {}

  void logout() => Get.find<AuthController>().logout();

  bool? _tableOptionsFromSettings(Map<String, dynamic>? data) {
    final rawFeatures = data?['features'];
    if (rawFeatures is! List) return null;
    for (final raw in rawFeatures) {
      if (raw is! Map) continue;
      if (raw['key']?.toString() == 'table_options') {
        return raw['enabled'] == true;
      }
    }
    return null;
  }
}
