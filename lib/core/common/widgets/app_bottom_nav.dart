import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/constants/colors.dart';
import '../styles/global_text_style.dart';

class BottomNavItem {
  final String label;
  final IconData icon;

  const BottomNavItem({required this.label, required this.icon});
}

class AppBottomNav extends StatelessWidget {
  final List<BottomNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const AppBottomNav({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: SafeArea(
        top: false,
        child: Row(
          children: List.generate(items.length, (index) {
            final selected = index == selectedIndex;
            final color = selected
                ? AppColors.onboardingBackground
                : AppColors.chipInactiveText;
            return Expanded(
              child: GestureDetector(
                onTap: () => onSelected(index),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(items[index].icon, size: 22.sp, color: color),
                    SizedBox(height: 2.h),
                    Text(
                      items[index].label,
                      style: getTextStyle(fontSize: 12.8, color: color),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
