import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/common/styles/global_text_style.dart';
import '../../../core/common/widgets/app_text_field.dart';
import '../../../core/utils/constants/colors.dart';

class CreateItemField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hintText;
  final String? helperText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;

  const CreateItemField({
    super.key,
    required this.label,
    required this.controller,
    this.hintText,
    this.helperText,
    this.keyboardType,
    this.suffixIcon,
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
          keyboardType: keyboardType,
          backgroundColor: AppColors.chipBackground,
          borderStyle: AppTextFieldBorder.outline,
          borderColor: AppColors.cardBorder,
          hintColor: AppColors.chipInactiveText,
          textColor: AppColors.chipInactiveText,
          fontSize: 16.4,
          suffixIcon: suffixIcon,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 16.h,
          ),
        ),
        if (helperText != null) ...[
          SizedBox(height: 8.h),
          Text(
            helperText!,
            style: getTextStyle(
              fontSize: 12.8,
              color: AppColors.chipInactiveText,
            ),
          ),
        ],
      ],
    );
  }
}
