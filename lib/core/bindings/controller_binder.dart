import 'package:get/get.dart';

import '../controller/theme_controller.dart';
import '../../features/apps/controller/apps_controller.dart';
import '../../features/auth/controller/auth_controller.dart';
import '../../features/checkout/controller/checkout_controller.dart';
import '../../features/customer/controller/customer_controller.dart';
import '../../features/general/controller/general_controller.dart';
import '../../features/home/controller/home_controller.dart';
import '../../features/inventory/controller/inventory_controller.dart';
import '../../features/invoice/controller/invoice_controller.dart';
import '../../features/main_nav/controller/main_nav_controller.dart';
import '../../features/more/controller/more_controller.dart';
import '../../features/onboarding/controller/onboarding_controller.dart';
import '../../features/printer/controller/printer_controller.dart';
import '../../features/shift/controller/shift_controller.dart';
import '../../features/splash/controller/splash_controller.dart';
import '../../features/tax/controller/tax_controller.dart';
import '../../features/transaction/controller/transaction_controller.dart';
import '../../features/walkthrough/controller/walkthrough_controller.dart';
import '../services/sync_service.dart';

class ControllerBinder extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ThemeController>(() => ThemeController(), fenix: true);
    Get.putAsync<SyncService>(() => SyncService().init(), permanent: true);
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    // Eager: SplashController's only job is its onInit timer, which a screen
    // that never reads `controller` in build() would otherwise never trigger.
    Get.put<SplashController>(SplashController(), permanent: true);
    Get.lazyPut<OnboardingController>(
      () => OnboardingController(),
      fenix: true,
    );
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.lazyPut<WalkthroughController>(
      () => WalkthroughController(),
      fenix: true,
    );
    Get.lazyPut<CheckoutController>(() => CheckoutController(), fenix: true);
    Get.lazyPut<TransactionController>(
      () => TransactionController(),
      fenix: true,
    );
    // permanent, not fenix: it's read by every tab's Scaffold (drawer) and
    // the IndexedStack simultaneously — if GetX ever disposes and silently
    // recreates it (fenix does this once nothing holds a reference, which
    // briefly happens during Get.offAllNamed), those widgets can end up
    // bound to two different instances, so drawer taps stop switching tabs.
    Get.put<MainNavController>(MainNavController(), permanent: true);
    Get.lazyPut<InvoiceController>(() => InvoiceController(), fenix: true);
    Get.lazyPut<InventoryController>(() => InventoryController(), fenix: true);
    Get.lazyPut<MoreController>(() => MoreController(), fenix: true);
    Get.lazyPut<ShiftController>(() => ShiftController(), fenix: true);
    Get.lazyPut<CustomerController>(() => CustomerController(), fenix: true);
    Get.lazyPut<PrinterController>(() => PrinterController(), fenix: true);
    Get.lazyPut<AppsController>(() => AppsController(), fenix: true);
    Get.lazyPut<TaxController>(() => TaxController(), fenix: true);
    Get.lazyPut<GeneralController>(() => GeneralController(), fenix: true);
  }
}
