import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/helpers/app_helper.dart';
import 'customer_controller.dart';

class EditCustomerController extends GetxController {
  final CustomerController _customerController = Get.find<CustomerController>();

  late final customer = _customerController.customer.value;

  late final nameController = TextEditingController(text: customer.name);
  late final emailController = TextEditingController(text: customer.email);
  late final phoneController = TextEditingController(text: customer.phone);
  late final addressController = TextEditingController(text: customer.address);
  late final cityController = TextEditingController(text: customer.city);
  late final regionController = TextEditingController(text: customer.region);
  late final postalCodeController = TextEditingController(
    text: customer.postalCode,
  );
  late final countryController = TextEditingController(text: customer.country);
  late final customerCodeController = TextEditingController(
    text: customer.customerCode,
  );
  late final creditLimitController = TextEditingController(
    text: AppHelperFunctions.getFormattedMoney(customer.creditLimit),
  );
  late final noteController = TextEditingController(text: customer.note);

  void save() {
    _customerController.customer.value = customer.copyWith(
      name: nameController.text,
      email: emailController.text,
      phone: phoneController.text,
      address: addressController.text,
      city: cityController.text,
      region: regionController.text,
      postalCode: postalCodeController.text,
      country: countryController.text,
      customerCode: customerCodeController.text,
      creditLimit:
          double.tryParse(creditLimitController.text.replaceAll(',', '')) ??
          customer.creditLimit,
      note: noteController.text,
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
