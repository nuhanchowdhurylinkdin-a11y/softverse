import 'package:get/get.dart';

import '../../../routes/app_routes.dart';

class MoreController extends GetxController {
  final profileName = 'Liam Macey';
  final profileRole = 'Softvence';
  final posLabel = 'POS-1';
  final profileImageUrl = 'https://randomuser.me/api/portraits/men/32.jpg';

  void openShift() => Get.toNamed(AppRoute.getShiftManagementScreen());

  void openItem() => Get.toNamed(AppRoute.getItemsMenuScreen());

  void openCustomer() {}

  void openPrinterSettings() {}

  void openAppsSettings() {}

  void openGeneralSettings() {}

  void openTaxesSettings() {}

  void openBackOffice() {}

  void openAppsIntegration() {}

  void openSupport() {}

  void switchPos() {}

  void openNotifications() {}

  void logout() {}
}
