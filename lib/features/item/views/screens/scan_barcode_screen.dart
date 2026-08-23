import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/common/styles/global_text_style.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../controller/scan_barcode_controller.dart';

class ScanBarcodeScreen extends GetView<ScanBarcodeController> {
  const ScanBarcodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.featureTitle,
      appBar: AppBar(
        centerTitle: false,
        toolbarHeight: 69.h,
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
          'Scan barcode',
          style: getTextStyle(
            fontSize: 21.9,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: controller.flipCamera,
            icon: Icon(Iconsax.refresh_2, color: Colors.white, size: 26.sp),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: MobileScanner(
          controller: controller.cameraController,
          onDetect: controller.onDetect,
          overlayBuilder: (context, constraints) => const _ViewfinderOverlay(),
          errorBuilder: (context, error) => _CameraError(
            error: error,
            onOpenSettings: controller.openAppSettings,
          ),
        ),
      ),
    );
  }
}

class _ViewfinderOverlay extends StatelessWidget {
  const _ViewfinderOverlay();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0, 0.15),
      child: SizedBox(
        width: 305.w,
        height: 120.h,
        child: Stack(
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: 12.5.w),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.dangerRed, width: 2),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(left: 12.5.w),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.dangerRed, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: Colors.white),
                  child: SizedBox(height: 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CameraError extends StatelessWidget {
  final MobileScannerException error;
  final VoidCallback onOpenSettings;

  const _CameraError({required this.error, required this.onOpenSettings});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - 64.h,
            ),
            child: Center(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(22.w, 24.h, 22.w, 22.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.10),
                  ),
                  borderRadius: BorderRadius.circular(22.r),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 78.w,
                      height: 78.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Iconsax.camera_slash,
                        size: 38.sp,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 18.h),
                    Text(
                      'Camera access needed',
                      textAlign: TextAlign.center,
                      style: getTextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Allow camera permission to scan item barcodes.',
                      textAlign: TextAlign.center,
                      style: getTextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.82),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      error.errorCode.message,
                      textAlign: TextAlign.center,
                      style: getTextStyle(
                        fontSize: 12.8,
                        color: Colors.white.withValues(alpha: 0.58),
                      ),
                    ),
                    SizedBox(height: 22.h),
                    SizedBox(
                      width: double.infinity,
                      height: 48.h,
                      child: FilledButton.icon(
                        onPressed: onOpenSettings,
                        icon: Icon(Iconsax.setting_2, size: 18.sp),
                        label: const Text('Open Settings'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.onboardingBackground,
                          foregroundColor: Colors.white,
                          textStyle: getTextStyle(
                            fontSize: 15.2,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
