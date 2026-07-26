import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/common/styles/global_text_style.dart';
import '../../../../core/common/widgets/app_text_field.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../controller/app_device_view_controller.dart';
import '../../models/app_device_model.dart';

class AppDeviceViewScreen extends GetView<AppDeviceViewController> {
  const AppDeviceViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final device = controller.device;
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
          '${device.name} ${device.type.label}',
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
              Text(
                'Name',
                style: getTextStyle(
                  fontSize: 16.4,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onboardingBackground,
                ),
              ),
              SizedBox(height: 8.h),
              AppTextField(
                controller: controller.nameController,
                backgroundColor: AppColors.chipBackground,
                borderStyle: AppTextFieldBorder.outline,
                borderColor: AppColors.cardBorder,
                textColor: AppColors.chipInactiveText,
                fontSize: 16.4,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 16.h,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                device.type.ipFieldLabel,
                style: getTextStyle(
                  fontSize: 16.4,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onboardingBackground,
                ),
              ),
              SizedBox(height: 8.h),
              AppTextField(
                controller: controller.ipController,
                backgroundColor: AppColors.chipBackground,
                borderStyle: AppTextFieldBorder.outline,
                borderColor: AppColors.cardBorder,
                textColor: AppColors.chipInactiveText,
                fontSize: 16.4,
                keyboardType: TextInputType.number,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 16.h,
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Iconsax.wifi,
                        size: 22.sp,
                        color: AppColors.onboardingBackground,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Pair',
                        style: getTextStyle(
                          fontSize: 16.4,
                          fontWeight: FontWeight.w500,
                          color: AppColors.onboardingBackground,
                        ),
                      ),
                    ],
                  ),
                  Obx(
                    () => Switch(
                      value: controller.isPaired.value,
                      onChanged: controller.isPairing.value
                          ? null
                          : (_) => controller.togglePairing(),
                      activeThumbColor: Colors.white,
                      activeTrackColor: AppColors.onboardingBackground,
                      inactiveTrackColor: AppColors.toggleTrackOff,
                      inactiveThumbColor: Colors.white,
                      trackOutlineColor: const WidgetStatePropertyAll(
                        Colors.transparent,
                      ),
                      trackOutlineWidth: const WidgetStatePropertyAll(0),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40.h),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: controller.save,
                      child: Container(
                        height: 68.h,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.shiftButtonGradientStart,
                              AppColors.shiftButtonGradientEnd,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          'Save',
                          style: getTextStyle(
                            fontSize: 16.4,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _confirmRemove(context),
                      child: Container(
                        height: 68.h,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.dangerRed,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          'Remove',
                          style: getTextStyle(
                            fontSize: 16.4,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmRemove(BuildContext context) {
    final device = controller.device;
    Get.dialog(
      AlertDialog(
        title: Text('Remove ${device.type.label} device?'),
        content: Text(
          'This will remove ${device.name} from your ${device.type.label} list.',
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.remove();
            },
            child: Text('Remove', style: TextStyle(color: AppColors.dangerRed)),
          ),
        ],
      ),
    );
  }
}
