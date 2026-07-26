import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/helpers/app_helper.dart';
import '../../../routes/app_routes.dart';
import '../models/tax_model.dart';
import 'tax_controller.dart';

class EditTaxController extends GetxController {
  final TaxController _taxController = Get.find<TaxController>();

  String get taxId => Get.arguments as String;

  late final TaxModel tax = _taxController.taxById(taxId)!;

  late final nameController = TextEditingController(text: tax.name);
  late final rateController = TextEditingController(
    text: formatTaxRate(tax.ratePercent),
  );

  late final Rxn<TaxType> type = Rxn<TaxType>(tax.type);
  late final appliedItemIds = <String>[...tax.appliedItemIds].obs;

  void setType(TaxType selected) => type.value = selected;

  Future<void> openApplyToItems() async {
    final result = await Get.toNamed(
      AppRoute.getApplyTaxItemsScreen(),
      arguments: appliedItemIds.toList(),
    );
    if (result is List<String>) {
      appliedItemIds.assignAll(result);
    }
  }

  void save() {
    final name = nameController.text.trim();
    final rate = double.tryParse(rateController.text.trim());
    if (name.isEmpty || rate == null || type.value == null) {
      AppHelperFunctions.showWarningSnackBar(
        'Enter a name, a valid tax rate, and select a tax type.',
      );
      return;
    }

    _taxController.updateTax(
      tax.copyWith(
        name: name,
        ratePercent: rate,
        type: type.value,
        appliedItemIds: appliedItemIds,
      ),
    );
    Get.back();
  }

  void remove() {
    _taxController.removeTax(taxId);
    Get.back();
  }

  @override
  void onClose() {
    nameController.dispose();
    rateController.dispose();
    super.onClose();
  }
}
