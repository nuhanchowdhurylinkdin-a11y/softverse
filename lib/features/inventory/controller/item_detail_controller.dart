import 'package:get/get.dart';

import '../models/inventory_product.dart';
import '../models/modifier_group.dart';

class ItemDetailController extends GetxController {
  late InventoryProduct product;

  final soldBy = 'PCS';
  final manufacturingDate = '2/2025';
  final expireDate = '2/2028';

  final modifierEnabled = true.obs;
  final trackExpiryDate = true.obs;
  final activityEnabled = true.obs;
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

  @override
  void onInit() {
    super.onInit();
    product = Get.arguments as InventoryProduct;
  }

  void toggleModifier() => modifierEnabled.toggle();

  void toggleTrackExpiryDate() => trackExpiryDate.toggle();

  void toggleActivity() => activityEnabled.toggle();

  void selectModifierOption(int index) =>
      selectedModifierOptionIndex.value = index;
}
