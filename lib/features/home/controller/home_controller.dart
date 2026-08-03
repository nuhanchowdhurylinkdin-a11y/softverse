import 'package:get/get.dart';

import '../../../core/utils/helpers/app_helper.dart';
import '../../../core/utils/constants/product_images.dart';
import '../../checkout/controller/checkout_controller.dart';
import '../../main_nav/controller/main_nav_controller.dart';
import '../models/product.dart';
import '../models/table_order.dart';

class HomeController extends GetxController {
  final isOrderTabSelected = true.obs;
  final selectedCategoryIndex = 0.obs;

  final orderId = 'POS-1 Order-1';

  int get orderItemCount => Get.find<CheckoutController>().cartItems.fold(
    0,
    (sum, item) => sum + item.quantity,
  );

  double get orderTotal => Get.find<CheckoutController>().subtotal;

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
    Product(
      name: 'A4Ttech Keyboard',
      price: 800,
      stockCount: 97,
      imageUrl: ProductImages.keyboard,
    ),
    Product(
      name: 'A4Ttech Keyboard',
      price: 800,
      stockCount: 97,
      imageUrl: ProductImages.keyboard,
    ),
    Product(
      name: 'A4Ttech Mouse',
      price: 400,
      stockCount: 97,
      imageUrl: ProductImages.mouse,
    ),
    Product(
      name: 'A4Ttech Mouse',
      price: 400,
      stockCount: 97,
      imageUrl: ProductImages.mouse,
    ),
    Product(
      name: 'HP Monitor',
      price: 18000,
      stockCount: 97,
      imageUrl: ProductImages.monitor,
    ),
    Product(
      name: 'HP Monitor',
      price: 18000,
      stockCount: 97,
      imageUrl: ProductImages.monitor,
    ),
    Product(
      name: 'HP Monitor',
      price: 18000,
      stockCount: 97,
      imageUrl: ProductImages.monitor,
    ),
    Product(
      name: 'HP Monitor',
      price: 18000,
      stockCount: 97,
      imageUrl: ProductImages.monitor,
    ),
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

  void checkout() => Get.find<MainNavController>().changeTab(1);

  void addToCart(Product product) => Get.find<CheckoutController>().addProduct(
    name: product.name,
    price: product.price,
    imageUrl: product.imageUrl,
  );

  void openSearch() {}

  void openScan() {}

  Future<void> forceSync() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    AppHelperFunctions.showSuccessSnackBar('Sales data synced.');
  }
}
