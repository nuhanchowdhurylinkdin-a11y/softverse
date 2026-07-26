import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddCustomerController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final regionController = TextEditingController();
  final postalCodeController = TextEditingController();
  final countryController = TextEditingController();
  final customerCodeController = TextEditingController();
  final noteController = TextEditingController();

  void choosePhoto() {}

  void save() => Get.back();

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    cityController.dispose();
    regionController.dispose();
    postalCodeController.dispose();
    countryController.dispose();
    customerCodeController.dispose();
    noteController.dispose();
    super.onClose();
  }
}
