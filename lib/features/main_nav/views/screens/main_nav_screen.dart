import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/common/widgets/app_bottom_nav.dart';
import '../../../checkout/views/screens/checkout_screen.dart';
import '../../../home/views/screens/home_screen.dart';
import '../../../inventory/views/screens/inventory_screen.dart';
import '../../../more/views/screens/more_screen.dart';
import '../../../transaction/views/screens/transaction_screen.dart';
import '../../controller/main_nav_controller.dart';

class MainNavScreen extends GetView<MainNavController> {
  const MainNavScreen({super.key});

  static const _navItems = [
    BottomNavItem(label: 'Home', icon: Iconsax.home),
    BottomNavItem(label: 'Checkout', icon: Iconsax.shopping_cart),
    BottomNavItem(label: 'Transection', icon: Iconsax.refresh),
    BottomNavItem(label: 'Inventory', icon: Iconsax.box),
    BottomNavItem(label: 'More', icon: Iconsax.menu),
  ];

  static const _tabs = [
    HomeScreen(),
    CheckoutScreen(),
    TransactionScreen(),
    InventoryScreen(),
    MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () =>
            IndexedStack(index: controller.currentIndex.value, children: _tabs),
      ),
      bottomNavigationBar: Obx(
        () => AppBottomNav(
          items: _navItems,
          selectedIndex: controller.currentIndex.value,
          onSelected: controller.changeTab,
        ),
      ),
    );
  }
}
