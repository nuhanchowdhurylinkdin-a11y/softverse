import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/common/widgets/floating_icon_button.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../../home/widgets/category_tabs.dart';
import '../../../home/widgets/pos_app_bar.dart';
import '../../controller/inventory_controller.dart';
import '../../widgets/inventory_product_row.dart';

class InventoryScreen extends GetView<InventoryController> {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                PosAppBar(title: 'Inventory', showClock: false),
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
