import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/common/styles/global_text_style.dart';
import '../../../../core/common/widgets/app_text_field.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../controller/add_app_device_controller.dart';
import '../../models/app_device_model.dart';

class AddAppDeviceScreen extends GetView<AddAppDeviceController> {
  const AddAppDeviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final type = controller.type;
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
          'Add ${type.label}',
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
                hintText: type.nameHint,
                backgroundColor: AppColors.chipBackground,
                borderStyle: AppTextFieldBorder.outline,
                borderColor: AppColors.cardBorder,
                hintColor: AppColors.chipInactiveText,
                textColor: AppColors.chipInactiveText,
                fontSize: 16.4,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 16.h,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                type.ipFieldLabel,
                style: getTextStyle(
                  fontSize: 16.4,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onboardingBackground,
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: controller.ipController,
                      hintText: '192.168.12.88',
                      keyboardType: TextInputType.number,
                      backgroundColor: AppColors.chipBackground,
                      borderStyle: AppTextFieldBorder.outline,
                      borderColor: AppColors.cardBorder,
                      hintColor: AppColors.chipInactiveText,
                      textColor: AppColors.chipInactiveText,
                      fontSize: 16.4,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 16.h,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Obx(
                    () => GestureDetector(
                      onTap: controller.isScanning.value
                          ? null
                          : () => _openScanSheet(context),
                      child: Container(
                        width: 55.h,
                        height: 55.h,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.gradientStart,
                              AppColors.gradientEnd,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        alignment: Alignment.center,
                        child: controller.isScanning.value
                            ? SizedBox(
                                width: 20.w,
                                height: 20.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                Iconsax.search_normal_1,
                                color: Colors.white,
                                size: 22.sp,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                'Enter IP address manually or press the "Search" icon',
                style: getTextStyle(
                  fontSize: 10.9,
                  color: AppColors.onboardingBackground,
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
              Center(
                child: GestureDetector(
                  onTap: controller.save,
                  child: Container(
                    width: 197.w,
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
            ],
          ),
        ),
      ),
    );
  }

  void _openScanSheet(BuildContext context) {
    controller.scanNetwork();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Obx(() {
            final devices = controller.foundDevices;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: 16.w),
                    Text(
                      'Devices on your network',
                      style: getTextStyle(
                        fontSize: 16.4,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onboardingBackground,
                      ),
                    ),
                    IconButton(
                      onPressed: controller.scanNetwork,
                      icon: Icon(
                        Iconsax.refresh,
                        size: 20.sp,
                        color: AppColors.onboardingBackground,
                      ),
                    ),
                  ],
                ),
                if (controller.isScanning.value)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.h),
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                else if (devices.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 24.h,
                      horizontal: 16.w,
                    ),
                    child: Text(
                      'No reachable devices found on this network. Make sure the device is powered on and connected, then rescan.',
                      textAlign: TextAlign.center,
                      style: getTextStyle(
                        fontSize: 12.8,
                        color: AppColors.chipInactiveText,
                      ),
                    ),
                  )
                else
                  ...devices.map(
                    (ip) => ListTile(
                      leading: Icon(
                        Iconsax.monitor,
                        color: AppColors.onboardingBackground,
                      ),
                      title: Text(
                        ip,
                        style: getTextStyle(
                          fontSize: 14.6,
                          color: AppColors.authTextDark,
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        controller.selectIp(ip);
                      },
                    ),
                  ),
                SizedBox(height: 8.h),
              ],
            );
          }),
        );
      },
    );
  }
}
