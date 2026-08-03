import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/common/styles/global_text_style.dart';
import '../../../core/utils/constants/colors.dart';
import '../../../core/utils/helpers/app_helper.dart';

class OrderSummaryBanner extends StatelessWidget {
  final String invoiceLabel;
  final int itemCount;
  final double price;

  const OrderSummaryBanner({
    super.key,
    required this.invoiceLabel,
    required this.itemCount,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.cardBorder),
        gradient: const LinearGradient(
          colors: [
            AppColors.billCardStart,
            AppColors.onboardingBackground,
            AppColors.billCardStart,
          ],
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
                  invoiceLabel,
                  style: getTextStyle(
                    fontSize: 16.4,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
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
          Text(
            '\$ ${AppHelperFunctions.getFormattedMoney(price)}',
            style: getTextStyle(
              fontSize: 21.9,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
