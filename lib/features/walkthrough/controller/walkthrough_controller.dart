import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../routes/app_routes.dart';
import '../models/feature_toggle_item.dart';

class WalkthroughController extends GetxController {
  final pageController = PageController();
  final currentPage = 0.obs;

  static const slideCount = 3;

  final features = <FeatureToggleItem>[
    const FeatureToggleItem(
      title: 'Shifts',
      subtitle: 'Track cash that goes in and out of your drawer',
      icon: Iconsax.clock,
    ),
    const FeatureToggleItem(
      title: 'Open Order',
      subtitle: 'Allow to save and edit orders before completing a payment',
      icon: Iconsax.ticket,
    ),
    const FeatureToggleItem(
      title: 'Kitchen printers',
      subtitle: 'Send orders to kitchen printer or display',
      icon: Iconsax.printer,
    ),
    const FeatureToggleItem(
      title: 'Customer displays',
      subtitle:
          'Display order information to customers at the time of purchase',
      icon: Iconsax.monitor,
    ),
    const FeatureToggleItem(
      title: 'Table options',
      subtitle: 'Mark orders as dine in, takeout, or for delivery',
      icon: Iconsax.reserve,
    ),
    const FeatureToggleItem(
      title: 'Low stock notifications',
      subtitle: 'Get daily email on items that are low or out of stock',
      icon: Iconsax.notification,
    ),
    const FeatureToggleItem(
      title: 'Negative stock alerts',
      subtitle:
          'Warn cashiers attempting to sell more inventory than available in stock',
      icon: Iconsax.document,
    ),
    const FeatureToggleItem(
      title: 'Credit Sales',
      subtitle:
          'Credit sales allow businesses to sell now and receive payment later.',
      icon: Iconsax.tag,
    ),
    const FeatureToggleItem(
      title: 'Payment in Installments',
      subtitle:
          'It offers a convenient installment payment system to help manage your finances.',
      icon: Iconsax.wallet,
    ),
    const FeatureToggleItem(
      title: 'Product Expiration Information',
      subtitle:
          'Expiration Alerts: Keep track of your purchases and access exclusive deals!',
      icon: Iconsax.calendar,
    ),
  ];

  late final featureToggles = List.generate(features.length, (_) => false.obs);

  void toggleFeature(int index) =>
      featureToggles[index].value = !featureToggles[index].value;

  void onPageChanged(int index) => currentPage.value = index;

  void nextPage() {
    if (currentPage.value == slideCount - 1) {
      Get.toNamed(AppRoute.getFeatureSettingsScreen());
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

  void saveFeatureSettings() => Get.offAllNamed(AppRoute.getHomeScreen());

  void skipFeatureSettings() => Get.offAllNamed(AppRoute.getHomeScreen());

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
