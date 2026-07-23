import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/common/styles/global_text_style.dart';
import '../../../core/utils/constants/colors.dart';
import '../../../core/utils/helpers/app_helper.dart';

class SalesSummaryCard extends StatelessWidget {
  final double grossSales;
  final double refunds;
  final double discounts;
  final double netSales;
  final double taxes;
  final double totalTendered;
  final double cash;
  final double? card;
  final double? duePayment;
  final double? installment;

  const SalesSummaryCard({
    super.key,
    required this.grossSales,
    required this.refunds,
    required this.discounts,
    required this.netSales,
    required this.taxes,
    required this.totalTendered,
    required this.cash,
    this.card,
    this.duePayment,
    this.installment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sales summary',
            style: getTextStyle(
              fontSize: 14.6,
              fontWeight: FontWeight.w500,
              color: AppColors.onboardingBackground,
            ),
          ),
          SizedBox(height: 12.h),
          _Row(label: 'Gross sales', value: grossSales, emphasizeLabel: true),
          SizedBox(height: 4.h),
          _Row(label: 'Refunds', value: refunds),
          SizedBox(height: 4.h),
          _Row(label: 'Discounts', value: discounts),
          SizedBox(height: 4.h),
          _Row(label: 'Net sales', value: netSales, emphasizeLabel: true),
          SizedBox(height: 4.h),
          _Row(label: 'Taxes', value: taxes),
          SizedBox(height: 12.h),
          _Row(
            label: 'Total tendered',
            value: totalTendered,
            emphasizeLabel: true,
            blueLabel: true,
          ),
          SizedBox(height: 4.h),
          _Row(label: 'Cash', value: cash),
          if (card != null) ...[
            SizedBox(height: 4.h),
            _Row(label: 'Card', value: card!),
          ],
          if (duePayment != null) ...[
            SizedBox(height: 4.h),
            _Row(label: 'Due Payment', value: duePayment!),
          ],
          if (installment != null) ...[
            SizedBox(height: 4.h),
            _Row(label: 'Installment', value: installment!),
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final double value;
  final bool emphasizeLabel;
  final bool blueLabel;

  const _Row({
    required this.label,
    required this.value,
    this.emphasizeLabel = false,
    this.blueLabel = false,
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
            fontWeight: emphasizeLabel ? FontWeight.w500 : FontWeight.w400,
            color: blueLabel
                ? AppColors.onboardingBackground
                : emphasizeLabel
                ? AppColors.authTextDark
                : AppColors.chipInactiveText,
          ),
        ),
        Text(
          AppHelperFunctions.getFormattedMoney(value),
          style: getTextStyle(
            fontSize: 14.6,
            fontWeight: emphasizeLabel ? FontWeight.w500 : FontWeight.w400,
            color: AppColors.onboardingBackground,
          ),
        ),
      ],
    );
  }
}
