import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/common/styles/global_text_style.dart';
import '../../../core/utils/constants/colors.dart';
import '../models/app_device_model.dart';

class AppDeviceListTile extends StatelessWidget {
  final AppDeviceModel device;
  final VoidCallback onTap;

  const AppDeviceListTile({
    super.key,
    required this.device,
    required this.onTap,
  });

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
              Iconsax.monitor,
              size: 28.sp,
              color: AppColors.onboardingBackground,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.name,
                    style: getTextStyle(
                      fontSize: 14.6,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onboardingBackground,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: const BoxDecoration(
                          color: AppColors.stockBadgeText,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Connected',
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
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: device.isPaired
                    ? AppColors.stockBadgeBackground
                    : AppColors.dangerRed.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                device.isPaired ? 'Paired' : 'Unpaired',
                style: getTextStyle(
                  fontSize: 12.8,
                  color: device.isPaired
                      ? AppColors.stockBadgeText
                      : AppColors.dangerRed,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
