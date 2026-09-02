import 'package:get/get.dart';

import '../../../core/services/permission_service.dart';
import '../../../core/utils/helpers/app_helper.dart';
import '../../../routes/app_routes.dart';

class ItemsMenuController extends GetxController {
  bool get canEditProducts =>
      PermissionService.has(AppPermission.createEditProducts);
  bool get canEditCategories =>
      PermissionService.has(AppPermission.createEditCategories);

  void openCreateItems() {
    if (!canEditProducts) {
      AppHelperFunctions.showErrorSnackBar(
        'You do not have permission to create items.',
      );
      return;
    }
    Get.toNamed(AppRoute.getCreateItemScreen());
  }

  void openCategory() {
    if (!canEditCategories) {
      AppHelperFunctions.showErrorSnackBar(
        'You do not have permission to manage categories.',
      );
      return;
    }
    Get.toNamed(AppRoute.getCategoryListScreen());
  }

  void openModifiers() {}

  void openDiscounts() {}

  void goToBackOffice() {}

  void dismissHint() {}
}
