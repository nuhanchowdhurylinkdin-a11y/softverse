import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/common/styles/global_text_style.dart';
import '../../../core/utils/constants/colors.dart';

class ShiftActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;

  const ShiftActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color contentColor = filled
        ? Colors.white
        : AppColors.chipInactiveText;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          color: filled ? null : AppColors.chipBackground,
          border: filled ? null : Border.all(color: AppColors.cardBorder),
          gradient: filled
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.shiftButtonGradientStart,
                    AppColors.shiftButtonGradientEnd,
                  ],
                )
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 26.sp, color: contentColor),
            SizedBox(width: 12.w),
            Text(
              label,
              style: getTextStyle(
                fontSize: 16.4,
                fontWeight: FontWeight.w500,
                color: contentColor,
              ).copyWith(letterSpacing: 0.08),
            ),
          ],
        ),
      ),
    );
  }
}
