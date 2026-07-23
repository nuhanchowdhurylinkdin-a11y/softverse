import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/constants/colors.dart';

class RadioCircle extends StatelessWidget {
  final bool selected;

  const RadioCircle({super.key, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18.w,
      height: 18.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.authLink : AppColors.chipInactiveText,
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
          ? Center(
              child: Container(
                width: 7.w,
                height: 7.w,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}
