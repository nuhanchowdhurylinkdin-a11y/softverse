import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/category_controller.dart';

class CategoryListScreen extends GetView<CategoryController> {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Categories')),
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
      if (controller.categories.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('No categories yet.'),
              if (controller.canEdit)
                TextButton(
                  onPressed: controller.openCreate,
                  child: const Text('Create Category'),
                ),
            ],
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: controller.fetchCategories,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.categories.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (_, index) {
            final category = controller.categories[index];
            return ListTile(
              title: Text(category.name),
              subtitle: Text(
                '${category.itemCount} item(s)${category.isActive ? '' : ' • Inactive'}',
              ),
              onTap: controller.canEdit
                  ? () => controller.openEdit(category)
                  : null,
              trailing: controller.canEdit
                  ? IconButton(
                      tooltip: 'Delete category',
                      onPressed: () => controller.delete(category),
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
