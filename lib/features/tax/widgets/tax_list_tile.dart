import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/common/styles/global_text_style.dart';
import '../../../core/utils/constants/colors.dart';
import '../models/tax_model.dart';

class TaxListTile extends StatelessWidget {
  final TaxModel tax;
  final VoidCallback onTap;

  const TaxListTile({super.key, required this.tax, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, AppColors.rowGradientEnd],
          ),
          border: Border.all(color: AppColors.cardBorder),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(
              Iconsax.percentage_circle,
              size: 24.sp,
              color: AppColors.onboardingBackground,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tax.name,
                    style: getTextStyle(
                      fontSize: 14.6,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onboardingBackground,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${tax.itemCount} Items',
                    style: getTextStyle(
                      fontSize: 12.8,
                      color: AppColors.chipInactiveText,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.stockBadgeBackground,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                '${formatTaxRate(tax.ratePercent)}%',
                style: getTextStyle(
                  fontSize: 12.8,
                  color: AppColors.stockBadgeText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
