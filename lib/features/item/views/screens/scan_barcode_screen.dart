import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/common/styles/global_text_style.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../../shift/widgets/shift_header.dart';
import '../../controller/scan_barcode_controller.dart';

class ScanBarcodeScreen extends GetView<ScanBarcodeController> {
  const ScanBarcodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.featureTitle,
      body: SafeArea(
        child: Column(
          children: [
            ShiftHeader(
              title: 'Scan barcode',
              trailingIcon: Iconsax.refresh_2,
              onClockTap: controller.flipCamera,
            ),
            Expanded(
              child: Stack(
                children: [
                  Align(
                    alignment: const Alignment(0, 0.15),
                    child: SizedBox(
                      width: 305.w,
                      height: 120.h,
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(right: 12.5.w),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.dangerRed,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(left: 12.5.w),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.dangerRed,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Container(height: 1, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Obx(
                    () => controller.showPermissionPrompt.value
                        ? Align(
                            alignment: Alignment.bottomCenter,
                            child: _PermissionPrompt(controller: controller),
                          )
                        : const SizedBox.shrink(),
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

class _PermissionPrompt extends StatelessWidget {
  final ScanBarcodeController controller;

  const _PermissionPrompt({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Iconsax.camera, size: 32.sp, color: AppColors.authTextDark),
          SizedBox(height: 16.h),
          Text(
            'Allow Softverse POS to take pictures\nand record video?',
            style: getTextStyle(fontSize: 14.6, color: AppColors.authTextDark),
          ),
          SizedBox(height: 20.h),
          _PermissionButton(
            label: 'While using the app',
            onTap: controller.allowWhileUsingApp,
          ),
          SizedBox(height: 8.h),
          _PermissionButton(
            label: 'Only this time',
            onTap: controller.allowOnlyThisTime,
          ),
          SizedBox(height: 8.h),
          _PermissionButton(
            label: "Don't allow",
            onTap: controller.denyPermission,
          ),
        ],
      ),
    );
  }
}

class _PermissionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PermissionButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.lightBorder,
          borderRadius: BorderRadius.circular(50.r),
        ),
        child: Text(
          label,
          style: getTextStyle(
            fontSize: 16.4,
            fontWeight: FontWeight.w500,
            color: AppColors.onboardingBackground,
          ).copyWith(letterSpacing: 0.16),
        ),
      ),
    );
  }
}
