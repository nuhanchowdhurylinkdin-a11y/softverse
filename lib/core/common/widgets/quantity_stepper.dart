import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../utils/constants/colors.dart';
import '../styles/global_text_style.dart';

class QuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final double width;
  final double height;

  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    this.width = 109,
    this.height = 37,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width.w,
      height: height.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999.r),
        gradient: const LinearGradient(
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onIncrement,
            child: Icon(Iconsax.add, size: 18.sp, color: Colors.white),
          ),
          Text(
            '$quantity',
            style: getTextStyle(
              fontSize: 16.4,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          GestureDetector(
            onTap: onDecrement,
            child: Icon(Iconsax.minus, size: 18.sp, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
