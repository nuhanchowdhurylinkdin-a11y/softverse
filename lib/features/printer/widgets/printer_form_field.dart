import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/common/styles/global_text_style.dart';
import '../../../core/common/widgets/app_text_field.dart';
import '../../../core/utils/constants/colors.dart';

class PrinterFormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hintText;

  const PrinterFormField({
    super.key,
    required this.label,
    required this.controller,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: getTextStyle(
            fontSize: 16.4,
            fontWeight: FontWeight.w500,
            color: AppColors.onboardingBackground,
          ),
        ),
        SizedBox(height: 8.h),
        AppTextField(
          controller: controller,
          hintText: hintText,
          backgroundColor: AppColors.chipBackground,
          borderStyle: AppTextFieldBorder.outline,
          borderColor: AppColors.cardBorder,
          hintColor: AppColors.chipInactiveText,
          textColor: AppColors.chipInactiveText,
          fontSize: 16.4,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        ),
      ],
    );
  }
}
