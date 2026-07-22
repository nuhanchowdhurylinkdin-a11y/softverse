import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/common/widgets/floating_icon_button.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../controller/home_controller.dart';
import '../../widgets/category_tabs.dart';
import '../../widgets/order_summary_card.dart';
import '../../widgets/order_tab_selector.dart';
import '../../widgets/pos_app_bar.dart';
import '../../widgets/product_row.dart';
import '../../widgets/table_order_card.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                PosAppBar(title: 'POS-1'),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Obx(
                          () => OrderTabSelector(
                            isOrderSelected: controller.isOrderTabSelected.value,
                            onOrderTap: controller.selectOrderTab,
                            onTableTap: controller.selectTableTab,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Obx(
                          () => controller.isOrderTabSelected.value
                              ? _OrderTabBody(controller: controller)
                              : _TableTabBody(controller: controller),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Obx(
              () => controller.isOrderTabSelected.value
                  ? Positioned(
                      right: 16.w,
                      bottom: 16.h,
                      child: Column(
                        children: [
                          FloatingIconButton(
                            icon: Iconsax.search_normal,
                            backgroundColor: AppColors.chipBackground,
                            iconColor: AppColors.onboardingBackground,
                            onTap: controller.openSearch,
                          ),
                          SizedBox(height: 15.h),
                          FloatingIconButton(
                            icon: Iconsax.scan,
                            backgroundColor: AppColors.onboardingBackground,
                            iconColor: Colors.white,
                            onTap: controller.openScan,
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderTabBody extends StatelessWidget {
  final HomeController controller;

  const _OrderTabBody({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OrderSummaryCard(
          orderId: controller.orderId,
          itemCount: controller.orderItemCount,
          total: controller.orderTotal,
          onCheckout: controller.checkout,
        ),
        SizedBox(height: 16.h),
        Obx(
          () => CategoryTabs(
            categories: controller.categories,
            selectedIndex: controller.selectedCategoryIndex.value,
            onSelected: controller.selectCategory,
          ),
        ),
        SizedBox(height: 16.h),
        ...controller.products.map(
          (product) => Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: ProductRow(
              product: product,
              onAdd: () => controller.addToCart(product),
            ),
          ),
        ),
      ],
    );
  }
}

class _TableTabBody extends StatelessWidget {
  final HomeController controller;

  const _TableTabBody({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: controller.tableOrders
          .map(
            (tableOrder) => Padding(
              padding: EdgeInsets.only(bottom: 24.h),
              child: TableOrderCard(
                tableOrder: tableOrder,
                onOpenOrder: () => controller.openTableOrder(tableOrder),
              ),
            ),
          )
          .toList(),
    );
  }
}
