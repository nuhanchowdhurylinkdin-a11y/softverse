import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/common/styles/global_text_style.dart';
import '../../../core/utils/constants/colors.dart';

class LabeledRow extends StatelessWidget {
  final String label;
  final String value;

  const LabeledRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: getTextStyle(
              fontSize: 16.4,
              fontWeight: FontWeight.w500,
              color: AppColors.onboardingBackground,
            ),
          ),
          Text(
            value,
            style: getTextStyle(
              fontSize: 16.4,
              fontWeight: FontWeight.w500,
              color: AppColors.chipInactiveText,
            ),
          ),
        ],
      ),
    );
  }
}
