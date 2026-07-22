import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/common/styles/global_text_style.dart';
import '../../../core/common/widgets/primary_button.dart';
import '../../../core/utils/constants/colors.dart';

class OrderSummaryCard extends StatelessWidget {
  final String orderId;
  final int itemCount;
  final double total;
  final VoidCallback onCheckout;

  const OrderSummaryCard({
    super.key,
    required this.orderId,
    required this.itemCount,
    required this.total,
    required this.onCheckout,
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
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
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
                  orderId,
                  style: getTextStyle(
                    fontSize: 16.4,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  'Item : $itemCount',
                  style: getTextStyle(
                    fontSize: 12.8,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$ ${total.toStringAsFixed(0)}',
                style: getTextStyle(
                  fontSize: 21.9,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 12.h),
              PrimaryButton(
                label: 'Checkout',
                onPressed: onCheckout,
                icon: Iconsax.add_circle,
                iconSize: 18,
                width: 133.w,
                height: 37,
                fontSize: 16.4,
                textColor: AppColors.authTextDark,
                gradient: const LinearGradient(
                  colors: [
                    AppColors.checkoutGoldStart,
                    AppColors.checkoutGoldMid,
                    AppColors.checkoutGoldLight,
                    AppColors.checkoutGoldMid,
                    AppColors.checkoutGoldEnd,
                  ],
                ),
                borderRadius: 999,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
