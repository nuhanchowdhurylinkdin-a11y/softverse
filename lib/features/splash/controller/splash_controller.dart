import 'package:get/get.dart';

import '../../../core/services/storage_service.dart';
import '../../../routes/app_routes.dart';
import '../../store/controller/store_controller.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToOnboarding();
  }

  Future<void> _navigateToOnboarding() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!StorageService.isOnboardingComplete) {
      Get.offAllNamed(AppRoute.getOnboardingScreen());
      return;
    }
    if (!StorageService.hasToken()) {
      Get.offAllNamed(AppRoute.getLoginScreen());
      return;
    }
    if (!StorageService.isFeatureSettingsComplete) {
      Get.offAllNamed(AppRoute.getFeatureSettingsScreen());
      return;
    }
    Get.offAllNamed(AppRoute.getHomeScreen());
    // A store may have been added since the last session.
    Get.find<StoreController>().ensureSelected();
  }
}
