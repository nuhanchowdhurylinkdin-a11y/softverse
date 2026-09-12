import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/permission_service.dart';
import '../../../core/utils/helpers/app_helper.dart';
import '../../../routes/app_routes.dart';
import '../data/discount_repository.dart';
import '../models/discount_rule_model.dart';

class DiscountController extends GetxController {
  final DiscountRepository _repository;

  DiscountController({DiscountRepository? repository})
    : _repository = repository ?? HttpDiscountRepository();

  final discounts = <DiscountRuleModel>[].obs;
  final isLoading = false.obs;

  bool get canEdit => PermissionService.has(AppPermission.giveDiscount);

  @override
  void onInit() {
    super.onInit();
    fetchDiscounts();
  }

  Future<void> fetchDiscounts() async {
    isLoading.value = true;
    final response = await _repository.fetchDiscountRules();
    isLoading.value = false;
    if (!response.isSuccess || response.responseData is! Map) {
      AppHelperFunctions.showErrorSnackBar(response.errorMessage);
      return;
    }
    final raw = (response.responseData as Map)['discounts'];
    discounts.assignAll(
      raw is List
          ? raw.whereType<Map>().map(
              (value) => DiscountRuleModel.fromJson(
                Map<String, dynamic>.from(value),
              ),
            )
          : const <DiscountRuleModel>[],
    );
  }

  Future<void> openCreate() async {
    if (!canEdit) {
      _permissionDenied();
      return;
    }
    final saved = await Get.toNamed(AppRoute.getDiscountFormScreen());
    if (saved is DiscountRuleModel) await fetchDiscounts();
  }

  Future<void> openEdit(DiscountRuleModel discount) async {
    if (!canEdit) {
      _permissionDenied();
      return;
    }
    final saved = await Get.toNamed(
      AppRoute.getDiscountFormScreen(),
      arguments: discount,
    );
    if (saved is DiscountRuleModel) await fetchDiscounts();
  }

  Future<void> delete(DiscountRuleModel discount) async {
    if (!canEdit) {
      _permissionDenied();
      return;
    }
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete discount?'),
        content: Text('Delete ${discount.name}? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final response = await _repository.deleteDiscountRule(discount.id);
    if (!response.isSuccess) {
      AppHelperFunctions.showErrorSnackBar(response.errorMessage);
      return;
    }
    discounts.removeWhere((entry) => entry.id == discount.id);
    AppHelperFunctions.showSuccessSnackBar('Discount deleted.');
  }

  void _permissionDenied() => AppHelperFunctions.showErrorSnackBar(
    'You do not have permission to manage discounts.',
  );
}

class DiscountFormController extends GetxController {
  final DiscountRepository _repository;

  DiscountFormController({DiscountRepository? repository})
    : _repository = repository ?? HttpDiscountRepository();

  final nameController = TextEditingController();
  final valueController = TextEditingController();
  final isPercentage = true.obs;
  final restrictedAccess = false.obs;
  final isActive = true.obs;
  final isSaving = false.obs;
  DiscountRuleModel? discount;

  bool get isEditing => discount != null;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is DiscountRuleModel) {
      discount = Get.arguments as DiscountRuleModel;
      nameController.text = discount!.name;
      valueController.text = discount!.value == discount!.value.roundToDouble()
          ? discount!.value.toStringAsFixed(0)
          : discount!.value.toString();
      isPercentage.value = discount!.type != 'amount';
      restrictedAccess.value = discount!.restrictedAccess;
      isActive.value = discount!.isActive;
    }
  }

  void setType(bool percentage) => isPercentage.value = percentage;

  void toggleRestrictedAccess() =>
      restrictedAccess.value = !restrictedAccess.value;

  Map<String, dynamic>? buildPayload() {
    final name = nameController.text.trim();
    final value = double.tryParse(valueController.text.trim());
    if (name.isEmpty || value == null || value < 0) return null;
    return {
      'name': name,
      'type': isPercentage.value ? 'percentage' : 'amount',
      'value': value,
      'restrictedAccess': restrictedAccess.value,
      'isActive': isActive.value,
    };
  }

  Future<void> save() async {
    if (isSaving.value) return;
    if (!PermissionService.has(AppPermission.giveDiscount)) {
      AppHelperFunctions.showErrorSnackBar(
        'You do not have permission to manage discounts.',
      );
      return;
    }
    final payload = buildPayload();
    if (payload == null) {
      AppHelperFunctions.showWarningSnackBar(
        'Enter a discount name and a valid value.',
      );
      return;
    }

    isSaving.value = true;
    final response = isEditing
        ? await _repository.updateDiscountRule(discount!.id, payload)
        : await _repository.createDiscountRule(payload);
    isSaving.value = false;
    if (!response.isSuccess || response.responseData is! Map) {
      AppHelperFunctions.showErrorSnackBar(response.errorMessage);
      return;
    }
    final saved = DiscountRuleModel.fromJson(
      Map<String, dynamic>.from(response.responseData as Map),
    );
    Get.back(result: saved);
    AppHelperFunctions.showSuccessSnackBar(
      isEditing ? 'Discount updated.' : 'Discount created.',
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    valueController.dispose();
    super.onClose();
  }
}
