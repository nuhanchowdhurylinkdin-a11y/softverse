import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';

class OpenShiftController extends GetxController {
  final amountController = TextEditingController();

  void openShift() => Get.offAllNamed(AppRoute.getHomeScreen());

  void openShiftHistory() => Get.toNamed(AppRoute.getShiftListScreen());

  @override
  void onClose() {
    amountController.dispose();
    super.onClose();
  }
}
