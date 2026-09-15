import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/helpers/app_helper.dart';
import '../../controller/customer_due_orders_controller.dart';
import '../../models/due_order_model.dart';

class CustomerDueOrdersScreen extends GetView<CustomerDueOrdersController> {
  const CustomerDueOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Obx(() => Text(controller.customerName.value)),
    ),
    body: Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.orders.isEmpty) {
        return const Center(child: Text('No outstanding due orders.'));
      }
      return RefreshIndicator(
        onRefresh: controller.fetchDueOrders,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: ListTile(
                title: const Text('Total outstanding'),
                trailing: Text(
                  AppHelperFunctions.getFormattedMoney(controller.totalDue.value),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ...controller.orders.map(
              (order) => Card(
                child: ListTile(
                  title: Text(order.orderNumber),
                  subtitle: Text(
                    order.date == null
                        ? 'Total: ${AppHelperFunctions.getFormattedMoney(order.totalAmount)}'
                        : '${AppHelperFunctions.getFormattedDate(order.date!, format: 'dd MMM yyyy')} • Total: ${AppHelperFunctions.getFormattedMoney(order.totalAmount)}',
                  ),
                  trailing: Obx(
                    () => TextButton(
                      onPressed:
                          controller.collectingOrderId.value == order.checkoutOrderId
                          ? null
                          : () => _showCollectPaymentDialog(context, order),
                      child:
                          controller.collectingOrderId.value ==
                              order.checkoutOrderId
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              'Collect ${AppHelperFunctions.getFormattedMoney(order.amountDue)}',
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }),
  );

  void _showCollectPaymentDialog(BuildContext context, DueOrderModel order) {
    final amountController = TextEditingController(
      text: order.amountDue.toStringAsFixed(2),
    );
    Get.dialog<void>(
      AlertDialog(
        title: Text('Collect Payment - ${order.orderNumber}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Outstanding balance: ${AppHelperFunctions.getFormattedMoney(order.amountDue)}',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Amount received',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text.trim());
              Get.back();
              if (amount != null) controller.collectPayment(order, amount);
            },
            child: const Text('Collect'),
          ),
        ],
      ),
    );
  }
}
