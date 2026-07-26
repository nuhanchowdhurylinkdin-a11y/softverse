import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/common/styles/global_text_style.dart';
import '../../../../core/common/widgets/app_text_field.dart';
import '../../../../core/common/widgets/primary_button.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../../inventory/widgets/date_field_row.dart';
import '../../../inventory/widgets/modifier_section.dart';
import '../../../inventory/widgets/toggle_field_row.dart';
import '../../controller/create_item_controller.dart';
import '../../widgets/color_shape_picker.dart';
import '../../widgets/create_item_field.dart';
import '../../widgets/item_photo_picker.dart';
import '../../widgets/labeled_radio_option.dart';

class CreateItemScreen extends GetView<CreateItemController> {
  const CreateItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
          'Create item',
          style: getTextStyle(
            fontSize: 21.9,
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
              AppTextField(
                controller: controller.nameController,
                hintText: 'A4tec mouse',
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
              SizedBox(height: 8.h),
              Container(
                height: 60.h,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: AppColors.chipBackground,
                  border: Border.all(color: AppColors.cardBorder),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: controller.categoryController,
                      builder: (context, value, _) => Text(
                        value.text.isEmpty ? 'No Category' : value.text,
                        style: getTextStyle(
                          fontSize: 16.4,
                          fontWeight: FontWeight.w500,
                          color: AppColors.chipInactiveText,
                        ),
                      ),
                    ),
                    Icon(
                      Iconsax.arrow_down_2,
                      size: 22.sp,
                      color: AppColors.chipInactiveText,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'Sold by',
                style: getTextStyle(
                  fontSize: 16.4,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onboardingBackground,
                ),
              ),
              SizedBox(height: 20.h),
              Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LabeledRadioOption(
                      label: 'PCS',
                      selected: controller.soldBy.value == SoldBy.pcs,
                      onTap: () => controller.selectSoldBy(SoldBy.pcs),
                    ),
                    SizedBox(height: 16.h),
                    LabeledRadioOption(
                      label: 'Weight',
                      selected: controller.soldBy.value == SoldBy.weight,
                      onTap: () => controller.selectSoldBy(SoldBy.weight),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              CreateItemField(
                label: 'Price',
                controller: controller.priceController,
                hintText: '\$0.00',
                keyboardType: TextInputType.number,
                helperText:
                    'To indicate the price upon sale, leave the field blank',
              ),
              SizedBox(height: 24.h),
              CreateItemField(
                label: 'Cost',
                controller: controller.costController,
                hintText: '\$0.00',
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 24.h),
              CreateItemField(
                label: 'SKU',
                controller: controller.skuController,
                hintText: '00000',
                helperText:
                    'To indicate the price upon sale, leave the field blank',
              ),
              SizedBox(height: 24.h),
              CreateItemField(
                label: 'Barcode',
                controller: controller.barcodeController,
                hintText: 'Scan or Manually enter',
                suffixIcon: GestureDetector(
                  onTap: controller.openScanBarcode,
                  child: Icon(
                    Iconsax.barcode,
                    size: 22.sp,
                    color: AppColors.chipInactiveText,
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'Inventory',
                style: getTextStyle(
                  fontSize: 16.4,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onboardingBackground,
                ),
              ),
              SizedBox(height: 8.h),
              Obx(
                () => ToggleFieldRow(
                  label: 'Track stock',
                  value: controller.trackStock.value,
                  onChanged: (_) => controller.toggleTrackStock(),
                  boxed: true,
                ),
              ),
              Obx(
                () => controller.trackStock.value
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: 8.h),
                          CreateItemField(
                            label: 'In Stock',
                            controller: controller.inStockController,
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(height: 24.h),
                          CreateItemField(
                            label: 'Low Stock',
                            controller: controller.lowStockController,
                            keyboardType: TextInputType.number,
                            helperText:
                                'Quantity at which you will be notified about low stock',
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
              SizedBox(height: 24.h),
              Text(
                'Expire Date',
                style: getTextStyle(
                  fontSize: 16.4,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onboardingBackground,
                ),
              ),
              SizedBox(height: 8.h),
              Obx(
                () => ToggleFieldRow(
                  label: 'Track Date',
                  value: controller.trackDate.value,
                  onChanged: (_) => controller.toggleTrackDate(),
                  boxed: true,
                ),
              ),
              Obx(
                () => controller.trackDate.value
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: 24.h),
                          Text(
                            'Manufacturing Date',
                            style: getTextStyle(
                              fontSize: 16.4,
                              fontWeight: FontWeight.w500,
                              color: AppColors.onboardingBackground,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          DateFieldRow(
                            value: controller.manufacturingDate.value,
                          ),
                          SizedBox(height: 24.h),
                          Text(
                            'Expire Date',
                            style: getTextStyle(
                              fontSize: 16.4,
                              fontWeight: FontWeight.w500,
                              color: AppColors.onboardingBackground,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          DateFieldRow(value: controller.expireDate.value),
                          SizedBox(height: 8.h),
                          Text(
                            'Quantity at which you will be notified about Expire Date',
                            style: getTextStyle(
                              fontSize: 12.8,
                              color: AppColors.chipInactiveText,
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
              SizedBox(height: 24.h),
              Obx(
                () => ModifierSection(
                  group: controller.modifierGroup,
                  enabled: controller.modifierEnabled.value,
                  onEnabledChanged: (_) => controller.toggleModifier(),
                  selectedOptionIndex:
                      controller.selectedModifierOptionIndex.value,
                  onOptionSelected: controller.selectModifierOption,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'Representation on POS',
                style: getTextStyle(
                  fontSize: 16.4,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onboardingBackground,
                ),
              ),
              SizedBox(height: 20.h),
              Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LabeledRadioOption(
                      label: 'Color and shape',
                      selected:
                          controller.representation.value ==
                          ItemRepresentation.colorAndShape,
                      onTap: () => controller.selectRepresentation(
                        ItemRepresentation.colorAndShape,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    LabeledRadioOption(
                      label: 'Image',
                      selected:
                          controller.representation.value ==
                          ItemRepresentation.image,
                      onTap: () => controller.selectRepresentation(
                        ItemRepresentation.image,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              Obx(
                () =>
                    controller.representation.value ==
                        ItemRepresentation.colorAndShape
                    ? ColorShapePicker(
                        selectedColorIndex: controller.selectedColorIndex.value,
                        onColorSelected: controller.selectColor,
                        selectedShapeIndex: controller.selectedShapeIndex.value,
                        onShapeSelected: controller.selectShape,
                      )
                    : ItemPhotoPicker(
                        onChoosePhoto: controller.choosePhoto,
                        onTakePhoto: controller.takePhoto,
                      ),
              ),
              SizedBox(height: 40.h),
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
}
