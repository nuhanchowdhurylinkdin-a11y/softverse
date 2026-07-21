import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../styles/global_text_style.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Gradient? gradient;
  final Color textColor;
  final Color? borderColor;
  final double borderWidth;
  final double height;
  final double? width;
  final double borderRadius;
  final double fontSize;
  final FontWeight fontWeight;
  final double letterSpacing;
  final bool isLoading;
  final String loadingLabel;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor = Colors.white,
    this.gradient,
    this.textColor = Colors.black,
    this.borderColor,
    this.borderWidth = 1,
    this.height = 56,
    this.width,
    this.borderRadius = 12,
    this.fontSize = 18,
    this.fontWeight = FontWeight.w500,
    this.letterSpacing = 0,
    this.isLoading = false,
    this.loadingLabel = 'Submitting...',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height.h,
      child: Material(
        color: gradient == null ? backgroundColor : null,
        borderRadius: BorderRadius.circular(borderRadius.r),
        child: Ink(
          decoration: gradient != null
              ? BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(borderRadius.r),
                )
              : null,
          child: InkWell(
            borderRadius: BorderRadius.circular(borderRadius.r),
            onTap: isLoading ? null : onPressed,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius.r),
                border: borderColor != null
                    ? Border.all(color: borderColor!, width: borderWidth)
                    : null,
              ),
              alignment: Alignment.center,
              child: isLoading
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: fontSize.sp,
                          height: fontSize.sp,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: textColor,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          loadingLabel,
                          style: getTextStyle(
                            fontSize: fontSize,
                            fontWeight: fontWeight,
                            color: textColor,
                          ).copyWith(letterSpacing: letterSpacing),
                        ),
                      ],
                    )
                  : Text(
                      label,
                      style: getTextStyle(
                        fontSize: fontSize,
                        fontWeight: fontWeight,
                        color: textColor,
                      ).copyWith(letterSpacing: letterSpacing),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
