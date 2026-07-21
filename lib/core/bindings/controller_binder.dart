import 'package:get/get.dart';

import '../controller/theme_controller.dart';
import '../../features/auth/controller/auth_controller.dart';
import '../../features/home/controller/home_controller.dart';
import '../../features/onboarding/controller/onboarding_controller.dart';
import '../../features/splash/controller/splash_controller.dart';

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
  }
}
