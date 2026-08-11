import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import 'shift_controller.dart';

class OpenShiftController extends GetxController {
  final amountController = TextEditingController();

  Future<void> openShift() async {
    final amount =
        double.tryParse(
          amountController.text.replaceAll(',', '').replaceAll('\$', ''),
        ) ??
        0;
    final opened = await Get.find<ShiftController>().openShift(amount);
    if (opened) Get.offAllNamed(AppRoute.getHomeScreen());
  }

  void openShiftHistory() => Get.toNamed(AppRoute.getShiftListScreen());

  @override
  void onClose() {
    amountController.dispose();
    super.onClose();
  }
}
