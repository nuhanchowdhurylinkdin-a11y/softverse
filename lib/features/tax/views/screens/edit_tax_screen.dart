import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/common/styles/global_text_style.dart';
import '../../../../core/common/widgets/app_text_field.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../controller/edit_tax_controller.dart';
import '../../models/tax_model.dart';
import '../../widgets/tax_type_picker.dart';

class EditTaxScreen extends GetView<EditTaxController> {
  const EditTaxScreen({super.key});

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
          'Edit Tax',
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
                'Tax rate %',
                style: getTextStyle(
                  fontSize: 16.4,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onboardingBackground,
                ),
              ),
              SizedBox(height: 8.h),
              AppTextField(
                controller: controller.rateController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
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
                'Type',
                style: getTextStyle(
                  fontSize: 16.4,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onboardingBackground,
                ),
              ),
              SizedBox(height: 8.h),
              Obx(
                () => GestureDetector(
                  onTap: () async {
                    final selected = await showTaxTypePicker(
                      context: context,
                      selected: controller.type.value,
                    );
                    if (selected != null) controller.setType(selected);
                  },
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
                            controller.type.value?.label ?? 'Select tax type',
                            style: getTextStyle(
                              fontSize: 14.6,
                              color: AppColors.chipInactiveText,
                            ),
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
              ),
              SizedBox(height: 24.h),
              GestureDetector(
                onTap: controller.openApplyToItems,
                child: Container(
                  height: 55.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.onboardingBackground),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Obx(
                    () => Text(
                      'Apply to items (${controller.appliedItemIds.length})',
                      style: getTextStyle(
                        fontSize: 16.4,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onboardingBackground,
                      ),
                    ),
                  ),
                ),
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
    Get.dialog(
      AlertDialog(
        title: const Text('Remove tax?'),
        content: Text(
          'This will remove ${controller.tax.name} (${formatTaxRate(controller.tax.ratePercent)}%) from your tax list.',
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
