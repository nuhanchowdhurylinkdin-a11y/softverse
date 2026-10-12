import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../features/main_nav/controller/main_nav_controller.dart';
import '../../../routes/app_routes.dart';
import '../../utils/constants/colors.dart';
import '../styles/global_text_style.dart';
import 'till_identity_title.dart';

class _NavDrawerItem {
  final String label;
  final IconData icon;

  /// Bottom-nav tab this item opens; null for a pushed screen ([route]).
  final int? tabIndex;
  final String? route;

  const _NavDrawerItem({
    required this.label,
    required this.icon,
    this.tabIndex,
    this.route,
  });
}

class AppNavDrawer extends GetView<MainNavController> {
  const AppNavDrawer({super.key});

  static List<_NavDrawerItem> get _items => [
    _NavDrawerItem(label: 'Home'.tr, icon: Iconsax.home, tabIndex: 0),
    // Checkout is one tap away on Home; due balances need a shortcut more.
    _NavDrawerItem(
      label: 'Due Balances'.tr,
      icon: Iconsax.wallet_2,
      route: AppRoute.getCustomerDueListScreen(),
    ),
    _NavDrawerItem(label: 'Transaction'.tr, icon: Iconsax.refresh, tabIndex: 2),
    _NavDrawerItem(label: 'Inventory'.tr, icon: Iconsax.box, tabIndex: 3),
    _NavDrawerItem(label: 'More'.tr, icon: Iconsax.menu, tabIndex: 4),
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Obx(
          () => ListView(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
                child: const TillIdentityTitle(
                  color: AppColors.onboardingBackground,
                  subtitleColor: AppColors.chipInactiveText,
                ),
              ),
              for (var i = 0; i < _items.length; i++) _buildTile(context, i),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context, int index) {
    final item = _items[index];
    final selected =
        item.tabIndex != null && controller.currentIndex.value == item.tabIndex;
    final color = selected
        ? AppColors.onboardingBackground
        : AppColors.chipInactiveText;

    return ListTile(
      selected: selected,
      selectedTileColor: AppColors.chipBackground,
      leading: Icon(item.icon, size: 22.sp, color: color),
      title: Text(
        item.label,
        style: getTextStyle(
          fontSize: 14.6,
          fontWeight: FontWeight.w500,
          color: color,
          textAlign: TextAlign.left,
        ),
      ),
      onTap: () {
        Navigator.of(context).pop();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (item.route != null) {
            Get.toNamed(item.route!);
          } else {
            controller.changeTab(item.tabIndex!);
          }
        });
      },
    );
  }
}
