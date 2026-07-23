import 'package:get/get.dart';

import '../../../core/utils/constants/product_images.dart';
import '../models/product.dart';
import '../models/table_order.dart';

class HomeController extends GetxController {
  final isOrderTabSelected = true.obs;
  final selectedCategoryIndex = 0.obs;

  final orderId = 'POS-1 Order-1';
  final orderItemCount = 5;
  final orderTotal = 15000.0;

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
    Product(name: 'A4Ttech Keyboard', price: 800, stockCount: 97, imageUrl: ProductImages.keyboard),
    Product(name: 'A4Ttech Keyboard', price: 800, stockCount: 97, imageUrl: ProductImages.keyboard),
    Product(name: 'A4Ttech Mouse', price: 400, stockCount: 97, imageUrl: ProductImages.mouse),
    Product(name: 'A4Ttech Mouse', price: 400, stockCount: 97, imageUrl: ProductImages.mouse),
    Product(name: 'HP Monitor', price: 18000, stockCount: 97, imageUrl: ProductImages.monitor),
    Product(name: 'HP Monitor', price: 18000, stockCount: 97, imageUrl: ProductImages.monitor),
    Product(name: 'HP Monitor', price: 18000, stockCount: 97, imageUrl: ProductImages.monitor),
    Product(name: 'HP Monitor', price: 18000, stockCount: 97, imageUrl: ProductImages.monitor),
  ];

  final tableOrders = const [
    TableOrder(
      tableName: 'Table-1',
      orderId: 'POS-1 Order-1',
      customerName: 'Abs Corporation',
      time: '12.05 pm',
      status: OrderStatus.complete,
    ),
    TableOrder(
      tableName: 'Table-2',
      orderId: 'POS-1 Order-5',
      customerName: 'Not registered',
      time: '12.05 pm',
      status: OrderStatus.ongoing,
    ),
    TableOrder(
      tableName: 'Table-3',
      orderId: 'POS-1 Order-7',
      customerName: 'XYZ Corporation',
      time: '12.05 pm',
      status: OrderStatus.ongoing,
    ),
  ];

  void openTableOrder(TableOrder tableOrder) {}

  void selectOrderTab() => isOrderTabSelected.value = true;

  void selectTableTab() => isOrderTabSelected.value = false;

  void selectCategory(int index) => selectedCategoryIndex.value = index;

  void checkout() {}

  void addToCart(Product product) {}

  void openSearch() {}

  void openScan() {}
}
