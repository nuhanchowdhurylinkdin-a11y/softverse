import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/common/styles/global_text_style.dart';
import '../../../core/utils/constants/colors.dart';

class DateFieldRow extends StatelessWidget {
  final String value;
  final VoidCallback? onTap;

  const DateFieldRow({super.key, required this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.chipBackground,
          border: Border.all(color: AppColors.cardBorder),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value,
              style: getTextStyle(
                fontSize: 16.4,
                fontWeight: FontWeight.w500,
                color: AppColors.chipInactiveText,
              ),
            ),
            Icon(Iconsax.calendar_1, size: 22.sp, color: AppColors.onboardingBackground),
          ],
        ),
      ),
    );
  }
}
