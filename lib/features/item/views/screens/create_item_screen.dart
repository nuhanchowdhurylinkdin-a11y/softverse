import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/common/styles/global_text_style.dart';
import '../../../../core/common/widgets/app_text_field.dart';
import '../../../../core/common/widgets/primary_button.dart';
import '../../../../core/services/feature_settings.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../../inventory/widgets/date_field_row.dart';
import '../../../inventory/widgets/toggle_field_row.dart';
import '../../controller/create_item_controller.dart';
import '../../widgets/combo_pack_editor_section.dart';
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
              SizedBox(height: 24.h),
              CreateItemField(
                label: 'Description',
                controller: controller.descriptionController,
                hintText: 'Item description',
              ),
              SizedBox(height: 24.h),
              GestureDetector(
                onTap: controller.openCategoryPicker,
                child: Container(
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
                () => Padding(
                  padding: EdgeInsets.only(top: 6.h),
                  child: Text(
                    controller.trackStock.value
                        ? 'On: stock is reduced after each sale and shown as In stock, Low stock, or Out of stock.'
                        : 'Off: this item is always sellable; quantities are not tracked.',
                    style: getTextStyle(
                      fontSize: 11.8,
                      color: AppColors.mutedText,
                    ),
                  ),
                ),
              ),
              Obx(
                () =>
                    controller.trackStock.value && !controller.hasSelectedStores
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
              _StoreInventorySection(controller: controller),
              Obx(
                () =>
                    FeatureSettings.isEnabled('product_expiration_information')
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
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
                                        value:
                                            controller.manufacturingDate.value,
                                        onTap: controller.pickManufacturingDate,
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
                                      DateFieldRow(
                                        value: controller.expireDate.value,
                                        onTap: controller.pickExpireDate,
                                      ),
                                      SizedBox(height: 24.h),
                                      CreateItemField(
                                        label: 'Expiration alert quantity',
                                        controller: controller
                                            .expirationAlertQuantityController,
                                        keyboardType: TextInputType.number,
                                        helperText:
                                            'Quantity at which you will be notified about the expiration date',
                                      ),
                                    ],
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
              SizedBox(height: 24.h),
              Obx(
                () => ComboPackEditorSection(
                  enabled: controller.modifierEnabled.value,
                  onEnabledChanged: (_) => controller.toggleModifier(),
                  comboPacks: controller.comboPacks,
                  onSelectionToggle: controller.toggleComboPackSelection,
                  onEdit: (index) =>
                      controller.openComboPackEditor(index: index),
                  onDelete: controller.removeComboPack,
                  onAdd: controller.openComboPackEditor,
                ),
              ),
              SizedBox(height: 24.h),
              _CompositeItemSection(controller: controller),
              SizedBox(height: 24.h),
              _VariantOptionsSection(controller: controller),
              SizedBox(height: 24.h),
              _VariantsSection(controller: controller),
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
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ItemPhotoPicker(
                            selectedImage: controller.selectedImage.value,
                            onChoosePhoto: controller.choosePhoto,
                            onTakePhoto: controller.takePhoto,
                          ),
                          SizedBox(height: 16.h),
                          CreateItemField(
                            label: 'Image URL',
                            controller: controller.imageUrlController,
                            hintText: 'https://example.com/item.jpg',
                            helperText:
                                'Optional when a photo is selected above',
                          ),
                        ],
                      ),
              ),
              SizedBox(height: 40.h),
              Center(
                child: Obx(
                  () => PrimaryButton(
                    label: 'Save',
                    isLoading: controller.isSaving.value,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoreInventorySection extends StatelessWidget {
  final CreateItemController controller;

  const _StoreInventorySection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 24.h),
          _sectionTitle('Available stores'),
          SizedBox(height: 4.h),
          Text(
            'Select the store(s) where this item can be sold.',
            style: getTextStyle(fontSize: 11.8, color: AppColors.mutedText),
          ),
          SizedBox(height: 8.h),
          if (controller.isLoadingStores.value)
            const Center(child: CircularProgressIndicator())
          else if (controller.storeLoadFailed.value)
            _draftCard(
              children: [
                Text(
                  'Could not load stores.',
                  style: getTextStyle(
                    fontSize: 12.8,
                    color: AppColors.dangerRed,
                  ),
                ),
                TextButton(
                  onPressed: controller.fetchStores,
                  child: const Text('RETRY'),
                ),
              ],
            )
          else if (controller.stores.isEmpty)
            _draftCard(
              children: [
                Text(
                  'No active stores found. The item will be available at all stores.',
                  style: getTextStyle(
                    fontSize: 12.8,
                    color: AppColors.mutedText,
                  ),
                ),
              ],
            ),
          ...controller.stores.map(
            (store) => _draftCard(
              children: [
                Row(
                  children: [
                    Expanded(child: Text(store.name)),
                    Switch(
                      value: store.selected.value,
                      onChanged: (value) => store.selected.value = value,
                    ),
                  ],
                ),
                if (store.selected.value && controller.trackStock.value) ...[
                  CreateItemField(
                    label: 'In stock',
                    controller: store.inStockController,
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 12.h),
                  CreateItemField(
                    label: 'Low stock',
                    controller: store.lowStockController,
                    keyboardType: TextInputType.number,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompositeItemSection extends StatelessWidget {
  final CreateItemController controller;

  const _CompositeItemSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ToggleFieldRow(
            label: 'Composite item',
            value: controller.compositeItem.value,
            onChanged: (_) => controller.toggleCompositeItem(),
            boxed: true,
          ),
          if (controller.compositeItem.value) ...[
            SizedBox(height: 12.h),
            ...controller.compositeComponents.asMap().entries.map(
              (entry) => _draftCard(
                onDelete: () => controller.removeCompositeComponent(entry.key),
                children: [
                  CreateItemField(
                    label: 'Component item ID',
                    controller: entry.value.itemIdController,
                    hintText: 'Item UUID',
                  ),
                  SizedBox(height: 12.h),
                  CreateItemField(
                    label: 'Component name',
                    controller: entry.value.nameController,
                  ),
                  SizedBox(height: 12.h),
                  CreateItemField(
                    label: 'Quantity',
                    controller: entry.value.quantityController,
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 12.h),
                  CreateItemField(
                    label: 'Cost',
                    controller: entry.value.costController,
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            _addButton('Add component', controller.addCompositeComponent),
          ],
        ],
      ),
    );
  }
}

class _VariantOptionsSection extends StatelessWidget {
  final CreateItemController controller;

  const _VariantOptionsSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionTitle('Variant options'),
          SizedBox(height: 8.h),
          ...controller.variantOptions.asMap().entries.map(
            (entry) => _draftCard(
              onDelete: () => controller.removeVariantOption(entry.key),
              children: [
                CreateItemField(
                  label: 'Option name',
                  controller: entry.value.optionNameController,
                  hintText: 'Size',
                ),
                SizedBox(height: 12.h),
                CreateItemField(
                  label: 'Option values',
                  controller: entry.value.optionValuesController,
                  hintText: 'Small, Medium, Large',
                  helperText: 'Separate values with commas',
                ),
              ],
            ),
          ),
          _addButton('Add variant option', controller.addVariantOption),
        ],
      ),
    );
  }
}

class _VariantsSection extends StatelessWidget {
  final CreateItemController controller;

  const _VariantsSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionTitle('Variants'),
          SizedBox(height: 8.h),
          ...controller.variants.asMap().entries.map(
            (entry) => _draftCard(
              onDelete: () => controller.removeVariant(entry.key),
              children: [
                CreateItemField(
                  label: 'Variant name',
                  controller: entry.value.nameController,
                ),
                SizedBox(height: 12.h),
                CreateItemField(
                  label: 'Size',
                  controller: entry.value.sizeController,
                ),
                SizedBox(height: 12.h),
                CreateItemField(
                  label: 'Color',
                  controller: entry.value.colorController,
                ),
                SizedBox(height: 12.h),
                Obx(
                  () => SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Available for sale'),
                    value: entry.value.availableForSale.value,
                    onChanged: (value) =>
                        entry.value.availableForSale.value = value,
                  ),
                ),
                CreateItemField(
                  label: 'Price',
                  controller: entry.value.priceController,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 12.h),
                CreateItemField(
                  label: 'Cost',
                  controller: entry.value.costController,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 12.h),
                CreateItemField(
                  label: 'SKU',
                  controller: entry.value.skuController,
                ),
                SizedBox(height: 12.h),
                CreateItemField(
                  label: 'Barcode',
                  controller: entry.value.barcodeController,
                ),
              ],
            ),
          ),
          _addButton('Add variant', controller.addVariant),
        ],
      ),
    );
  }
}

Widget _draftCard({required List<Widget> children, VoidCallback? onDelete}) {
  return Container(
    margin: EdgeInsets.only(bottom: 12.h),
    padding: EdgeInsets.all(12.w),
    decoration: BoxDecoration(
      color: AppColors.chipBackground,
      border: Border.all(color: AppColors.cardBorder),
      borderRadius: BorderRadius.circular(12.r),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (onDelete != null)
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
          ),
        ...children,
      ],
    ),
  );
}

Widget _addButton(String label, VoidCallback onPressed) {
  return OutlinedButton.icon(
    onPressed: onPressed,
    icon: const Icon(Icons.add),
    label: Text(label),
  );
}

Widget _sectionTitle(String label) {
  return Text(
    label,
    style: getTextStyle(
      fontSize: 16.4,
      fontWeight: FontWeight.w500,
      color: AppColors.onboardingBackground,
    ),
  );
}
