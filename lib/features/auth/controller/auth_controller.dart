import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';

class AuthController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final fullNameController = TextEditingController();
  final businessNameController = TextEditingController();
  final createPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final emailOrMobileController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();

  final List<TextEditingController> otpControllers =
      List.generate(5, (_) => TextEditingController());
  final List<FocusNode> otpFocusNodes = List.generate(5, (_) => FocusNode());

  final obscureNewPassword = true.obs;
  final obscureConfirmNewPassword = true.obs;
  final isResetSubmitting = false.obs;

  void toggleObscureNewPassword() => obscureNewPassword.toggle();

  void toggleObscureConfirmNewPassword() => obscureConfirmNewPassword.toggle();

  void login() => Get.offAllNamed(AppRoute.getWalkthroughScreen());

  void register() => Get.offAllNamed(AppRoute.getWalkthroughScreen());

  void goToForgotPassword() => Get.toNamed(AppRoute.getForgetPasswordScreen());

  void goToRegistration() => Get.toNamed(AppRoute.getRegistrationScreen());

  void goToSignIn() => Get.toNamed(AppRoute.getLoginScreen());

  void continueForgotPassword() => Get.toNamed(AppRoute.getEnterOtpScreen());

  void resendOtp() {}

  void submitOtp() => Get.toNamed(AppRoute.getResetPasswordScreen());

  void onOtpChanged(int index, String value) {
    if (value.isNotEmpty && index < otpFocusNodes.length - 1) {
      otpFocusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      otpFocusNodes[index - 1].requestFocus();
    }
  }

  Future<void> submitResetPassword() async {
    isResetSubmitting.value = true;
    await Future.delayed(const Duration(seconds: 2));
    isResetSubmitting.value = false;
    Get.offAllNamed(AppRoute.getLoginScreen());
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    fullNameController.dispose();
    businessNameController.dispose();
    createPasswordController.dispose();
    confirmPasswordController.dispose();
    emailOrMobileController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    for (final c in otpControllers) {
      c.dispose();
    }
    for (final f in otpFocusNodes) {
      f.dispose();
    }
    super.onClose();
  }
}
