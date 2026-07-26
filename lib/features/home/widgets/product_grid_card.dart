import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/common/styles/global_text_style.dart';
import '../../../core/common/widgets/primary_button.dart';
import '../../../core/common/widgets/product_image.dart';
import '../../../core/utils/constants/colors.dart';
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
    return Container(
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
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: AppColors.stockBadgeBackground,
              borderRadius: BorderRadius.circular(18.r),
            ),
            child: Text(
              '${product.stockCount} In Stock',
              style: getTextStyle(
                fontSize: 11,
                color: AppColors.stockBadgeText,
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '\$${product.price.toStringAsFixed(0)}',
            style: getTextStyle(
              fontSize: 14.6,
              fontWeight: FontWeight.w500,
              color: AppColors.onboardingBackground,
            ),
          ),
          const Spacer(),
          PrimaryButton(
            label: 'Add',
            onPressed: onAdd,
            icon: Iconsax.shopping_cart,
            iconSize: 16,
            height: 30,
            fontSize: 14.6,
            textColor: Colors.white,
            gradient: const LinearGradient(
              colors: [AppColors.gradientStart, AppColors.gradientEnd],
            ),
            borderRadius: 999,
          ),
        ],
      ),
    );
  }
}
