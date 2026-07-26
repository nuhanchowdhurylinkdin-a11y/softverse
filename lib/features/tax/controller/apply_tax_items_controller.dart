import 'package:get/get.dart';

import '../models/taxable_item.dart';

class ApplyTaxItemsController extends GetxController {
  final selectedIds = <String>{}.obs;
  final selectedCategoryIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final initial = Get.arguments;
    if (initial is List<String>) {
      selectedIds.addAll(initial);
    }
  }

  List<TaxableItem> get visibleItems {
    final category = taxItemCategories[selectedCategoryIndex.value];
    if (category == 'All Item') return taxableItemCatalog;
    return taxableItemCatalog
        .where((item) => item.category == category)
        .toList();
  }

  void selectCategory(int index) => selectedCategoryIndex.value = index;

  void toggleItem(String id) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else {
      selectedIds.add(id);
    }
  }

  void confirm() => Get.back(result: selectedIds.toList());
}
