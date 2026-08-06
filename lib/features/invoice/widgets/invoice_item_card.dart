import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/common/styles/global_text_style.dart';
import '../../../core/common/widgets/product_image.dart';
import '../../../core/utils/constants/colors.dart';
import '../../../core/utils/helpers/app_helper.dart';
import '../../checkout/models/cart_item.dart';

class InvoiceItemCard extends StatelessWidget {
  final CartItem item;
  final bool selectable;
  final bool selected;
  final VoidCallback? onTap;

  const InvoiceItemCard({
    super.key,
    required this.item,
    this.selectable = false,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (selectable) ...[
              Padding(
                padding: EdgeInsets.only(top: 2.h, right: 12.w),
                child: _RadioCircle(selected: selected),
              ),
            ],
            ProductImage(imageUrl: item.imageUrl, size: 46),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Row(label: item.name, value: item.price),
                  if (item.bundle != null) ...[
                    SizedBox(height: 4.h),
                    _Row(label: item.bundle!.name, value: item.bundle!.price),
                    SizedBox(height: 4.h),
                    _Row(
                      label: item.bundle!.discountLabel,
                      value: item.bundle!.discountAmount,
                    ),
                    SizedBox(height: 4.h),
                    _Row(
                      label: 'Sub Total',
                      value: item.bundle!.subtotal,
                      emphasize: true,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RadioCircle extends StatelessWidget {
  final bool selected;

  const _RadioCircle({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18.w,
      height: 18.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.authLink : AppColors.chipInactiveText,
        ),
        gradient: selected
            ? const LinearGradient(
                colors: [
                  AppColors.checkboxGradientStart,
                  AppColors.checkboxGradientEnd,
                ],
              )
            : null,
      ),
      child: selected
          ? Center(
              child: Container(
                width: 7.w,
                height: 7.w,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final double value;
  final bool emphasize;

  const _Row({
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
