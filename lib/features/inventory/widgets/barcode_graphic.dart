import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/utils/constants/colors.dart';

class BarcodeGraphic extends StatelessWidget {
  const BarcodeGraphic({super.key});

  static const _widths = [2, 1, 3, 1, 1, 3, 1, 2, 1, 1, 1];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84.w,
      height: 50.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(4.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _widths
            .map(
              (w) => Container(
                width: w.toDouble().w,
                height: 36.h,
                color: AppColors.authTextDark,
              ),
            )
            .toList(),
      ),
    );
  }
}
