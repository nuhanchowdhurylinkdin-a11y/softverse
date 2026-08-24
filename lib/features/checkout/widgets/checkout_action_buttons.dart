import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/common/styles/global_text_style.dart';
import '../../../core/common/widgets/primary_button.dart';
import '../../../core/utils/constants/colors.dart';

class CheckoutActionButtons extends StatelessWidget {
  final VoidCallback onSendToTable;
  final VoidCallback onSaveOrder;
  final VoidCallback onClearOrder;
  final bool showSaveOrder;
  final bool showSendToTable;

  const CheckoutActionButtons({
    super.key,
    required this.onSendToTable,
    required this.onSaveOrder,
    required this.onClearOrder,
    this.showSaveOrder = true,
    this.showSendToTable = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showSendToTable) ...[
          GestureDetector(
            onTap: onSendToTable,
            child: Container(
              height: 48.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                gradient: const LinearGradient(
                  colors: [AppColors.gradientStart, AppColors.gradientEnd],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Send to Table',
                    style: getTextStyle(
                      fontSize: 16.4,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  Icon(Iconsax.arrow_down, size: 22.sp, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
        if (showSaveOrder) ...[
          SizedBox(height: 15.h),
          PrimaryButton(
            label: 'Save Order',
            onPressed: onSaveOrder,
            backgroundColor: Colors.white,
            textColor: AppColors.onboardingBackground,
            borderColor: AppColors.onboardingBackground,
            height: 48,
            fontSize: 16.4,
          ),
        ],
        SizedBox(height: 15.h),
        PrimaryButton(
          label: 'Clear Order',
          onPressed: onClearOrder,
          backgroundColor: Colors.white,
          textColor: AppColors.dangerRed,
          borderColor: AppColors.dangerRed,
          height: 48,
          fontSize: 16.4,
        ),
      ],
    );
  }
}
