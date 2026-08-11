import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../models/shift_record.dart';
import 'shift_controller.dart';

class CloseShiftController extends GetxController {
  final ShiftController _shiftController = Get.find<ShiftController>();
  final actualCashController = TextEditingController();

  ShiftRecord get shift => _shiftController.currentShift.value!;

  double get actualCashAmount =>
      double.tryParse(
        actualCashController.text.replaceAll(',', '').replaceAll('\$', ''),
      ) ??
      shift.expectedCashAmount;

  double get difference => actualCashAmount - shift.expectedCashAmount;

  @override
  void onInit() {
    super.onInit();
    actualCashController.text = shift.expectedCashAmount.toStringAsFixed(2);
  }

  Future<void> closeShift() async {
    final closed = await _shiftController.closeShift(actualCashAmount);
    if (closed) Get.back();
  }

  @override
  void onClose() {
    actualCashController.dispose();
    super.onClose();
  }
}
