import 'package:get/get.dart';

import '../../../core/utils/constants/product_images.dart';
import '../../../routes/app_routes.dart';
import '../models/inventory_product.dart';

class InventoryController extends GetxController {
  final selectedCategoryIndex = 0.obs;

  final categories = const [
    'All Item',
    'PC Components',
    'Monitor & Display',
    'Input Devices',
    'Audio',
    'Gaming Accessories',
    'Networking',
    'Laptop & Accessories',
    'Storage Devices',
    'Printers & Office',
    'Cables & Adapters',
    'Software & Licenses',
  ];

  final products = const [
    InventoryProduct(
      name: 'A4Ttech Keyboard',
      sku: 'SKU-10012',
      price: 800,
      cost: 350,
      barcode: '123456789124',
      inStock: 97,
      lowStockThreshold: 10,
      imageUrl: ProductImages.keyboard,
    ),
    InventoryProduct(
      name: 'A4Ttech Keyboard',
      sku: 'SKU-10012',
      price: 800,
      cost: 350,
      barcode: '123456789124',
      inStock: 9,
      lowStockThreshold: 10,
      imageUrl: ProductImages.keyboard,
    ),
    InventoryProduct(
      name: 'A4Ttech Mouse',
      sku: 'SKU-10012',
      price: 400,
      cost: 150,
      barcode: '123456789125',
      inStock: 97,
      lowStockThreshold: 10,
      imageUrl: ProductImages.mouse,
    ),
    InventoryProduct(
      name: 'A4Ttech Mouse',
      sku: 'SKU-10012',
      price: 400,
      cost: 150,
      barcode: '123456789125',
      inStock: 97,
      lowStockThreshold: 10,
      imageUrl: ProductImages.mouse,
    ),
    InventoryProduct(
      name: 'HP Monitor',
      sku: 'SKU-10012',
      price: 18000,
      cost: 12000,
      barcode: '123456789126',
      inStock: 7,
      lowStockThreshold: 10,
      imageUrl: ProductImages.monitor,
    ),
    InventoryProduct(
      name: 'HP Monitor',
      sku: 'SKU-10012',
      price: 18000,
      cost: 12000,
      barcode: '123456789126',
      inStock: 0,
      lowStockThreshold: 10,
      imageUrl: ProductImages.monitor,
    ),
    InventoryProduct(
      name: 'HP Monitor',
      sku: 'SKU-10012',
      price: 18000,
      cost: 12000,
      barcode: '123456789126',
      inStock: 97,
      lowStockThreshold: 10,
      imageUrl: ProductImages.monitor,
    ),
    InventoryProduct(
      name: 'HP Monitor',
      sku: 'SKU-10012',
      price: 18000,
      cost: 12000,
      barcode: '123456789126',
      inStock: 0,
      lowStockThreshold: 10,
      imageUrl: ProductImages.monitor,
    ),
  ];

  void selectCategory(int index) => selectedCategoryIndex.value = index;

  void openProduct(InventoryProduct product) {
    Get.toNamed(AppRoute.getItemDetailScreen(), arguments: product);
  }

  void openSearch() {}

  void openScan() {}

  void openNotifications() {}
}
