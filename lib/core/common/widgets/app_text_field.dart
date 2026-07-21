import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/constants/colors.dart';
import '../styles/global_text_style.dart';

enum AppTextFieldBorder { underline, outline, none }

class AppTextField extends StatelessWidget {
  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Color? backgroundColor;
  final AppTextFieldBorder borderStyle;
  final double borderRadius;
  final Color borderColor;
  final Color labelColor;
  final Color textColor;
  final Color hintColor;
  final double fontSize;
  final EdgeInsetsGeometry? contentPadding;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;

  const AppTextField({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.backgroundColor,
    this.borderStyle = AppTextFieldBorder.underline,
    this.borderRadius = 12,
    this.borderColor = AppColors.fieldDivider,
    this.labelColor = AppColors.authTextDark,
    this.textColor = AppColors.authTextDark,
    this.hintColor = AppColors.textSecondary,
    this.fontSize = 16,
    this.contentPadding,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final InputBorder border = switch (borderStyle) {
      AppTextFieldBorder.outline => OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius.r),
          borderSide: BorderSide(color: borderColor),
        ),
      AppTextFieldBorder.underline =>
        UnderlineInputBorder(borderSide: BorderSide(color: borderColor)),
      AppTextFieldBorder.none => OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius.r),
          borderSide: BorderSide.none,
        ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: getTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: labelColor,
            ),
          ),
          SizedBox(height: 8.h),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          style: getTextStyle(fontSize: fontSize, color: textColor),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: getTextStyle(fontSize: fontSize, color: hintColor),
            filled: backgroundColor != null,
            fillColor: backgroundColor,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            isDense: true,
            contentPadding: contentPadding ?? EdgeInsets.symmetric(vertical: 8.h),
            border: border,
            enabledBorder: border,
            focusedBorder: border,
          ),
        ),
      ],
    );
  }
}
