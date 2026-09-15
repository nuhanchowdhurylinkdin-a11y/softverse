import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/helpers/app_helper.dart';
import '../../controller/customer_due_controller.dart';

class CustomerDueListScreen extends GetView<CustomerDueController> {
  const CustomerDueListScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Due Balances')),
    body: Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.dues.isEmpty) {
        return const Center(child: Text('No outstanding due balances.'));
      }
      return RefreshIndicator(
        onRefresh: controller.fetchDues,
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
            ...controller.dues.map(
              (due) => Card(
                child: ListTile(
                  title: Text(due.customerName),
                  subtitle: Text(
                    '${due.dueOrderCount} due order(s)'
                    '${due.phone?.isNotEmpty == true ? ' • ${due.phone}' : ''}',
                  ),
                  trailing: Text(
                    AppHelperFunctions.getFormattedMoney(due.amountDue),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  onTap: () => controller.openCustomerDueOrders(due),
                ),
              ),
            ),
          ],
        ),
      );
    }),
  );
}
