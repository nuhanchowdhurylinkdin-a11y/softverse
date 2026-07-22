import 'package:get/get.dart';

import '../controller/theme_controller.dart';
import '../../features/auth/controller/auth_controller.dart';
import '../../features/checkout/controller/checkout_controller.dart';
import '../../features/home/controller/home_controller.dart';
import '../../features/invoice/controller/invoice_controller.dart';
import '../../features/main_nav/controller/main_nav_controller.dart';
import '../../features/onboarding/controller/onboarding_controller.dart';
import '../../features/splash/controller/splash_controller.dart';
import '../../features/transaction/controller/transaction_controller.dart';
import '../../features/walkthrough/controller/walkthrough_controller.dart';

class ControllerBinder extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ThemeController>(() => ThemeController(), fenix: true);
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    // Eager: SplashController's only job is its onInit timer, which a screen
    // that never reads `controller` in build() would otherwise never trigger.
    Get.put<SplashController>(SplashController(), permanent: true);
    Get.lazyPut<OnboardingController>(() => OnboardingController(), fenix: true);
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
    Get.lazyPut<WalkthroughController>(() => WalkthroughController(), fenix: true);
    Get.lazyPut<CheckoutController>(() => CheckoutController(), fenix: true);
    Get.lazyPut<TransactionController>(() => TransactionController(), fenix: true);
    Get.lazyPut<MainNavController>(() => MainNavController(), fenix: true);
    Get.lazyPut<InvoiceController>(() => InvoiceController(), fenix: true);
  }
}
