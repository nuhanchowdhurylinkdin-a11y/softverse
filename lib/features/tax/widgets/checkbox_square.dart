import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/utils/constants/colors.dart';

class CheckboxSquare extends StatelessWidget {
  final bool selected;

  const CheckboxSquare({super.key, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20.w,
      height: 20.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(
          color: selected ? AppColors.authLink : AppColors.checkboxBorder,
        ),
        gradient: selected
            ? const LinearGradient(
                colors: [
                  AppColors.checkboxGradientStart,
                  AppColors.checkboxGradientEnd,
                ],
              )
            : null,
      ),
      child: selected
          ? Icon(Icons.check, size: 14.sp, color: Colors.white)
          : null,
    );
  }
}
