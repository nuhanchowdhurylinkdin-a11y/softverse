import 'package:get/get.dart';

import '../../../core/services/network_caller.dart';
import '../../../core/utils/constants/api_constants.dart';
import '../../../core/utils/helpers/app_helper.dart';
import '../models/taxable_item.dart';

class ApplyTaxItemsController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();
  final items = <TaxableItem>[].obs;
  final selectedIds = <String>[].obs;
  final selectedCategoryIndex = 0.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    final initial = Get.arguments;
    if (initial is List<String>) {
      selectedIds.addAll(initial);
    }
    fetchItems();
  }

  List<String> get categories {
    final names = items.map((item) => item.category).toSet().toList()..sort();
    return ['All Item', ...names];
  }

  List<TaxableItem> get visibleItems {
    if (items.isEmpty) return [];
    final safeIndex = selectedCategoryIndex.value
        .clamp(0, categories.length - 1)
        .toInt();
    final category = categories[safeIndex];
    if (category == 'All Item') return items;
    return items.where((item) => item.category == category).toList();
  }

  Future<void> fetchItems() async {
    isLoading.value = true;
    final response = await _networkCaller.getRequest(ApiConstants.taxItems);
    isLoading.value = false;
    if (!response.isSuccess || response.responseData is! List) {
      AppHelperFunctions.showErrorSnackBar(response.errorMessage);
      return;
    }
    items.assignAll(
      List<dynamic>.from(response.responseData as List).whereType<Map>().map(
        (json) => TaxableItem.fromApi(Map<String, dynamic>.from(json)),
      ),
    );
  }

  void selectCategory(int index) => selectedCategoryIndex.value = index;

  void toggleItem(String id) {
    final next = selectedIds.toSet();
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    selectedIds.assignAll(next);
  }

  void confirm() => Get.back(result: selectedIds.toList());
}
