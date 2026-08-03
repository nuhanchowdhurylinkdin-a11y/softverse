import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/customer_model.dart';
import 'customer_controller.dart';

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
  final creditLimitController = TextEditingController();
  final noteController = TextEditingController();

  void choosePhoto() {}

  void save() {
    Get.find<CustomerController>().customer.value = CustomerModel(
      name: nameController.text,
      email: emailController.text,
      phone: phoneController.text,
      address: addressController.text,
      city: cityController.text,
      region: regionController.text,
      postalCode: postalCodeController.text,
      country: countryController.text,
      customerCode: customerCodeController.text,
      imageUrl: 'https://randomuser.me/api/portraits/men/45.jpg',
      note: noteController.text,
      creditLimit:
          double.tryParse(creditLimitController.text.replaceAll(',', '')) ?? 0,
    );
    Get.back();
  }

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
    creditLimitController.dispose();
    noteController.dispose();
    super.onClose();
  }
}
