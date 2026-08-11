import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/common/styles/global_text_style.dart';
import '../../../../core/common/widgets/floating_icon_button.dart';
import '../../../../core/common/widgets/product_image.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../../home/widgets/category_tabs.dart';
import '../../controller/apply_tax_items_controller.dart';
import '../../widgets/checkbox_square.dart';

class ApplyTaxItemsScreen extends GetView<ApplyTaxItemsController> {
  const ApplyTaxItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: false,
        toolbarHeight: 55.h,
        leading: IconButton(
          onPressed: Get.back,
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 22.sp),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [AppColors.posHeaderStart, AppColors.posHeaderEnd],
            ),
          ),
        ),
        title: Text(
          'Apply tax to item',
          style: getTextStyle(
            fontSize: 16.4,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Obx(
                () => CategoryTabs(
                  categories: controller.categories,
                  selectedIndex: controller.selectedCategoryIndex.value,
                  onSelected: controller.selectCategory,
                ),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final items = controller.visibleItems;
                    if (items.isEmpty) {
                      return Center(
                        child: Text(
                          'No items found.',
                          style: getTextStyle(
                            fontSize: 16.4,
                            color: AppColors.onboardingBackground,
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return GestureDetector(
                          onTap: () => controller.toggleItem(item.id),
                          child: Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white,
                                  AppColors.rowGradientEnd,
                                ],
                              ),
                              border: Border.all(color: AppColors.cardBorder),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              children: [
                                ProductImage(imageUrl: item.imageUrl, size: 60),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: getTextStyle(
                                          fontSize: 14.6,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.authTextDark,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        item.sku,
                                        style: getTextStyle(
                                          fontSize: 12.8,
                                          color: AppColors.onboardingBackground,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Obx(
                                  () => CheckboxSquare(
                                    selected: controller.selectedIds.contains(
                                      item.id,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }),
                  Positioned(
                    right: 16.w,
                    bottom: 16.h,
                    child: Column(
                      children: [
                        FloatingIconButton(
                          icon: Iconsax.search_normal,
                          backgroundColor: AppColors.chipBackground,
                          iconColor: AppColors.onboardingBackground,
                          onTap: () {},
                        ),
                        SizedBox(height: 15.h),
                        FloatingIconButton(
                          icon: Iconsax.tick_circle,
                          backgroundColor: AppColors.onboardingBackground,
                          iconColor: Colors.white,
                          onTap: controller.confirm,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
