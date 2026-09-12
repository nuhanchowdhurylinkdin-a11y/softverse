import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/discount_controller.dart';

class DiscountListScreen extends GetView<DiscountController> {
  const DiscountListScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Discounts')),
    floatingActionButton: controller.canEdit
        ? FloatingActionButton(
            onPressed: controller.openCreate,
            child: const Icon(Icons.add),
          )
        : null,
    body: Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.discounts.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('No discounts yet.'),
              if (controller.canEdit)
                TextButton(
                  onPressed: controller.openCreate,
                  child: const Text('Create Discount'),
                ),
            ],
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: controller.fetchDiscounts,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.discounts.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (_, index) {
            final discount = controller.discounts[index];
            return ListTile(
              title: Text(discount.name),
              subtitle: Text(
                '${discount.displayValue} off'
                '${discount.restrictedAccess ? ' • Restricted access' : ''}'
                '${discount.isActive ? '' : ' • Inactive'}',
              ),
              onTap: controller.canEdit
                  ? () => controller.openEdit(discount)
                  : null,
              trailing: controller.canEdit
                  ? IconButton(
                      tooltip: 'Delete discount',
                      onPressed: () => controller.delete(discount),
                      icon: const Icon(Icons.delete_outline),
                    )
                  : null,
            );
          },
        ),
      );
    }),
  );
}
