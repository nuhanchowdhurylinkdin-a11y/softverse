import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/common/styles/global_text_style.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../../../routes/app_routes.dart';
import '../../models/app_device_model.dart';

class AppsMenuScreen extends StatelessWidget {
  const AppsMenuScreen({super.key});

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
          'Apps',
          style: getTextStyle(
            fontSize: 16.4,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _AppTile(
                type: AppDeviceType.cds,
                onTap: () => Get.toNamed(
                  AppRoute.getAppDeviceListScreen(),
                  arguments: AppDeviceType.cds,
                ),
              ),
              SizedBox(height: 12.h),
              _AppTile(
                type: AppDeviceType.kds,
                onTap: () => Get.toNamed(
                  AppRoute.getAppDeviceListScreen(),
                  arguments: AppDeviceType.kds,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppTile extends StatelessWidget {
  final AppDeviceType type;
  final VoidCallback onTap;

  const _AppTile({required this.type, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, AppColors.rowGradientEnd],
          ),
          border: Border.all(color: AppColors.cardBorder),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(
              Iconsax.monitor,
              size: 26.sp,
              color: AppColors.onboardingBackground,
            ),
            SizedBox(width: 12.w),
            Text(
              type.label,
              style: getTextStyle(
                fontSize: 14.6,
                fontWeight: FontWeight.w500,
                color: AppColors.onboardingBackground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
