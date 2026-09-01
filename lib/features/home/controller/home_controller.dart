import 'package:get/get.dart';

import '../../../core/services/feature_settings.dart';
import '../../../core/common/widgets/catalog_search_sheet.dart';
import '../../../core/services/network_caller.dart';
import '../../../core/services/offline_database_service.dart';
import '../../../core/utils/constants/api_constants.dart';
import '../../../core/utils/helpers/app_helper.dart';
import '../../../routes/app_routes.dart';
import '../../checkout/controller/checkout_controller.dart';
import '../../invoice/controller/invoice_controller.dart';
import '../../main_nav/controller/main_nav_controller.dart';
import '../models/product.dart';
import '../models/table_order.dart';
import '../data/home_repository.dart';

class HomeController extends GetxController {
  final NetworkCaller _networkCaller;
  final HomeRepository _homeRepository;

  HomeController({NetworkCaller? networkCaller, HomeRepository? homeRepository})
    : _networkCaller = networkCaller ?? NetworkCaller(),
      _homeRepository = homeRepository ?? HttpHomeRepository();
  final isOrderTabSelected = true.obs;
  final selectedCategoryIndex = 0.obs;
  final isLoadingCatalog = false.obs;
  final isLoadingTables = false.obs;

  final orderId = 'POS-1 Order-1';

  int get orderItemCount => Get.find<CheckoutController>().cartItems.fold(
    0,
    (sum, item) => sum + item.quantity,
  );

  double get orderTotal => Get.find<CheckoutController>().subtotal;

  final categories = <String>['All Item'].obs;
  final products = <Product>[].obs;
  final tableOrders = <TableOrder>[].obs;

  List<TableOrder> get availableTables => tableOrders
      .where((table) => table.isAvailable && table.tableId.isNotEmpty)
      .toList(growable: false);

  List<TableOrder> get visibleTableOrders =>
      tableOrders.where((table) => table.hasOrder).toList(growable: false);

  List<Product> get visibleProducts {
    if (selectedCategoryIndex.value <= 0 ||
        selectedCategoryIndex.value >= categories.length) {
      return products;
    }
    final selected = categories[selectedCategoryIndex.value];
    return products
        .where((product) => product.categoryName == selected)
        .toList(growable: false);
  }

  @override
  void onInit() {
    super.onInit();
    _loadCachedCatalog();
    _loadCachedTables();
    forceSync(showMessage: false);
  }

  Future<void> openTableOrder(TableOrder tableOrder) async {
    if (!tableOrder.hasOrder) return;
    if (tableOrder.status == OrderStatus.complete ||
        tableOrder.status == OrderStatus.paid) {
      final response = await _networkCaller.getRequest(
        ApiConstants.checkoutOrder(tableOrder.id!),
      );
      if (response.isSuccess && response.responseData is Map) {
        Get.find<InvoiceController>().loadFromOrder(
          Map<String, dynamic>.from(response.responseData as Map),
          fallbackTableId: tableOrder.tableId,
          fallbackTableName: tableOrder.tableName,
        );
        Get.toNamed(AppRoute.getInvoiceScreen());
      }
      return;
    }

    await Get.find<CheckoutController>().loadOrderForCheckout(tableOrder.id!);
  }

  void selectOrderTab() => isOrderTabSelected.value = true;

  void selectTableTab() {
    isOrderTabSelected.value = false;
    fetchTables();
  }

  void selectCategory(int index) => selectedCategoryIndex.value = index;

  void checkout() => Get.find<MainNavController>().changeTab(1);

  void openPendingOrders() =>
      Get.find<CheckoutController>().openPendingOrders();

  void addToCart(Product product) {
    if (product.isOutOfStock &&
        FeatureSettings.isEnabled('negative_stock_alerts')) {
      AppHelperFunctions.showWarningSnackBar(
        '${product.name} is out of stock.',
      );
      return;
    }
    Get.find<CheckoutController>().addProduct(
      itemId: product.id,
      name: product.name,
      price: product.price,
      imageUrl: product.imageUrl,
    );
  }

  Product? findProductByBarcode(String barcode) {
    final normalized = barcode.trim().toLowerCase();
    if (normalized.isEmpty) return null;
    return products.firstWhereOrNull(
      (product) => product.barcode.trim().toLowerCase() == normalized,
    );
  }

