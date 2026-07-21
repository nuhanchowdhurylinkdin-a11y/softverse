import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/constants/colors.dart';

class StepProgressIndicator extends StatelessWidget {
  final int stepCount;
  final int activeIndex;
  final double stepWidth;
  final double stepHeight;
  final double gap;
  final Color activeColor;
  final Color inactiveColor;

  const StepProgressIndicator({
    super.key,
    required this.stepCount,
    required this.activeIndex,
    this.stepWidth = 29,
    this.stepHeight = 4,
    this.gap = 11,
    this.activeColor = AppColors.authTextDark,
    this.inactiveColor = AppColors.fieldBackground,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(stepCount, (index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: gap.w / 2),
          child: Container(
            width: stepWidth.w,
            height: stepHeight.h,
            decoration: BoxDecoration(
              color: index == activeIndex ? activeColor : inactiveColor,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        );
      }),
    );
  }
}
