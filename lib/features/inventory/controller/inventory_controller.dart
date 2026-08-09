import 'package:get/get.dart';

import '../../../core/services/network_caller.dart';
import '../../../core/services/offline_database_service.dart';
import '../../../core/utils/constants/api_constants.dart';
import '../../../core/utils/helpers/app_helper.dart';
import '../../../routes/app_routes.dart';
import '../models/inventory_product.dart';

class InventoryController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();
  final selectedCategoryIndex = 0.obs;
  final selectedFilterIndex = 0.obs;
  final isLoading = false.obs;

  final categories = <String>['All Item'].obs;
  final filterLabels = const ['All', 'Low Stock', 'Out', 'In Stock'];
  final _stockFilters = const [null, 'low_stock', 'out_of_stock', 'in_stock'];
  final products = <InventoryProduct>[].obs;

  List<InventoryProduct> get visibleProducts {
    final category =
        selectedCategoryIndex.value <= 0 ||
            selectedCategoryIndex.value >= categories.length
        ? null
        : categories[selectedCategoryIndex.value];
    return products
        .where(
          (product) => category == null || product.categoryName == category,
        )
        .toList(growable: false);
  }

  void selectCategory(int index) => selectedCategoryIndex.value = index;

  @override
  void onInit() {
    super.onInit();
    _loadCachedCategories();
    _loadCachedInventory();
    fetchCategories();
    fetchInventory();
  }

  Future<void> selectFilter(int index) async {
    selectedFilterIndex.value = index;
    await fetchInventory();
  }

  Future<void> fetchInventory() async {
    isLoading.value = true;
    final stockFilter = _stockFilters[selectedFilterIndex.value];
    final url = stockFilter == null
        ? ApiConstants.inventory
        : '${ApiConstants.inventory}?stockStatus=$stockFilter';
    final response = await _networkCaller.getRequest(url);
    isLoading.value = false;
    if (!response.isSuccess || response.responseData is! Map) {
      if (products.isEmpty) {
        AppHelperFunctions.showWarningSnackBar('Inventory saved offline.');
      }
      return;
    }
    final data = Map<String, dynamic>.from(response.responseData as Map);
    if (selectedFilterIndex.value == 0) {
      await OfflineDatabaseService.saveCache('inventory', data);
    }
    _applyInventory(data);
  }

  Future<void> fetchCategories() async {
    final response = await _networkCaller.getRequest(ApiConstants.categories);
    if (!response.isSuccess || response.responseData is! List) return;
    final data = List<dynamic>.from(response.responseData as List);
    await OfflineDatabaseService.saveCache('categories', data);
    _applyCategories(data);
  }

  void openProduct(InventoryProduct product) {
    Get.toNamed(AppRoute.getItemDetailScreen(), arguments: product);
  }

  void openSearch() {}

  void openScan() {}

  void openNotifications() {}

  void _loadCachedCategories() {
    final cached = OfflineDatabaseService.readCache<List<dynamic>>(
      'categories',
    );
    if (cached != null) _applyCategories(cached);
  }

  void _loadCachedInventory() {
    final cached = OfflineDatabaseService.readCache<Map<String, dynamic>>(
      'inventory',
    );
    if (cached != null) _applyInventory(cached);
  }

  void _applyInventory(Map<String, dynamic> data) {
    final rawItems = data['items'];
    if (rawItems is! List) return;
    final mapped = rawItems
        .whereType<Map>()
        .map(
          (entry) => InventoryProduct.fromApi(Map<String, dynamic>.from(entry)),
        )
        .toList();
    products.assignAll(mapped);
    if (categories.length == 1) {
      _applyCategoryNames(mapped.map((product) => product.categoryName));
    }
  }

  void _applyCategories(List<dynamic> data) {
    _applyCategoryNames(
      data
          .whereType<Map>()
          .map((entry) => entry['name']?.toString())
          .whereType<String>(),
    );
  }

  void _applyCategoryNames(Iterable<String?> namesSource) {
    final names =
        namesSource
            .whereType<String>()
            .where((name) => name.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    categories.assignAll(['All Item', ...names]);
    if (selectedCategoryIndex.value >= categories.length) {
      selectedCategoryIndex.value = 0;
    }
  }
}
