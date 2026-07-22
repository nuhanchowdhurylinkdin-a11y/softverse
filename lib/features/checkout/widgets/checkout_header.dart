import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/common/styles/global_text_style.dart';
import '../../../core/utils/constants/colors.dart';

class CheckoutHeader extends StatelessWidget {
  final String orderId;
  final String customerName;
  final VoidCallback onAddCustomer;

  const CheckoutHeader({
    super.key,
    required this.orderId,
    required this.customerName,
    required this.onAddCustomer,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 58.h,
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [AppColors.posHeaderStart, AppColors.posHeaderEnd],
            ),
          ),
          child: Row(
            children: [
              Text(
                orderId,
                style: getTextStyle(
                  fontSize: 16.4,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Icon(Iconsax.clock, color: Colors.white, size: 26.sp),
              SizedBox(width: 15.w),
              Icon(Iconsax.notification, color: Colors.white, size: 26.sp),
              SizedBox(width: 15.w),
              Icon(Iconsax.more, color: Colors.white, size: 26.sp),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 55.h,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: AppColors.chipBackground,
                    border: Border.all(color: AppColors.cardBorder),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          customerName,
                          style: getTextStyle(
                            fontSize: 16.4,
                            fontWeight: FontWeight.w500,
                            color: AppColors.chipInactiveText,
                          ),
                        ),
                      ),
                      Icon(
                        Iconsax.arrow_down,
                        size: 22.sp,
                        color: AppColors.chipInactiveText,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              GestureDetector(
                onTap: onAddCustomer,
                child: Container(
                  width: 55.w,
                  height: 55.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    gradient: const LinearGradient(
                      colors: [AppColors.gradientStart, AppColors.gradientEnd],
                    ),
                  ),
                  child: Icon(Iconsax.user_add, color: Colors.white, size: 26.sp),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
