import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/common/styles/global_text_style.dart';
import '../../../core/utils/constants/colors.dart';

class ItemMenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const ItemMenuTile({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 68.h,
        padding: EdgeInsets.only(left: 20.w),
        decoration: BoxDecoration(
          color: AppColors.chipBackground,
          border: Border.all(color: AppColors.cardBorder),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22.sp, color: AppColors.onboardingBackground),
            SizedBox(width: 8.w),
            Text(
              label,
              style: getTextStyle(
                fontSize: 16.4,
                fontWeight: FontWeight.w500,
                color: AppColors.onboardingBackground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
