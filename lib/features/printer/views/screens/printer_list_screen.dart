import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/common/styles/global_text_style.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../../../routes/app_routes.dart';
import '../../controller/printer_controller.dart';
import '../../widgets/printer_list_tile.dart';

class PrinterListScreen extends GetView<PrinterController> {
  const PrinterListScreen({super.key});

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
          'Printers',
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
            Obx(
              () => ListView.separated(
                padding: EdgeInsets.all(16.w),
                itemCount: controller.printers.length,
                separatorBuilder: (_, _) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final printer = controller.printers[index];
                  return PrinterListTile(
                    printer: printer,
                    onTap: () => Get.toNamed(
                      AppRoute.getPrinterDetailScreen(),
                      arguments: printer.id,
                    ),
                  );
                },
              ),
            ),
            Positioned(
              right: 16.w,
              bottom: 16.h,
              child: GestureDetector(
                onTap: () => Get.toNamed(AppRoute.getAddPrinterScreen()),
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
