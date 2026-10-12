import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/common/styles/global_text_style.dart';
import '../../../core/utils/constants/colors.dart';
import '../../../core/utils/helpers/app_helper.dart';

/// "Use loyalty points" switch shown when the chosen customer has points.
class LoyaltyPointsTile extends StatelessWidget {
  final double availablePoints;
  final bool isUsing;
  final double usedValue;
  final VoidCallback onToggle;

  const LoyaltyPointsTile({
    super.key,
    required this.availablePoints,
    required this.isUsing,
    required this.usedValue,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Icon(
            Iconsax.gift,
            size: 22.sp,
            color: AppColors.onboardingBackground,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Use loyalty points',
                  style: getTextStyle(
                    fontSize: 14.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  isUsing
                      ? 'Using ${AppHelperFunctions.formatCurrency(usedValue)}'
                      : '${availablePoints.toStringAsFixed(2)} points available',
                  style: getTextStyle(
                    fontSize: 12.4,
                    color: AppColors.chipInactiveText,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: isUsing, onChanged: (_) => onToggle()),
        ],
      ),
    );
  }
}
