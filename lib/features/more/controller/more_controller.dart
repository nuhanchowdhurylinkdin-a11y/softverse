import 'package:get/get.dart';

import '../../../routes/app_routes.dart';

class MoreController extends GetxController {
  final profileName = 'Liam Macey';
  final profileRole = 'Softvence';
  final posLabel = 'POS-1';
  final profileImageUrl = 'https://randomuser.me/api/portraits/men/32.jpg';

  void openShift() => Get.toNamed(AppRoute.getShiftManagementScreen());

  void openItem() => Get.toNamed(AppRoute.getItemsMenuScreen());

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

  void logout() {}
}
