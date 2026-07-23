import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/common/styles/global_text_style.dart';
import '../../../../core/common/widgets/app_text_field.dart';
import '../../../../core/common/widgets/primary_button.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../controller/cash_management_controller.dart';
import '../../widgets/shift_header.dart';

class CashManagementScreen extends GetView<CashManagementController> {
  const CashManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const ShiftHeader(title: 'CASH MANAGEMENT'),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _FieldLabel('Amount'),
                    SizedBox(height: 8.h),
                    AppTextField(
                      controller: controller.amountController,
                      hintText: '0.00',
                      keyboardType: TextInputType.number,
                      backgroundColor: AppColors.chipBackground,
                      borderStyle: AppTextFieldBorder.outline,
                      borderColor: AppColors.cardBorder,
                      hintColor: AppColors.chipInactiveText,
                      textColor: AppColors.authTextDark,
                      fontSize: 16.4,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 16.h,
                      ),
                    ),
                    SizedBox(height: 32.h),
                    _FieldLabel('Note'),
                    SizedBox(height: 8.h),
                    AppTextField(
                      controller: controller.noteController,
                      maxLines: 5,
                      backgroundColor: AppColors.chipBackground,
                      borderStyle: AppTextFieldBorder.outline,
                      borderColor: AppColors.cardBorder,
                      textAlignVertical: TextAlignVertical.top,
                      contentPadding: EdgeInsets.all(16.w),
                    ),
                    SizedBox(height: 64.h),
                    Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            label: 'PAY IN',
                            onPressed: controller.payIn,
                            backgroundColor: Colors.white,
                            textColor: AppColors.onboardingBackground,
                            borderColor: AppColors.onboardingBackground,
                            height: 60,
                            fontSize: 16.4,
                            letterSpacing: 0.16,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: PrimaryButton(
                            label: 'PAY OUT',
                            onPressed: controller.payOut,
                            backgroundColor: Colors.white,
                            textColor: AppColors.dangerRed,
                            borderColor: AppColors.dangerRed,
                            height: 60,
                            fontSize: 16.4,
                            letterSpacing: 0.16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: getTextStyle(
        fontSize: 16.4,
        fontWeight: FontWeight.w500,
        color: AppColors.onboardingBackground,
      ),
    );
  }
}
