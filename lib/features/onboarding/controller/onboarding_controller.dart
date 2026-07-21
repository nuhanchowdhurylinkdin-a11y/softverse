import 'package:get/get.dart';

import '../../../routes/app_routes.dart';

class OnboardingController extends GetxController {
  void goToRegistration() => Get.toNamed(AppRoute.getRegistrationScreen());

  void goToSignIn() => Get.toNamed(AppRoute.getLoginScreen());
}
