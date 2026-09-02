import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/offline_database_service.dart';
import '../../../core/services/permission_service.dart';
import '../../../core/services/sync_service.dart';
import '../../../core/utils/helpers/app_helper.dart';
import '../../../routes/app_routes.dart';
import '../data/category_repository.dart';
import '../models/category_model.dart';

class CategoryController extends GetxController {
  final CategoryRepository _repository;

  CategoryController({CategoryRepository? repository})
    : _repository = repository ?? HttpCategoryRepository();

  final categories = <CategoryModel>[].obs;
  final isLoading = false.obs;

  bool get canEdit => PermissionService.has(AppPermission.createEditCategories);

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    isLoading.value = true;
    final response = await _repository.fetchAdminCategories();
    isLoading.value = false;
    if (!response.isSuccess || response.responseData is! Map) {
      AppHelperFunctions.showErrorSnackBar(response.errorMessage);
      return;
    }
    final raw = (response.responseData as Map)['categories'];
    categories.assignAll(
      raw is List
          ? raw.whereType<Map>().map(
              (value) =>
                  CategoryModel.fromJson(Map<String, dynamic>.from(value)),
            )
          : const <CategoryModel>[],
    );
  }

  Future<void> openCreate() async {
    if (!canEdit) {
      _permissionDenied();
      return;
    }
    final saved = await Get.toNamed(AppRoute.getCategoryFormScreen());
    if (saved is CategoryModel) await fetchCategories();
  }

  Future<void> openEdit(CategoryModel category) async {
    if (!canEdit) {
      _permissionDenied();
      return;
    }
    final saved = await Get.toNamed(
      AppRoute.getCategoryFormScreen(),
      arguments: category,
    );
    if (saved is CategoryModel) await fetchCategories();
  }

  Future<void> delete(CategoryModel category) async {
    if (!canEdit) {
      _permissionDenied();
      return;
    }
    if (!_isOnline) {
      AppHelperFunctions.showWarningSnackBar(
        'Connect to the internet to delete a category.',
      );
      return;
    }
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete category?'),
        content: Text(
          category.itemCount > 0
              ? '${category.name} is assigned to ${category.itemCount} item(s) and cannot be deleted.'
              : 'Delete ${category.name}? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          if (category.itemCount == 0)
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Delete'),
            ),
        ],
      ),
    );
    if (confirmed != true) return;
    final response = await _repository.deleteCategory(category.id);
    if (!response.isSuccess) {
      AppHelperFunctions.showErrorSnackBar(response.errorMessage);
      return;
    }
    categories.removeWhere((entry) => entry.id == category.id);
    await _refreshPickerCache();
    AppHelperFunctions.showSuccessSnackBar('Category deleted.');
  }

  bool get _isOnline =>
      !Get.isRegistered<SyncService>() ||
      Get.find<SyncService>().isOnline.value;

  Future<void> _refreshPickerCache() async {
    final response = await _repository.fetchCategories();
    if (response.isSuccess && response.responseData is List) {
      await OfflineDatabaseService.saveCache(
        'categories',
        List<dynamic>.from(response.responseData as List),
      );
    }
  }

  void _permissionDenied() => AppHelperFunctions.showErrorSnackBar(
    'You do not have permission to manage categories.',
  );
}

class CategoryFormController extends GetxController {
  final CategoryRepository _repository;

  CategoryFormController({CategoryRepository? repository})
    : _repository = repository ?? HttpCategoryRepository();

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final isActive = true.obs;
  final isSaving = false.obs;
  CategoryModel? category;

  bool get isEditing => category != null;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is CategoryModel) {
      category = Get.arguments as CategoryModel;
      nameController.text = category!.name;
      descriptionController.text = category!.description ?? '';
      isActive.value = category!.isActive;
    }
  }

  Future<void> save() async {
    if (isSaving.value) return;
    if (!PermissionService.has(AppPermission.createEditCategories)) {
      AppHelperFunctions.showErrorSnackBar(
        'You do not have permission to manage categories.',
      );
      return;
    }
    final name = nameController.text.trim();
    if (name.isEmpty) {
      AppHelperFunctions.showWarningSnackBar('Category name is required.');
      return;
    }
    final online =
        !Get.isRegistered<SyncService>() ||
        Get.find<SyncService>().isOnline.value;
    if (!online) {
      AppHelperFunctions.showWarningSnackBar(
        'Connect to the internet to create or edit a category.',
      );
      return;
    }

    isSaving.value = true;
    final payload = {
      'name': name,
      if (descriptionController.text.trim().isNotEmpty)
        'description': descriptionController.text.trim(),
      'isActive': isActive.value,
    };
    final response = isEditing
        ? await _repository.updateCategory(category!.id, payload)
        : await _repository.createCategory(payload);
    isSaving.value = false;
    if (!response.isSuccess || response.responseData is! Map) {
      AppHelperFunctions.showErrorSnackBar(response.errorMessage);
      return;
    }
    final saved = CategoryModel.fromJson(
      Map<String, dynamic>.from(response.responseData as Map),
    );
    final activeResponse = await _repository.fetchCategories();
    if (activeResponse.isSuccess && activeResponse.responseData is List) {
      await OfflineDatabaseService.saveCache(
        'categories',
        List<dynamic>.from(activeResponse.responseData as List),
      );
    }
    Get.back(result: saved);
    AppHelperFunctions.showSuccessSnackBar(
      isEditing ? 'Category updated.' : 'Category created.',
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
