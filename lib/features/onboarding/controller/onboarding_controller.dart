import 'package:get/get.dart';

import '../../../core/services/storage_service.dart';
import '../../../routes/app_routes.dart';

class OnboardingController extends GetxController {
  Future<void> goToRegistration() async {
    await StorageService.setOnboardingComplete(true);
    Get.toNamed(AppRoute.getRegistrationScreen());
  }

  Future<void> goToSignIn() async {
    await StorageService.setOnboardingComplete(true);
    Get.toNamed(AppRoute.getLoginScreen());
  }
}
