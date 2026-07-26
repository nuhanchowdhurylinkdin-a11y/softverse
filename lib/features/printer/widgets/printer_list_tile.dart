import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/common/styles/global_text_style.dart';
import '../../../core/utils/constants/colors.dart';
import '../models/printer_model.dart';

class PrinterListTile extends StatelessWidget {
  final PrinterModel printer;
  final VoidCallback onTap;

  const PrinterListTile({super.key, required this.printer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
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
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: AppColors.chipBackground,
                borderRadius: BorderRadius.circular(8.r),
              ),
              alignment: Alignment.center,
              child: Icon(
                Iconsax.printer,
                size: 36.sp,
                color: AppColors.onboardingBackground,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    printer.printerModel,
                    style: getTextStyle(
                      fontSize: 14.6,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onboardingBackground,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    printer.category,
                    style: getTextStyle(
                      fontSize: 12.8,
                      color: AppColors.chipInactiveText,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          color: printer.isConnected
                              ? AppColors.stockBadgeText
                              : AppColors.chipInactiveText,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        printer.isConnected ? 'Connected' : 'Disconnected',
                        style: getTextStyle(
                          fontSize: 12.8,
                          color: AppColors.chipInactiveText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (printer.isDefault)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.stockBadgeBackground,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  'Default',
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
