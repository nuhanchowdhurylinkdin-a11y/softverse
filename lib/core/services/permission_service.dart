import 'storage_service.dart';

class AppPermission {
  static const createEditProducts = 'create_edit_products';
  static const createEditCategories = 'create_edit_categories';
}

class PermissionService {
  PermissionService._();

  static bool has(String permission) {
    final saved = StorageService.permissions;
    if (saved.isNotEmpty) return saved.contains(permission);

    // Compatibility for sessions created before permissions were cached.
    return const {
      'owner',
      'administrator',
      'manager',
    }.contains(StorageService.role?.toLowerCase());
  }
}
