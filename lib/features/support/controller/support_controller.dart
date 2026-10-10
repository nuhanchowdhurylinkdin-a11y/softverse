import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/network_caller.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/constants/api_constants.dart';
import '../../../core/utils/helpers/app_helper.dart';

class SupportFaq {
  final String question;
  final String answer;

  const SupportFaq({required this.question, required this.answer});
}

class SupportController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();

  final faqs = <SupportFaq>[].obs;
  final isLoadingFaqs = false.obs;
  final isSending = false.obs;

  late final emailController = TextEditingController(
    text: StorageService.email ?? '',
  );
  final phoneController = TextEditingController();
  final messageController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchFaqs();
  }

  Future<void> fetchFaqs() async {
    isLoadingFaqs.value = true;
    final response = await _networkCaller.getRequest(ApiConstants.helpFaqs);
    isLoadingFaqs.value = false;
    if (!response.isSuccess || response.responseData is! Map) return;
    final raw = (response.responseData as Map)['faqs'];
    if (raw is! List) return;
    faqs.assignAll(
      raw.whereType<Map>().map(
        (json) => SupportFaq(
          question: json['question']?.toString() ?? '',
          answer: json['answer']?.toString() ?? '',
        ),
      ),
    );
  }

  Future<void> submit() async {
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final message = messageController.text.trim();
    if (!GetUtils.isEmail(email)) {
      AppHelperFunctions.showWarningSnackBar('Enter a valid email.');
      return;
    }
    if (phone.isEmpty) {
      AppHelperFunctions.showWarningSnackBar('Enter a contact number.');
      return;
    }
    if (message.length < 5) {
      AppHelperFunctions.showWarningSnackBar('Describe the problem a bit more.');
      return;
    }

    isSending.value = true;
    final response = await _networkCaller.postRequest(
      ApiConstants.helpContact,
      body: {'email': email, 'contactNumber': phone, 'message': message},
    );
    isSending.value = false;

    if (!response.isSuccess) {
      AppHelperFunctions.showErrorSnackBar(response.errorMessage);
      return;
    }
    messageController.clear();
    AppHelperFunctions.showSuccessSnackBar('Request sent. We\'ll contact you.');
  }

  @override
  void onClose() {
    emailController.dispose();
    phoneController.dispose();
    messageController.dispose();
    super.onClose();
  }
}
