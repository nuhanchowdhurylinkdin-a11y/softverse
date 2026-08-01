import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../features/main_nav/controller/main_nav_controller.dart';
import '../../utils/constants/colors.dart';
import '../styles/global_text_style.dart';

class _NavDrawerItem {
  final String label;
  final IconData icon;

  const _NavDrawerItem({required this.label, required this.icon});
}

class AppNavDrawer extends GetView<MainNavController> {
  const AppNavDrawer({super.key});

  static const _items = [
    _NavDrawerItem(label: 'Home', icon: Iconsax.home),
    _NavDrawerItem(label: 'Checkout', icon: Iconsax.shopping_cart),
    _NavDrawerItem(label: 'Transaction', icon: Iconsax.refresh),
    _NavDrawerItem(label: 'Inventory', icon: Iconsax.box),
    _NavDrawerItem(label: 'More', icon: Iconsax.menu),
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
                child: Text(
                  'POS-1',
                  style: getTextStyle(
                    fontSize: 21.9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onboardingBackground,
                    textAlign: TextAlign.left,
                  ),
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
    final selected = controller.currentIndex.value == index;
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
        controller.changeTab(index);
        Navigator.of(context).pop();
      },
    );
  }
}
