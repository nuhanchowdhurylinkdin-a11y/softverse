import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/common/styles/global_text_style.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../../../routes/app_routes.dart';
import '../../controller/general_controller.dart';
import '../../widgets/language_picker.dart';

class GeneralSettingsScreen extends GetView<GeneralController> {
  const GeneralSettingsScreen({super.key});

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
          'General',
          style: getTextStyle(
            fontSize: 16.4,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Use camera to scan barcodes',
                      style: getTextStyle(
                        fontSize: 14.6,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onboardingBackground,
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  Obx(
                    () => Switch(
                      value: controller.cameraScanEnabled.value,
                      activeThumbColor: Colors.white,
                      activeTrackColor: AppColors.onboardingBackground,
                      inactiveTrackColor: AppColors.toggleTrackOff,
                      onChanged: controller.toggleCameraScan,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              GestureDetector(
                onTap: () =>
                    Get.toNamed(AppRoute.getHomeScreenItemLayoutScreen()),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Home screen item layout',
                      style: getTextStyle(
                        fontSize: 14.6,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onboardingBackground,
                        textAlign: TextAlign.left,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      height: 52.h,
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: AppColors.chipBackground,
                        border: Border.all(color: AppColors.cardBorder),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Obx(
                        () => Text(
                          controller.homeScreenLayoutLabel,
                          style: getTextStyle(
                            fontSize: 14.6,
                            color: AppColors.chipInactiveText,
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Feature',
                style: getTextStyle(
                  fontSize: 14.6,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onboardingBackground,
                  textAlign: TextAlign.left,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Language',
                style: getTextStyle(
                  fontSize: 14.6,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onboardingBackground,
                  textAlign: TextAlign.left,
                ),
              ),
              SizedBox(height: 8.h),
              Obx(
                () => GestureDetector(
                  onTap: () async {
                    final result = await showLanguagePicker(
                      context: context,
                      selected: controller.language.value,
                    );
                    if (result != null) {
                      controller.selectLanguage(result);
                    }
                  },
                  child: Container(
                    height: 52.h,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: AppColors.chipBackground,
                      border: Border.all(color: AppColors.cardBorder),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            controller.language.value,
                            style: getTextStyle(
                              fontSize: 14.6,
                              color: AppColors.chipInactiveText,
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                        Icon(
                          Iconsax.arrow_down_1,
                          size: 20.sp,
                          color: AppColors.chipInactiveText,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
