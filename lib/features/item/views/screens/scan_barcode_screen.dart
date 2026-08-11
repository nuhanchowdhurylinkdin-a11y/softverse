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
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.camera_slash, size: 48.sp, color: Colors.white),
            SizedBox(height: 16.h),
            Text(
              'Camera permission is required to scan item barcodes.',
              textAlign: TextAlign.center,
              style: getTextStyle(fontSize: 14.6, color: Colors.white),
            ),
            SizedBox(height: 8.h),
            Text(
              error.errorCode.message,
              textAlign: TextAlign.center,
              style: getTextStyle(fontSize: 12.8, color: Colors.white70),
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: onOpenSettings,
              child: const Text('Open Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
