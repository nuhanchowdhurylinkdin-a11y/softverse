import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/common/styles/global_text_style.dart';
import '../../../../core/common/widgets/product_image.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../controller/item_detail_controller.dart';
import '../../widgets/barcode_graphic.dart';
import '../../widgets/date_field_row.dart';
import '../../widgets/item_detail_header.dart';
import '../../widgets/labeled_row.dart';
import '../../widgets/modifier_section.dart';
import '../../widgets/toggle_field_row.dart';

class ItemDetailScreen extends GetView<ItemDetailController> {
  const ItemDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            ItemDetailHeader(title: controller.product.name),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 16.h),
                    Center(
                      child: ProductImage(
                        imageUrl: controller.product.imageUrl,
                        size: 109,
                        borderRadius: 12,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      controller.product.name,
                      textAlign: TextAlign.center,
                      style: getTextStyle(
                        fontSize: 14.6,
                        fontWeight: FontWeight.w500,
                        color: AppColors.authTextDark,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      controller.product.sku,
                      textAlign: TextAlign.center,
                      style: getTextStyle(
                        fontSize: 12.8,
                        color: AppColors.onboardingBackground,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    LabeledRow(label: 'Sold by', value: controller.soldBy),
                    LabeledRow(
                      label: 'Price',
                      value: '\$${controller.product.price.toStringAsFixed(0)}',
                    ),
                    LabeledRow(
                      label: 'Cost',
                      value: '\$${controller.product.cost.toStringAsFixed(2)}',
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Barcode',
                                style: getTextStyle(
                                  fontSize: 16.4,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.onboardingBackground,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                controller.product.barcode,
                                style: getTextStyle(
                                  fontSize: 12.8,
                                  color: AppColors.authTextDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const BarcodeGraphic(),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    LabeledRow(
                      label: 'In Stock',
                      value: '${controller.product.inStock}',
                    ),
                    LabeledRow(
                      label: 'Low Stock',
                      value: '${controller.product.lowStockThreshold}',
                    ),
                    SizedBox(height: 16.h),
                    Obx(
                      () => ModifierSection(
                        group: controller.modifierGroup,
                        enabled: controller.modifierEnabled.value,
                        onEnabledChanged: (_) => controller.toggleModifier(),
                        selectedOptionIndex: controller.selectedModifierOptionIndex.value,
                        onOptionSelected: controller.selectModifierOption,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Expire Date',
                      style: getTextStyle(
                        fontSize: 16.4,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onboardingBackground,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Obx(
                      () => ToggleFieldRow(
                        label: 'Track Date',
                        value: controller.trackExpiryDate.value,
                        onChanged: (_) => controller.toggleTrackExpiryDate(),
                        boxed: true,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Manufacturing Date',
                      style: getTextStyle(
                        fontSize: 16.4,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onboardingBackground,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    DateFieldRow(value: controller.manufacturingDate),
                    SizedBox(height: 16.h),
                    Text(
                      'Expire Date',
                      style: getTextStyle(
                        fontSize: 16.4,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onboardingBackground,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    DateFieldRow(value: controller.expireDate),
                    SizedBox(height: 8.h),
                    Text(
                      'Quantity at which you will be notified about Expire Date',
                      style: getTextStyle(
                        fontSize: 12.8,
                        color: AppColors.chipInactiveText,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Obx(
                      () => ToggleFieldRow(
                        label: 'Activity',
                        value: controller.activityEnabled.value,
                        onChanged: (_) => controller.toggleActivity(),
                      ),
                    ),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
