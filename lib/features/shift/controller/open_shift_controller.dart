import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../../main_nav/controller/main_nav_controller.dart';
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
    if (!opened) return;
    if (Get.isRegistered<MainNavController>()) {
      Get.find<MainNavController>().changeTab(4);
    }
    Get.until((route) => route.settings.name == AppRoute.getHomeScreen());
  }

  void openShiftHistory() => Get.toNamed(AppRoute.getShiftListScreen());

  @override
  void onClose() {
    amountController.dispose();
    super.onClose();
  }
}
