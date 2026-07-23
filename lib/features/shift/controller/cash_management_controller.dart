import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CashManagementController extends GetxController {
  final amountController = TextEditingController();
  final noteController = TextEditingController();

  void payIn() => Get.back();

  void payOut() => Get.back();

  @override
  void onClose() {
    amountController.dispose();
    noteController.dispose();
    super.onClose();
  }
}
