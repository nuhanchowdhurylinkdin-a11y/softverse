import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/common/styles/global_text_style.dart';
import '../../transaction/models/transaction_record.dart';

class PaymentTypeBadge extends StatelessWidget {
  final PaymentType paymentType;

  const PaymentTypeBadge({super.key, required this.paymentType});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        gradient: LinearGradient(
          colors: paymentType.gradient.map((c) => c.withValues(alpha: 0.2)).toList(),
        ),
      ),
      child: Text(
        paymentType.label,
        style: getTextStyle(fontSize: 12.8, color: paymentType.textColor),
      ),
    );
  }
}
