import 'package:get/get.dart';

import '../../features/apps/controller/apps_controller.dart';
import '../../features/checkout/controller/checkout_controller.dart';
import '../../features/customer/controller/customer_controller.dart';
import '../../features/general/controller/general_controller.dart';
import '../../features/home/controller/home_controller.dart';
import '../../features/inventory/controller/inventory_controller.dart';
import '../../features/invoice/controller/invoice_controller.dart';
import '../../features/main_nav/controller/main_nav_controller.dart';
import '../../features/more/controller/more_controller.dart';
import '../../features/printer/controller/printer_controller.dart';
import '../../features/shift/controller/shift_controller.dart';
import '../../features/tax/controller/tax_controller.dart';
import '../../features/transaction/controller/transaction_controller.dart';
import '../../features/walkthrough/controller/walkthrough_controller.dart';
import '../../routes/app_routes.dart';
import 'feature_settings.dart';
import 'offline_database_service.dart';
import 'storage_service.dart';

class SessionLifecycleService {
  SessionLifecycleService._();

  static bool _isEndingSession = false;

  static Future<void> endSession({bool navigateToLogin = true}) async {
    if (_isEndingSession) return;
    _isEndingSession = true;
    try {
      // Capture and clear the current owner's data before removing their IDs.
      await OfflineDatabaseService.clearCurrentOwnerData();
      await _deleteIfRegistered<HomeController>();
      await _deleteIfRegistered<CheckoutController>();
      await _deleteIfRegistered<TransactionController>();
      await _deleteIfRegistered<InvoiceController>();
      await _deleteIfRegistered<InventoryController>();
      await _deleteIfRegistered<MoreController>();
      await _deleteIfRegistered<ShiftController>();
      await _deleteIfRegistered<CustomerController>();
      await _deleteIfRegistered<PrinterController>();
      await _deleteIfRegistered<AppsController>();
      await _deleteIfRegistered<TaxController>();
      await _deleteIfRegistered<GeneralController>();
      await _deleteIfRegistered<WalkthroughController>();

      if (Get.isRegistered<MainNavController>()) {
        Get.find<MainNavController>().changeTab(0);
      }
      FeatureSettings.notifyChanged();
      await StorageService.logoutUser();
      if (navigateToLogin) {
        Get.offAllNamed(AppRoute.getLoginScreen());
      }
    } finally {
      _isEndingSession = false;
    }
  }

  static Future<void> _deleteIfRegistered<T extends GetxController>() async {
    if (Get.isRegistered<T>()) {
      await Get.delete<T>(force: true);
    }
  }
}
