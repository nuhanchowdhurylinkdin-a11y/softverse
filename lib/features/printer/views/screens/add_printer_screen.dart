import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/common/styles/global_text_style.dart';
import '../../../../core/common/widgets/primary_button.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../../inventory/widgets/toggle_field_row.dart';
import '../../controller/add_printer_controller.dart';
import '../../widgets/printer_form_field.dart';
import '../../widgets/printer_select_row.dart';

class AddPrinterScreen extends GetView<AddPrinterController> {
  const AddPrinterScreen({super.key});

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
          'Add Printer',
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
              PrinterFormField(
                label: 'Name',
                controller: controller.nameController,
                hintText: 'Epson',
              ),
              SizedBox(height: 24.h),
              Text(
                'Printer Model',
                style: getTextStyle(
                  fontSize: 16.4,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onboardingBackground,
                ),
              ),
              SizedBox(height: 8.h),
              Obx(() {
                final device = controller.selectedDevice.value;
                return GestureDetector(
                  onTap: () => _openDevicePicker(context),
                  child: Container(
                    height: 55.h,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: AppColors.chipBackground,
                      border: Border.all(color: AppColors.cardBorder),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            device?.name ?? 'Select paired printer',
                            style: getTextStyle(
                              fontSize: 14.6,
                              color: AppColors.chipInactiveText,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Iconsax.arrow_down_1,
                          size: 22.sp,
                          color: AppColors.chipInactiveText,
                        ),
                      ],
                    ),
                  ),
                );
              }),
              SizedBox(height: 8.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Iconsax.info_circle,
                    size: 14.sp,
                    color: AppColors.chipInactiveText,
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: controller.scanForPrinters,
                          child: Obx(
                            () => Text(
                              controller.isScanning.value
                                  ? 'Scanning for printers...'
                                  : "Can't find your printer? Tap to rescan.",
                              style: getTextStyle(
                                fontSize: 10.9,
                                color: AppColors.onboardingBackground,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          'Make sure the printer is turned on and connected.',
                          style: getTextStyle(
                            fontSize: 10.9,
                            color: AppColors.chipInactiveText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              Text(
                'Select Connection Type',
                style: getTextStyle(
                  fontSize: 16.4,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onboardingBackground,
                ),
              ),
              SizedBox(height: 8.h),
              Obx(
                () => Container(
                  height: 55.h,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: AppColors.chipBackground,
                    border: Border.all(color: AppColors.cardBorder),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        controller.connectionType.value,
                        style: getTextStyle(
                          fontSize: 14.6,
                          color: AppColors.chipInactiveText,
                        ),
                      ),
                      Icon(
                        Iconsax.arrow_down_1,
                        size: 22.sp,
                        color: AppColors.chipInactiveText,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Obx(
                () => ToggleFieldRow(
                  label: 'Print Receipt and Bills',
                  value: controller.printReceiptAndBills.value,
                  onChanged: (v) => controller.printReceiptAndBills.value = v,
                ),
              ),
              SizedBox(height: 8.h),
              Obx(
                () => ToggleFieldRow(
                  label: 'Print Orders',
                  value: controller.printOrders.value,
                  onChanged: (v) => controller.printOrders.value = v,
                ),
              ),
              SizedBox(height: 8.h),
              Obx(
                () => PrinterSelectRow(
                  label: 'Paper size',
                  value: controller.paperSize.value,
                  onTap: () async {
                    final selected = await showPrinterOptionPicker(
                      context: context,
                      title: 'Paper size',
                      options: const ['58mm', '80mm'],
                      selected: controller.paperSize.value,
                    );
                    if (selected != null) {
                      controller.setPaperSize(selected);
                    }
                  },
                ),
              ),
              SizedBox(height: 8.h),
              Obx(
                () => PrinterSelectRow(
                  label: 'Print Density',
                  value: controller.printDensity.value,
                  onTap: () async {
                    final selected = await showPrinterOptionPicker(
                      context: context,
                      title: 'Print Density',
                      options: const ['Light', 'Medium', 'Dark'],
                      selected: controller.printDensity.value,
                    );
                    if (selected != null) {
                      controller.setPrintDensity(selected);
                    }
                  },
                ),
              ),
              SizedBox(height: 8.h),
              Obx(
                () => ToggleFieldRow(
                  label: 'Auto Cut',
                  value: controller.autoCut.value,
                  onChanged: (v) => controller.autoCut.value = v,
                ),
              ),
              SizedBox(height: 8.h),
              Obx(
                () => ToggleFieldRow(
                  label: 'Default Printer',
                  value: controller.isDefault.value,
                  onChanged: (v) => controller.isDefault.value = v,
                ),
              ),
              SizedBox(height: 24.h),
              Obx(
                () => GestureDetector(
                  onTap: controller.isConnecting.value
                      ? null
                      : controller.printTest,
                  child: Container(
                    height: 55.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.onboardingBackground),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: controller.isConnecting.value
                        ? SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Iconsax.printer,
                                size: 22.sp,
                                color: AppColors.onboardingBackground,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'PRINT TEST',
                                style: getTextStyle(
                                  fontSize: 16.4,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.onboardingBackground,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Center(
                child: PrimaryButton(
                  label: 'Save',
                  onPressed: controller.save,
                  gradient: const LinearGradient(
                    colors: [AppColors.gradientStart, AppColors.gradientEnd],
                  ),
                  textColor: Colors.white,
                  width: 197.w,
                  height: 68,
                  fontSize: 16.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDevicePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Obx(() {
            final devices = controller.availableDevices;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: 16.w),
                    Text(
                      'Paired Printers',
                      style: getTextStyle(
                        fontSize: 16.4,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onboardingBackground,
                      ),
                    ),
                    IconButton(
                      onPressed: controller.scanForPrinters,
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
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                else if (devices.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 24.h,
                      horizontal: 16.w,
                    ),
                    child: Text(
                      'No paired Bluetooth printers found. Pair a printer in your device Bluetooth settings first, then tap rescan.',
                      textAlign: TextAlign.center,
                      style: getTextStyle(
                        fontSize: 12.8,
                        color: AppColors.chipInactiveText,
                      ),
                    ),
                  )
                else
                  ...devices.map(
                    (device) => ListTile(
                      leading: Icon(
                        Iconsax.printer,
                        color: AppColors.onboardingBackground,
                      ),
                      title: Text(
                        device.name,
                        style: getTextStyle(
                          fontSize: 14.6,
                          color: AppColors.authTextDark,
                        ),
                      ),
                      subtitle: Text(
                        device.macAdress,
                        style: getTextStyle(
                          fontSize: 11.6,
                          color: AppColors.chipInactiveText,
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        controller.selectDevice(device);
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
