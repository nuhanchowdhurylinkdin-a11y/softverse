import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/common/styles/global_text_style.dart';
import '../../../core/common/widgets/primary_button.dart';
import '../../../core/common/widgets/product_image.dart';
import '../../../core/utils/constants/colors.dart';
import '../models/product.dart';

class ProductRow extends StatelessWidget {
  final Product product;
  final VoidCallback onAdd;

  const ProductRow({super.key, required this.product, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  '\$${product.price.toStringAsFixed(0)}',
                  style: getTextStyle(
                    fontSize: 16.4,
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
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.stockBadgeBackground,
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Text(
                  '${product.stockCount} In Stock',
                  style: getTextStyle(
                    fontSize: 12.8,
                    color: AppColors.stockBadgeText,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              PrimaryButton(
                label: 'Add',
                onPressed: onAdd,
                icon: Iconsax.shopping_cart,
                iconSize: 18,
                width: 109.w,
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
    );
  }
}
