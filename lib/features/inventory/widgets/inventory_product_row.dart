import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/common/styles/global_text_style.dart';
import '../../../core/common/widgets/product_image.dart';
import '../../../core/utils/constants/colors.dart';
import '../models/inventory_product.dart';

class InventoryProductRow extends StatelessWidget {
  final InventoryProduct product;
  final VoidCallback onTap;

  const InventoryProductRow({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color badgeColor = product.isOutOfStock
        ? AppColors.dangerRed
        : product.isLowStock
        ? AppColors.checkoutGoldEnd
        : AppColors.stockBadgeText;
    final Color badgeBackground = product.isOutOfStock || product.isLowStock
        ? badgeColor.withValues(alpha: 0.2)
        : AppColors.stockBadgeBackground;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Colors.white, AppColors.rowGradientEnd],
          ),
        ),
        child: Row(
          children: [
            ProductImage(imageUrl: product.imageUrl),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: getTextStyle(
                      fontSize: 14.6,
                      fontWeight: FontWeight.w500,
                      color: AppColors.authTextDark,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    product.sku,
                    style: getTextStyle(
                      fontSize: 12.8,
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
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBackground,
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                  child: Text(
                    '${product.inStock} In Stock',
                    style: getTextStyle(fontSize: 12.8, color: badgeColor),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '\$${product.price.toStringAsFixed(0)}',
                  style: getTextStyle(
                    fontSize: 16.4,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onboardingBackground,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
