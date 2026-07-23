import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/common/styles/global_text_style.dart';
import '../../../core/utils/constants/colors.dart';
import '../models/shift_record.dart';

class ShiftInfoCard extends StatelessWidget {
  final ShiftRecord shift;

  const ShiftInfoCard({super.key, required this.shift});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Row(label: 'Shift number:', value: shift.shiftNumber.toString()),
          SizedBox(height: 4.h),
          _Row(label: 'Shift opened by', value: shift.openedBy),
          SizedBox(height: 4.h),
          _Row(label: 'Start Date', value: shift.startDate),
          SizedBox(height: 4.h),
          _Row(label: 'Start Time', value: shift.startTime),
          if (shift.closeTime != null) ...[
            SizedBox(height: 4.h),
            _Row(label: 'Close Time', value: shift.closeTime!),
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;

  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 144.w,
          child: Text(
            label,
            style: getTextStyle(
              fontSize: 14.6,
              color: AppColors.chipInactiveText,
            ),
          ),
        ),
        Text(
          ': $value',
          style: getTextStyle(
            fontSize: 14.6,
            color: AppColors.onboardingBackground,
          ),
        ),
      ],
    );
  }
}
