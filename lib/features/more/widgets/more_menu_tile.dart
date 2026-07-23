import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/common/styles/global_text_style.dart';
import '../../../core/utils/constants/colors.dart';

class MoreMenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool centered;

  const MoreMenuTile({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.centered = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60.h,
        padding: centered ? null : EdgeInsets.only(left: 24.w),
        decoration: BoxDecoration(
          color: AppColors.chipBackground,
          border: Border.all(color: AppColors.cardBorder),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: centered
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            Icon(icon, size: 26.sp, color: AppColors.chipInactiveText),
            SizedBox(width: 12.w),
            Text(
              label,
              style: getTextStyle(
                fontSize: 16.4,
                fontWeight: FontWeight.w500,
                color: AppColors.chipInactiveText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
