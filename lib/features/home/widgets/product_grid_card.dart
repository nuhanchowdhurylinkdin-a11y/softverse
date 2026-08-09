import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/common/styles/global_text_style.dart';
import '../../../core/common/widgets/product_image.dart';
import '../../../core/utils/constants/colors.dart';
import '../../../core/utils/helpers/app_helper.dart';
import '../models/product.dart';

class ProductGridCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAdd;

  const ProductGridCard({
    super.key,
    required this.product,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final badgeColor = product.isOutOfStock
        ? AppColors.dangerRed
        : product.isLowStock
        ? AppColors.checkoutGoldEnd
        : AppColors.stockBadgeText;
    final badgeBackground = product.isOutOfStock || product.isLowStock
        ? badgeColor.withValues(alpha: 0.18)
        : AppColors.stockBadgeBackground;

    return GestureDetector(
      onTap: onAdd,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, AppColors.rowGradientEnd],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: ProductImage(imageUrl: product.imageUrl, size: 44)),
            SizedBox(height: 4.h),
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: getTextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: AppColors.authTextDark,
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(height: 4.h),
            if (product.trackStock) ...[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: badgeBackground,
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (product.isOutOfStock || product.isLowStock) ...[
                      Icon(Iconsax.warning_2, size: 11.sp, color: badgeColor),
                      SizedBox(width: 3.w),
                    ],
                    Text(
                      product.stockLabel,
                      style: getTextStyle(fontSize: 11, color: badgeColor),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4.h),
            ],
            Text(
              '\$${AppHelperFunctions.getFormattedMoney(product.price)}',
              style: getTextStyle(
                fontSize: 14.6,
                fontWeight: FontWeight.w500,
                color: AppColors.onboardingBackground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
