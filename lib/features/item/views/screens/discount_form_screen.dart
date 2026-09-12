import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/discount_controller.dart';

class DiscountFormScreen extends GetView<DiscountFormController> {
  const DiscountFormScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(controller.isEditing ? 'Edit Discount' : 'Create Discount'),
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: controller.nameController,
          maxLength: 120,
          decoration: const InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('Percentage (%)')),
              ButtonSegment(value: false, label: Text('Fixed amount')),
            ],
            selected: {controller.isPercentage.value},
            onSelectionChanged: (selection) =>
                controller.setType(selection.first),
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => TextField(
            controller: controller.valueController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: InputDecoration(
              labelText: controller.isPercentage.value
                  ? 'Discount percentage'
                  : 'Discount amount',
              suffixText: controller.isPercentage.value ? '%' : null,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Restricted access'),
            subtitle: const Text(
              'Only owners, administrators, and managers can apply this discount at checkout.',
            ),
            value: controller.restrictedAccess.value,
            onChanged: (_) => controller.toggleRestrictedAccess(),
          ),
        ),
        if (controller.isEditing)
          Obx(
            () => SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Active'),
              subtitle: const Text(
                'Inactive discounts cannot be applied at checkout.',
              ),
              value: controller.isActive.value,
              onChanged: (value) => controller.isActive.value = value,
            ),
          ),
        const SizedBox(height: 16),
        Obx(
          () => FilledButton(
            onPressed: controller.isSaving.value ? null : controller.save,
            child: controller.isSaving.value
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ),
      ],
    ),
  );
}
