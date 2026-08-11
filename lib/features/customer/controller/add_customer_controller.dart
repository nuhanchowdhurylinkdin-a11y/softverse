import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/utils/helpers/app_helper.dart';
import '../models/customer_model.dart';
import 'customer_controller.dart';

class AddCustomerController extends GetxController {
  final ImagePicker _imagePicker = ImagePicker();
  final isSaving = false.obs;
  final selectedImage = Rxn<File>();
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
    final created = await Get.find<CustomerController>().createCustomer(
      CustomerModel(
        name: nameController.text,
        email: emailController.text,
        phone: phoneController.text,
        address: addressController.text,
        city: cityController.text,
        region: regionController.text,
        postalCode: postalCodeController.text,
        country: countryController.text,
        customerCode: customerCodeController.text,
        imageUrl: '',
        note: noteController.text,
        creditLimit:
            double.tryParse(creditLimitController.text.replaceAll(',', '')) ??
            0,
      ),
      image: selectedImage.value,
    );
    isSaving.value = false;
    if (created) {
      Get.back();
      await Future<void>.delayed(const Duration(milliseconds: 120));
      AppHelperFunctions.showSuccessSnackBar('Customer created.');
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
