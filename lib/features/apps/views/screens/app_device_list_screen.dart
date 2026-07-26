import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/common/styles/global_text_style.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../../../routes/app_routes.dart';
import '../../controller/apps_controller.dart';
import '../../models/app_device_model.dart';
import '../../widgets/app_device_list_tile.dart';

class AppDeviceListScreen extends GetView<AppsController> {
  const AppDeviceListScreen({super.key});

  AppDeviceType get _type => Get.arguments as AppDeviceType;

  @override
  Widget build(BuildContext context) {
    final type = _type;
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
          type.label,
          style: getTextStyle(
            fontSize: 16.4,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            Obx(() {
              final items = controller.devicesOfType(type);
              return ListView.separated(
                padding: EdgeInsets.all(16.w),
                itemCount: items.length,
                separatorBuilder: (_, _) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final device = items[index];
                  return AppDeviceListTile(
                    device: device,
                    onTap: () => Get.toNamed(
                      AppRoute.getAppDeviceViewScreen(),
                      arguments: device.id,
                    ),
                  );
                },
              );
            }),
            Positioned(
              right: 16.w,
              bottom: 16.h,
              child: GestureDetector(
                onTap: () => Get.toNamed(
                  AppRoute.getAddAppDeviceScreen(),
                  arguments: type,
                ),
                child: Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: const BoxDecoration(
                    color: AppColors.onboardingBackground,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Iconsax.add, color: Colors.white, size: 24.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
