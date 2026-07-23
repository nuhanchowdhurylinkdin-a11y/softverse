import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/common/styles/global_text_style.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../controller/items_menu_controller.dart';
import '../../widgets/item_menu_tile.dart';

class ItemsMenuScreen extends GetView<ItemsMenuController> {
  const ItemsMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 58.h,
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [AppColors.posHeaderStart, AppColors.posHeaderEnd],
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: Get.back,
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 22.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Items',
                    style: getTextStyle(
                      fontSize: 21.9,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ItemMenuTile(
                      icon: Iconsax.task_square,
                      label: 'Create Items',
                      onTap: controller.openCreateItems,
                    ),
                    SizedBox(height: 8.h),
                    ItemMenuTile(
                      icon: Iconsax.category,
                      label: 'Category',
                      onTap: controller.openCategory,
                    ),
                    SizedBox(height: 8.h),
                    ItemMenuTile(
                      icon: Iconsax.edit_2,
                      label: 'Modifiers',
                      onTap: controller.openModifiers,
                    ),
                    SizedBox(height: 8.h),
                    ItemMenuTile(
                      icon: Iconsax.tag,
                      label: 'Discounts',
                      onTap: controller.openDiscounts,
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: AppColors.chipBackground,
                        border: Border.all(color: AppColors.cardBorder),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Extended item settings are available in the Back Office',
                            style: getTextStyle(
                              fontSize: 16.4,
                              fontWeight: FontWeight.w500,
                              color: AppColors.chipInactiveText,
                            ),
                          ),
                          SizedBox(height: 18.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: controller.goToBackOffice,
                                child: Text(
                                  'GO TO BACK OFFICE',
                                  style: getTextStyle(
                                    fontSize: 16.4,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.onboardingBackground,
                                  ).copyWith(letterSpacing: 0.16),
                                ),
                              ),
                              SizedBox(width: 24.w),
                              GestureDetector(
                                onTap: controller.dismissHint,
                                child: Text(
                                  'GOT IT',
                                  style: getTextStyle(
                                    fontSize: 16.4,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.onboardingBackground,
                                  ).copyWith(letterSpacing: 0.16),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
