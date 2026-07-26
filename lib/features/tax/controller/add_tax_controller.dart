import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/helpers/app_helper.dart';
import '../../../routes/app_routes.dart';
import '../models/tax_model.dart';
import 'tax_controller.dart';

class AddTaxController extends GetxController {
  final TaxController _taxController = Get.find<TaxController>();

  final nameController = TextEditingController();
  final rateController = TextEditingController();

  final Rxn<TaxType> type = Rxn<TaxType>();
  final appliedItemIds = <String>[].obs;

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

    _taxController.addTax(
      TaxModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        ratePercent: rate,
        type: type.value!,
        appliedItemIds: appliedItemIds,
      ),
    );
    Get.back();
  }

  @override
  void onClose() {
    nameController.dispose();
    rateController.dispose();
    super.onClose();
  }
}
