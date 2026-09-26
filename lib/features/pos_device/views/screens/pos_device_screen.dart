import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/common/styles/global_text_style.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../controller/pos_device_controller.dart';
import '../../models/pos_device_model.dart';

class PosDeviceScreen extends GetView<PosDeviceController> {
  const PosDeviceScreen({super.key});

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
          'Switch POS',
          style: getTextStyle(
            fontSize: 16.4,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: controller.fetchDevices,
          child: Obx(() {
            if (controller.isLoading.value && controller.devices.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.devices.isEmpty) {
              return ListView(
                padding: EdgeInsets.all(24.w),
                children: [
                  SizedBox(height: 80.h),
                  Text(
                    'No POS devices have been set up yet.\nAdd one from the Business Admin '
                    'dashboard under Store settings > POS devices.',
                    textAlign: TextAlign.center,
                    style: getTextStyle(
                      fontSize: 14.4,
                      color: AppColors.chipInactiveText,
                    ),
                  ),
                ],
              );
            }
            return ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount: controller.devices.length,
              separatorBuilder: (_, _) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final device = controller.devices[index];
                final isSelected = controller.selectedDeviceId.value == device.id;
                return _PosDeviceTile(
                  device: device,
                  isSelected: isSelected,
                  onTap: controller.isSaving.value
                      ? null
                      : () => controller.selectDevice(device),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}

class _PosDeviceTile extends StatelessWidget {
  final PosDeviceModel device;
  final bool isSelected;
  final VoidCallback? onTap;

  const _PosDeviceTile({
    required this.device,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.onboardingBackground : AppColors.cardBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.name,
                    style: getTextStyle(
                      fontSize: 15.2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    device.storeName ?? 'Unassigned store',
                    style: getTextStyle(
                      fontSize: 12.8,
                      color: AppColors.chipInactiveText,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Iconsax.tick_circle,
                color: AppColors.onboardingBackground,
                size: 22.sp,
              ),
          ],
        ),
      ),
    );
  }
}
