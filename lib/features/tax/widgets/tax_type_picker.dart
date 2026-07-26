import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/common/styles/global_text_style.dart';
import '../../../core/utils/constants/colors.dart';
import '../models/tax_model.dart';

Future<TaxType?> showTaxTypePicker({
  required BuildContext context,
  TaxType? selected,
}) {
  return showModalBottomSheet<TaxType>(
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
              'Tax type',
              style: getTextStyle(
                fontSize: 16.4,
                fontWeight: FontWeight.w500,
                color: AppColors.onboardingBackground,
              ),
            ),
            SizedBox(height: 8.h),
            for (final option in TaxType.values)
              ListTile(
                title: Text(
                  option.label,
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
