import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/common/styles/global_text_style.dart';
import '../../../core/utils/constants/colors.dart';
import '../../../core/utils/helpers/app_helper.dart';

class CashDrawerCard extends StatelessWidget {
  final double startingCash;
  final double cashPayments;
  final double cashRefunds;
  final double paidIn;
  final double paidOut;
  final double expectedCashAmount;
  final double? actualCashAmount;
  final double? difference;

  const CashDrawerCard({
    super.key,
    required this.startingCash,
    required this.cashPayments,
    required this.cashRefunds,
    required this.paidIn,
    required this.paidOut,
    required this.expectedCashAmount,
    this.actualCashAmount,
    this.difference,
  });

  @override
  Widget build(BuildContext context) {
    final bool closed = actualCashAmount != null;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.billCardStart,
            AppColors.onboardingBackground,
            AppColors.billCardStart,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cash drawer',
            style: getTextStyle(
              fontSize: 16.4,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 12.h),
          _Row(label: 'Starting cash', value: startingCash),
          SizedBox(height: 4.h),
          _Row(label: 'Cash payments', value: cashPayments),
          SizedBox(height: 4.h),
          _Row(label: 'Cash refunds', value: cashRefunds),
          SizedBox(height: 4.h),
          _Row(label: 'Paid in', value: paidIn),
          SizedBox(height: 4.h),
          _Row(label: 'paid out', value: paidOut),
          SizedBox(height: 16.h),
          _Row(
            label: 'Expected cash amount',
            value: expectedCashAmount,
            emphasize: !closed,
          ),
          if (closed) ...[
            SizedBox(height: 4.h),
            _Row(label: 'Actual cash amount', value: actualCashAmount!),
            SizedBox(height: 4.h),
            _Row(label: 'Difference', value: difference ?? 0, emphasize: true),
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final double value;
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
          AppHelperFunctions.getFormattedMoney(value),
          style: getTextStyle(
            fontSize: 14.6,
            fontWeight: emphasize ? FontWeight.w500 : FontWeight.w400,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
