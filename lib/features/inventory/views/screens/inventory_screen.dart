import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/common/styles/global_text_style.dart';
import '../../../../core/common/widgets/app_nav_drawer.dart';
import '../../../../core/common/widgets/floating_icon_button.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../../home/widgets/category_tabs.dart';
import '../../controller/inventory_controller.dart';
import '../../widgets/inventory_product_row.dart';

class InventoryScreen extends GetView<InventoryController> {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const AppNavDrawer(),
      appBar: AppBar(
        centerTitle: false,
        toolbarHeight: 58.h,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
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
          'Inventory',
          style: getTextStyle(
            fontSize: 21.9,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        actions: [
          Icon(Iconsax.notification, color: Colors.white, size: 26.sp),
          SizedBox(width: 16.w),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(height: 16.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Obx(
                    () => CategoryTabs(
                      categories: controller.categories,
                      selectedIndex: controller.selectedCategoryIndex.value,
                      onSelected: controller.selectCategory,
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: controller.products
                          .map(
                            (product) => Padding(
                              padding: EdgeInsets.only(bottom: 10.h),
                              child: InventoryProductRow(
                                product: product,
                                onTap: () => controller.openProduct(product),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              right: 16.w,
              bottom: 16.h,
              child: Column(
                children: [
                  FloatingIconButton(
                    icon: Iconsax.search_normal,
                    backgroundColor: AppColors.chipBackground,
                    iconColor: AppColors.onboardingBackground,
                    onTap: controller.openSearch,
                  ),
                  SizedBox(height: 15.h),
                  FloatingIconButton(
                    icon: Iconsax.scan,
                    backgroundColor: AppColors.onboardingBackground,
                    iconColor: Colors.white,
                    onTap: controller.openScan,
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
