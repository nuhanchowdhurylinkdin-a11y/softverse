import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/common/styles/global_text_style.dart';
import '../../../../core/common/widgets/dashed_divider.dart';
import '../../../../core/common/widgets/primary_button.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../../../core/utils/helpers/app_helper.dart';
import '../../controller/close_shift_controller.dart';
import '../../widgets/shift_header.dart';

class CloseShiftScreen extends GetView<CloseShiftController> {
  const CloseShiftScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const ShiftHeader(title: 'Close shift'),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.billCardStart,
                            AppColors.billCardMid1,
                            AppColors.billCardMid2,
                            AppColors.billCardEnd,
                          ],
                        ),
                      ),
                      child: Column(
                        children: [
                          _Row(
                            label: 'Expected cash amount',
                            value:
                                '\$${AppHelperFunctions.getFormattedMoney(controller.shift.expectedCashAmount)}',
                          ),
                          SizedBox(height: 6.h),
                          const DashedDivider(),
                          SizedBox(height: 6.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Actual cash amount',
                                style: getTextStyle(
                                  fontSize: 14.6,
                                  color: Colors.white,
                                ),
                              ),
                              Container(
                                height: 36.h,
                                padding: EdgeInsets.symmetric(horizontal: 12.w),
                                alignment: Alignment.center,
                                color: Colors.white,
                                child: Text(
                                  '\$${AppHelperFunctions.getFormattedMoney(controller.shift.expectedCashAmount)}',
                                  style: getTextStyle(
                                    fontSize: 14.6,
                                    color: AppColors.authTextDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6.h),
                          const DashedDivider(),
                          SizedBox(height: 6.h),
                          _Row(
                            label: 'Difference',
                            value:
                                '\$${AppHelperFunctions.getFormattedMoney(controller.difference)}',
                            emphasize: true,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 40.h),
                    Center(
                      child: PrimaryButton(
                        label: 'CLOSE SHIFT',
                        onPressed: controller.closeShift,
                        backgroundColor: AppColors.dangerRed,
                        textColor: Colors.white,
                        width: 190.w,
                        height: 60,
                        fontSize: 16.4,
                        letterSpacing: 0.16,
                      ),
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

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasize;

  const _Row({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: getTextStyle(
            fontSize: 14.6,
            fontWeight: emphasize ? FontWeight.w500 : FontWeight.w400,
            color: Colors.white,
          ),
        ),
        Text(
          value,
          style: getTextStyle(
            fontSize: emphasize ? 16.4 : 14.6,
            fontWeight: emphasize ? FontWeight.w500 : FontWeight.w400,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
