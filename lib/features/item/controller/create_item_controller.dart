import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../../inventory/models/modifier_group.dart';

enum SoldBy { pcs, weight }

enum ItemRepresentation { colorAndShape, image }

class CreateItemController extends GetxController {
  final nameController = TextEditingController();
  final categoryController = TextEditingController();
  final priceController = TextEditingController();
  final costController = TextEditingController();
  final skuController = TextEditingController();
  final barcodeController = TextEditingController();
  final inStockController = TextEditingController();
  final lowStockController = TextEditingController();

  final soldBy = Rx<SoldBy?>(null);

  final trackStock = false.obs;
  final trackDate = false.obs;
  final manufacturingDate = '2/2025'.obs;
  final expireDate = '2/2028'.obs;

  final modifierEnabled = false.obs;
  final selectedModifierOptionIndex = 0.obs;
  final modifierGroup = const ModifierGroup(
    options: [
      ModifierOption(
        label: 'Combo Pack 1',
        products: [
          ModifierProduct(name: 'Mouse + Keyboard', price: 1100),
          ModifierProduct(name: '2 pcs Keyboard', price: 1300),
        ],
      ),
      ModifierOption(
        label: 'Combo Pack 1',
        products: [ModifierProduct(name: '2 pcs Mouse', price: 750)],
      ),
    ],
  );

  final representation = ItemRepresentation.colorAndShape.obs;
  final selectedColorIndex = 0.obs;
  final selectedShapeIndex = 0.obs;

  void selectSoldBy(SoldBy value) => soldBy.value = value;

  void toggleTrackStock() => trackStock.value = !trackStock.value;

  void toggleTrackDate() => trackDate.value = !trackDate.value;

  void toggleModifier() => modifierEnabled.value = !modifierEnabled.value;

  void selectModifierOption(int index) =>
      selectedModifierOptionIndex.value = index;

  void selectRepresentation(ItemRepresentation value) =>
      representation.value = value;

  void selectColor(int index) => selectedColorIndex.value = index;

  void selectShape(int index) => selectedShapeIndex.value = index;

  Future<void> openScanBarcode() async {
    final result = await Get.toNamed(AppRoute.getScanBarcodeScreen());
    if (result is String && result.isNotEmpty) {
      barcodeController.text = result;
    }
  }

  void choosePhoto() {}

  void takePhoto() {}

  void save() => Get.back();

  @override
  void onClose() {
    nameController.dispose();
    categoryController.dispose();
    priceController.dispose();
    costController.dispose();
    skuController.dispose();
    barcodeController.dispose();
    inStockController.dispose();
    lowStockController.dispose();
    super.onClose();
  }
}
