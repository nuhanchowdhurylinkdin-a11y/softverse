import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/common/styles/global_text_style.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../controller/store_controller.dart';

class StoreSelectScreen extends GetView<StoreController> {
  const StoreSelectScreen({super.key});

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
          'Select store',
          style: getTextStyle(
            fontSize: 16.4,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Obx(() {
          if (controller.isLoading.value && controller.stores.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.stores.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Text(
                  'No active store is available for your account.',
                  textAlign: TextAlign.center,
                  style: getTextStyle(
                    fontSize: 14.4,
                    color: AppColors.chipInactiveText,
                  ),
                ),
              ),
            );
          }
          return ListView.separated(
            padding: EdgeInsets.all(16.w),
            itemCount: controller.stores.length,
            separatorBuilder: (_, _) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final store = controller.stores[index];
              final selected = controller.currentStoreId.value == store.id;
              return InkWell(
                onTap: () => controller.pick(store),
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: selected
                          ? AppColors.onboardingBackground
                          : AppColors.cardBorder,
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Iconsax.shop, size: 22.sp),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          store.name,
                          style: getTextStyle(
                            fontSize: 15.2,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (selected)
                        Icon(
                          Iconsax.tick_circle,
                          color: AppColors.onboardingBackground,
                          size: 22.sp,
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
