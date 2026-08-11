import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/utils/helpers/app_helper.dart';
import '../models/customer_model.dart';
import 'customer_controller.dart';

class EditCustomerController extends GetxController {
  final ImagePicker _imagePicker = ImagePicker();
  final CustomerController _customerController = Get.find<CustomerController>();

  late final customer = _customerController.customer.value;
  final selectedImage = Rxn<File>();
  final isSaving = false.obs;

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

  Future<void> choosePhoto() async {
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) selectedImage.value = File(image.path);
  }

  Future<void> save() async {
    if (nameController.text.trim().isEmpty) {
      AppHelperFunctions.showWarningSnackBar('Enter customer name.');
      return;
    }

    isSaving.value = true;
    final updated = await _customerController.updateCustomer(
      CustomerModel(
        id: customer.id,
        name: nameController.text,
        email: emailController.text,
        phone: phoneController.text,
        address: addressController.text,
        city: cityController.text,
        region: regionController.text,
        postalCode: postalCodeController.text,
        country: countryController.text,
        customerCode: customerCodeController.text,
        imageUrl: customer.imageUrl,
        creditLimit:
            double.tryParse(creditLimitController.text.replaceAll(',', '')) ??
            customer.creditLimit,
        note: noteController.text,
      ),
      image: selectedImage.value,
    );
    isSaving.value = false;
    if (updated) {
      Get.back();
      await Future<void>.delayed(const Duration(milliseconds: 120));
      AppHelperFunctions.showSuccessSnackBar('Customer updated.');
    }
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
