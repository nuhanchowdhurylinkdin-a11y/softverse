import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/common/styles/global_text_style.dart';
import '../../../core/common/widgets/product_image.dart';
import '../../../core/common/widgets/quantity_stepper.dart';
import '../../../core/utils/constants/colors.dart';
import '../../../core/utils/helpers/app_helper.dart';
import '../models/cart_item.dart';

class CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.cardBorder),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Colors.white, AppColors.rowGradientEnd],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProductImage(imageUrl: item.imageUrl),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: getTextStyle(
                        fontSize: 14.6,
                        fontWeight: FontWeight.w500,
                        color: AppColors.authTextDark,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    QuantityStepper(
                      quantity: item.quantity,
                      onIncrement: onIncrement,
                      onDecrement: onDecrement,
                    ),
                  ],
                ),
              ),
              Text(
                '\$${AppHelperFunctions.getFormattedMoney(item.price)}',
                style: getTextStyle(
                  fontSize: 14.6,
                  color: AppColors.onboardingBackground,
                ),
              ),
            ],
          ),
          if (item.bundle != null) ...[
            SizedBox(height: 16.h),
            _InfoRow(label: item.bundle!.name, value: item.bundle!.price),
            SizedBox(height: 4.h),
            _InfoRow(
              label: item.bundle!.discountLabel,
              value: item.bundle!.discountAmount,
            ),
            SizedBox(height: 4.h),
            _InfoRow(
              label: 'Sub Total',
              value: item.bundle!.subtotal,
              emphasize: true,
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final double value;
  final bool emphasize;

  const _InfoRow({
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
            fontWeight: FontWeight.w500,
            color: AppColors.authTextDark,
          ),
        ),
        Text(
          '\$${AppHelperFunctions.getFormattedMoney(value)}',
          style: getTextStyle(
            fontSize: emphasize ? 16.4 : 14.6,
            fontWeight: emphasize ? FontWeight.w500 : FontWeight.w400,
            color: AppColors.onboardingBackground,
          ),
        ),
      ],
    );
  }
}
