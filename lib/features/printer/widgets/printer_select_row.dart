import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/common/styles/global_text_style.dart';
import '../../../core/utils/constants/colors.dart';

class PrinterSelectRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  final bool boxed;

  const PrinterSelectRow({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.boxed = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: getTextStyle(
              fontSize: 16.4,
              fontWeight: FontWeight.w500,
              color: boxed
                  ? AppColors.chipInactiveText
                  : AppColors.onboardingBackground,
            ),
          ),
          Row(
            children: [
              Text(
                value,
                style: getTextStyle(
                  fontSize: 14.6,
                  color: AppColors.onboardingBackground,
                ),
              ),
              SizedBox(width: 4.w),
              Icon(
                Iconsax.arrow_down_1,
                size: 22.sp,
                color: AppColors.onboardingBackground,
              ),
            ],
          ),
        ],
      ),
    );

    if (!boxed) return content;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: content,
    );
  }
}

Future<String?> showPrinterOptionPicker({
  required BuildContext context,
  required String title,
  required List<String> options,
  required String selected,
}) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
    ),
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 12.h),
            Text(
              title,
              style: getTextStyle(
                fontSize: 16.4,
                fontWeight: FontWeight.w500,
                color: AppColors.onboardingBackground,
              ),
            ),
            SizedBox(height: 8.h),
            for (final option in options)
              ListTile(
                title: Text(
                  option,
                  style: getTextStyle(
                    fontSize: 14.6,
                    color: option == selected
                        ? AppColors.onboardingBackground
                        : AppColors.authTextDark,
                    fontWeight: option == selected
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
                trailing: option == selected
                    ? Icon(
                        Icons.check,
                        color: AppColors.onboardingBackground,
                        size: 20.sp,
                      )
                    : null,
                onTap: () => Navigator.of(context).pop(option),
              ),
            SizedBox(height: 8.h),
          ],
        ),
      );
    },
  );
}
