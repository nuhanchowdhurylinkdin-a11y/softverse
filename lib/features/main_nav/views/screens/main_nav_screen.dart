import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../checkout/views/screens/checkout_screen.dart';
import '../../../home/views/screens/home_screen.dart';
import '../../../inventory/views/screens/inventory_screen.dart';
import '../../../more/views/screens/more_screen.dart';
import '../../../transaction/views/screens/transaction_screen.dart';
import '../../controller/main_nav_controller.dart';

class MainNavScreen extends GetView<MainNavController> {
  const MainNavScreen({super.key});

  static const _tabs = [
    HomeScreen(),
    CheckoutScreen(),
    TransactionScreen(),
    InventoryScreen(),
    MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => IndexedStack(index: controller.currentIndex.value, children: _tabs),
    );
  }
}
