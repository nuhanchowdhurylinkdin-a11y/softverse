import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/common/styles/global_text_style.dart';
import '../../../core/utils/constants/colors.dart';
import '../models/payment_method.dart';

class PaymentMethodGrid extends StatelessWidget {
  final List<PaymentMethod> methods;
  final ValueChanged<PaymentMethod> onSelected;

  const PaymentMethodGrid({
    super.key,
    required this.methods,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < methods.length; i += 2) {
      final rowMethods = methods.skip(i).take(2).toList();
      if (i > 0) rows.add(SizedBox(height: 22.h));
      rows.add(
        Row(
          children: [
            Expanded(child: _buildTile(rowMethods[0])),
            if (rowMethods.length > 1) ...[
              SizedBox(width: 22.w),
              Expanded(child: _buildTile(rowMethods[1])),
            ],
          ],
        ),
      );
    }
    return Column(children: rows);
  }

  Widget _buildTile(PaymentMethod method) {
    return GestureDetector(
      onTap: () => onSelected(method),
      child: Container(
        height: 67.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.cardBorder),
          borderRadius: BorderRadius.circular(12.r),
          gradient: LinearGradient(
            colors: [method.gradientStart, method.gradientEnd],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              method.label,
              style: getTextStyle(
                fontSize: 16.4,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            Icon(method.icon, color: Colors.white, size: 22.sp),
          ],
        ),
      ),
    );
  }
}
