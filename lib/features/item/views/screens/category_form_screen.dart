import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/category_controller.dart';
import '../../widgets/color_shape_picker.dart';

class CategoryFormScreen extends GetView<CategoryFormController> {
  const CategoryFormScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(controller.isEditing ? 'Edit Category' : 'Create Category'),
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
        TextField(
          controller: controller.descriptionController,
          maxLength: 500,
          minLines: 3,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: 'Description (optional)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'POS color and shape',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Obx(
          () => ColorShapePicker(
            selectedColorIndex: controller.selectedColorIndex.value,
            onColorSelected: controller.selectColor,
            selectedShapeIndex: controller.selectedShapeIndex.value,
            onShapeSelected: controller.selectShape,
          ),
        ),
        if (controller.isEditing)
          Obx(
            () => SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Active'),
              subtitle: const Text(
                'Inactive categories cannot be selected for items.',
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