  Future<void> openSearch() async {
    final selected = await showCatalogSearchSheet(
      title: 'Search products',
      items: products
          .map(
            (product) => CatalogSearchEntry(
              key: product.id ?? product.name,
              name: product.name,
              sku: product.sku,
              barcode: product.barcode,
              subtitle: product.stockLabel,
            ),
          )
          .toList(),
    );
    if (selected == null) return;
    final product = products.firstWhereOrNull(
      (item) => (item.id ?? item.name) == selected.key,
    );
    if (product != null) addToCart(product);
  }

  Future<void> openScan() async {
    final barcode = await Get.toNamed<String>(AppRoute.getScanBarcodeScreen());
    if (barcode == null || barcode.trim().isEmpty) return;
    final product = findProductByBarcode(barcode);
    if (product == null) {
      AppHelperFunctions.showWarningSnackBar(
        'No item found for barcode $barcode.',
      );
      return;
    }
    addToCart(product);
  }

  Future<void> forceSync({bool showMessage = true}) async {
    await Future.wait([fetchCategories(), fetchItems(), fetchTables()]);
    if (showMessage) {
      AppHelperFunctions.showSuccessSnackBar('Sales data synced.');
    }
  }

  Future<void> fetchCategories() async {
    final response = await _homeRepository.fetchCategories();
    if (!response.isSuccess || response.responseData is! List) return;
    final data = List<dynamic>.from(response.responseData as List);
    await OfflineDatabaseService.saveCache('categories', data);
    _applyCategories(data);
  }

  Future<void> fetchItems() async {
    isLoadingCatalog.value = true;
    final response = await _homeRepository.fetchItems();
    isLoadingCatalog.value = false;
    if (!response.isSuccess) return;
    final data = response.responseData is Map
        ? List<dynamic>.from(
            (response.responseData as Map)['items'] as List? ?? <dynamic>[],
          )
        : List<dynamic>.from(response.responseData as List? ?? <dynamic>[]);
    await OfflineDatabaseService.saveCache('items', data);
    _applyItems(data);
  }

  Future<void> fetchTables() async {
    isLoadingTables.value = true;
    final response = await _homeRepository.fetchTables();
    isLoadingTables.value = false;
    if (!response.isSuccess || response.responseData is! Map) return;
    final data = Map<String, dynamic>.from(response.responseData as Map);
    await OfflineDatabaseService.saveCache('tables', data);
    _applyTables(data);
  }

  void _loadCachedCatalog() {
    final cachedCategories = OfflineDatabaseService.readCache<List<dynamic>>(
      'categories',
    );
    final cachedItems = OfflineDatabaseService.readCache<List<dynamic>>(
      'items',
    );
    if (cachedCategories != null) _applyCategories(cachedCategories);
    if (cachedItems != null) {
      _applyItems(cachedItems);
    }
  }

  void _loadCachedTables() {
    final cachedTables = OfflineDatabaseService.readCache<Map<String, dynamic>>(
      'tables',
    );
    if (cachedTables != null) _applyTables(cachedTables);
  }

  void _applyCategories(List<dynamic> data) {
    final names =
        data
            .whereType<Map>()
            .map((entry) => entry['name']?.toString())
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

  void _applyItems(List<dynamic> data) {
    final mapped = data.whereType<Map>().map((entry) {
      return Product.fromApi(Map<String, dynamic>.from(entry));
    }).toList();
    products.assignAll(mapped);
  }

  Future<void> addLocalItem(Map<String, dynamic> item) async {
    final cachedItems =
        OfflineDatabaseService.readCache<List<dynamic>>('items') ?? <dynamic>[];
    final nextItems = [item, ...cachedItems];
    await OfflineDatabaseService.saveCache('items', nextItems);
    _applyItems(nextItems);
  }

  void _applyTables(Map<String, dynamic> data) {
    final rawTables = data['tables'];
    if (rawTables is! List) return;
    tableOrders.assignAll(
      rawTables
          .whereType<Map>()
          .map((entry) => TableOrder.fromApi(Map<String, dynamic>.from(entry)))
          .toList(),
    );
  }
}
