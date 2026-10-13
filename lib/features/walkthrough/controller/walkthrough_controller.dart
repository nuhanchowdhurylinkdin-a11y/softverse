import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/feature_settings.dart';
import '../../../routes/app_routes.dart';
import '../../main_nav/controller/main_nav_controller.dart';

/// The intro slides shown after sign-up. Features are no longer switched on
/// here: the business manager sets them on the website (Settings →
/// Features) and every till simply follows that.
class WalkthroughController extends GetxController {
  final pageController = PageController();
  final currentPage = 0.obs;

  static const slideCount = 3;

  void onPageChanged(int index) => currentPage.value = index;

  void nextPage() {
    if (currentPage.value == slideCount - 1) {
      finish();
    } else {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void previousPage() {
    pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // MainNavController.currentIndex is a persistent singleton, not reset by
  // navigating to the /homeScreen route.
  void finish() {
    FeatureSettings.refresh();
    if (Get.isRegistered<MainNavController>()) {
      Get.find<MainNavController>().changeTab(0);
    }
    Get.offAllNamed(AppRoute.getHomeScreen());
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
