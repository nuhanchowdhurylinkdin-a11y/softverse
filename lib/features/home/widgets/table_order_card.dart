import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/common/styles/global_text_style.dart';
import '../../../core/common/widgets/primary_button.dart';
import '../../../core/utils/constants/colors.dart';
import '../models/table_order.dart';

class TableOrderCard extends StatelessWidget {
  final TableOrder tableOrder;
  final VoidCallback onOpenOrder;

  const TableOrderCard({
    super.key,
    required this.tableOrder,
    required this.onOpenOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tableOrder.tableName,
          style: getTextStyle(
            fontSize: 16.4,
            fontWeight: FontWeight.w500,
            color: AppColors.onboardingBackground,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Colors.white, AppColors.rowGradientEnd],
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tableOrder.orderId,
                      style: getTextStyle(
                        fontSize: 10.9,
                        color: AppColors.authTextDark,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      tableOrder.customerName,
                      style: getTextStyle(
                        fontSize: 14.6,
                        fontWeight: FontWeight.w500,
                        color: AppColors.authTextDark,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      tableOrder.time,
                      style: getTextStyle(
                        fontSize: 12.8,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onboardingBackground,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18.r),
                      gradient: LinearGradient(
                        colors: tableOrder.status.gradient
                            .map((c) => c.withValues(alpha: 0.2))
                            .toList(),
                      ),
                    ),
                    child: Text(
                      tableOrder.status.label,
                      style: getTextStyle(
                        fontSize: 12.8,
                        color: tableOrder.status.textColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  PrimaryButton(
                    label: 'Open Order',
                    onPressed: onOpenOrder,
                    icon: Iconsax.shopping_cart,
                    iconSize: 18,
                    width: 126.w,
                    height: 37,
                    fontSize: 16.4,
                    textColor: Colors.white,
                    gradient: const LinearGradient(
                      colors: [AppColors.gradientStart, AppColors.gradientEnd],
                    ),
                    borderRadius: 999,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
