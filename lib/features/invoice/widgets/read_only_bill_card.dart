import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/common/styles/global_text_style.dart';
import '../../../core/common/widgets/dashed_divider.dart';
import '../../../core/utils/constants/colors.dart';

class ReadOnlyBillCard extends StatelessWidget {
  final double subtotal;
  final double tax;
  final double taxRate;
  final double totalAmount;
  final double amountReceived;
  final double changeToReturn;

  const ReadOnlyBillCard({
    super.key,
    required this.subtotal,
    required this.tax,
    required this.taxRate,
    required this.totalAmount,
    required this.amountReceived,
    required this.changeToReturn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
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
          _Row(label: 'Subtotal', value: '\$${subtotal.toStringAsFixed(2)}'),
          SizedBox(height: 8.h),
          _Row(
            label: 'TAX (${(taxRate * 100).toStringAsFixed(1)}%)',
            value: '\$${tax.toStringAsFixed(2)}',
          ),
          SizedBox(height: 12.h),
          const DashedDivider(),
          SizedBox(height: 12.h),
          _Row(
            label: 'Total Amount',
            value: '\$${totalAmount.toStringAsFixed(2)}',
            emphasize: true,
          ),
          SizedBox(height: 8.h),
          _Row(
            label: 'Amount Received',
            value: '\$${amountReceived.toStringAsFixed(2)}',
          ),
          SizedBox(height: 12.h),
          const DashedDivider(),
          SizedBox(height: 12.h),
          _Row(
            label: 'Change to Return',
            value: '\$${changeToReturn.toStringAsFixed(2)}',
            emphasize: true,
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasize;

  const _Row({required this.label, required this.value, this.emphasize = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: getTextStyle(fontSize: 14.6, color: Colors.white)),
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
