import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'shift_controller.dart';

class CashManagementController extends GetxController {
  final amountController = TextEditingController();
  final noteController = TextEditingController();

  Future<void> payIn() => _submit('pay_in');

  Future<void> payOut() => _submit('pay_out');

  Future<void> _submit(String type) async {
    final amount =
        double.tryParse(
          amountController.text.replaceAll(',', '').replaceAll('\$', ''),
        ) ??
        0;
    final saved = await Get.find<ShiftController>().addMovement(
      type,
      amount,
      noteController.text,
    );
    if (saved) Get.back();
  }

  @override
  void onClose() {
    amountController.dispose();
    noteController.dispose();
    super.onClose();
  }
}
