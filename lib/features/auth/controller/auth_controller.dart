import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/network_caller.dart';
import '../../../core/services/session_lifecycle_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/constants/api_constants.dart';
import '../../../core/utils/helpers/app_helper.dart';
import '../../../routes/app_routes.dart';

enum OtpFlow { signup, resetPassword }

class AuthController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final fullNameController = TextEditingController();
  final businessNameController = TextEditingController();
  final createPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final emailOrMobileController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();

  final List<TextEditingController> otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> otpFocusNodes = List.generate(6, (_) => FocusNode());

  final obscureNewPassword = true.obs;
  final obscureConfirmNewPassword = true.obs;
  final isLoginSubmitting = false.obs;
  final isRegisterSubmitting = false.obs;
  final isOtpSubmitting = false.obs;
  final isResetSubmitting = false.obs;
  final isResendingOtp = false.obs;
  final otpSecondsLeft = 120.obs;
  final currentOtpFlow = Rx<OtpFlow?>(null);
  String? _otpEmail;
  Timer? _otpTimer;

  String get otpCode =>
      otpControllers.map((controller) => controller.text).join();

  String get otpTimerLabel {
    final minutes = (otpSecondsLeft.value ~/ 60).toString().padLeft(2, '0');
    final seconds = (otpSecondsLeft.value % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  bool get canResendOtp => otpSecondsLeft.value == 0 && !isResendingOtp.value;

  void toggleObscureNewPassword() => obscureNewPassword.toggle();

  void toggleObscureConfirmNewPassword() => obscureConfirmNewPassword.toggle();

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      AppHelperFunctions.showErrorSnackBar('Email and password are required.');
      return;
    }

    isLoginSubmitting.value = true;
    final response = await _networkCaller.postRequest(
      ApiConstants.login,
      body: {'email': email, 'password': password},
      token: '',
    );
    isLoginSubmitting.value = false;

    if (!response.isSuccess) {
      AppHelperFunctions.showErrorSnackBar(response.errorMessage);
      return;
    }

    await _saveSession(response.responseData);
    _goAfterAuth();
  }

  Future<void> register() async {
    final email = emailController.text.trim();
    final password = createPasswordController.text;
    final confirmPassword = confirmPasswordController.text;
    if (fullNameController.text.trim().isEmpty ||
        businessNameController.text.trim().isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      AppHelperFunctions.showErrorSnackBar('Please fill all required fields.');
      return;
    }
    if (password != confirmPassword) {
      AppHelperFunctions.showErrorSnackBar('Passwords do not match.');
      return;
    }

    isRegisterSubmitting.value = true;
    final response = await _networkCaller.postRequest(
      ApiConstants.signup,
      body: {
        'fullName': fullNameController.text.trim(),
        'businessName': businessNameController.text.trim(),
        'email': email,
        'password': password,
        'retypePassword': confirmPassword,
      },
      token: '',
    );
    isRegisterSubmitting.value = false;

    if (!response.isSuccess) {
      AppHelperFunctions.showErrorSnackBar(response.errorMessage);
      return;
    }

    _startOtpFlow(OtpFlow.signup, email);
    Get.toNamed(AppRoute.getEnterOtpScreen());
  }

  void goToForgotPassword() => Get.toNamed(AppRoute.getForgetPasswordScreen());

  void goToRegistration() => Get.toNamed(AppRoute.getRegistrationScreen());

  void goToSignIn() => Get.toNamed(AppRoute.getLoginScreen());

  Future<void> continueForgotPassword() async {
    final email = emailOrMobileController.text.trim();
    if (email.isEmpty) {
      AppHelperFunctions.showErrorSnackBar('Email is required.');
      return;
    }

    isOtpSubmitting.value = true;
    final response = await _networkCaller.postRequest(
      ApiConstants.forgotPassword,
      body: {'email': email},
      token: '',
    );
    isOtpSubmitting.value = false;

    if (!response.isSuccess) {
      AppHelperFunctions.showErrorSnackBar(response.errorMessage);
      return;
    }

    _startOtpFlow(OtpFlow.resetPassword, email);
    Get.toNamed(AppRoute.getEnterOtpScreen());
  }

  Future<void> resendOtp() async {
    if (!canResendOtp || _otpEmail == null) return;

    isResendingOtp.value = true;
    final endpoint = currentOtpFlow.value == OtpFlow.signup
        ? ApiConstants.resendSignupOtp
        : ApiConstants.forgotPassword;
    final response = await _networkCaller.postRequest(
      endpoint,
      body: {'email': _otpEmail},
      token: '',
    );
    isResendingOtp.value = false;

    if (!response.isSuccess) {
      AppHelperFunctions.showErrorSnackBar(response.errorMessage);
      return;
    }
    _restartOtpTimer();
    AppHelperFunctions.showSuccessSnackBar('A new OTP has been sent.');
  }

  Future<void> submitOtp() async {
    if (_otpEmail == null || currentOtpFlow.value == null) return;
    if (otpCode.length != 6) {
      AppHelperFunctions.showErrorSnackBar('Enter the 6-digit OTP.');
      return;
    }

    isOtpSubmitting.value = true;
    final endpoint = currentOtpFlow.value == OtpFlow.signup
        ? ApiConstants.verifySignupOtp
        : ApiConstants.verifyForgotPasswordOtp;
    final response = await _networkCaller.postRequest(
      endpoint,
      body: {'email': _otpEmail, 'otp': otpCode},
      token: '',
    );
    isOtpSubmitting.value = false;

    if (!response.isSuccess) {
      AppHelperFunctions.showErrorSnackBar(response.errorMessage);
      return;
    }

    _stopOtpTimer();
    _clearOtp();
    if (currentOtpFlow.value == OtpFlow.signup) {
      await _saveSession(response.responseData);
      Get.offAllNamed(AppRoute.getWalkthroughScreen());
      return;
    }
    Get.toNamed(AppRoute.getResetPasswordScreen());
  }

  void onOtpChanged(int index, String value) {
    if (value.isNotEmpty && index < otpFocusNodes.length - 1) {
      otpFocusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      otpFocusNodes[index - 1].requestFocus();
    }
  }

  Future<void> submitResetPassword() async {
    if (_otpEmail == null) return;
    if (newPasswordController.text != confirmNewPasswordController.text) {
      AppHelperFunctions.showErrorSnackBar('Passwords do not match.');
      return;
    }

    isResetSubmitting.value = true;
    final response = await _networkCaller.postRequest(
      ApiConstants.resetPassword,
      body: {
        'email': _otpEmail,
        'newPassword': newPasswordController.text,
        'confirmPassword': confirmNewPasswordController.text,
      },
      token: '',
    );
    isResetSubmitting.value = false;

    if (!response.isSuccess) {
      AppHelperFunctions.showErrorSnackBar(response.errorMessage);
      return;
    }
    AppHelperFunctions.showSuccessSnackBar('Password reset successful.');
    Get.offAllNamed(AppRoute.getLoginScreen());
  }

  Future<void> logout() async {
    final refreshToken = StorageService.refreshToken;
    if (refreshToken != null) {
      await _networkCaller.postRequest(
        ApiConstants.logout,
        body: {'refreshToken': refreshToken},
      );
    }
    await SessionLifecycleService.endSession();
  }

  Future<void> _saveSession(dynamic raw) async {
    final data = Map<String, dynamic>.from(raw as Map);
    final user = Map<String, dynamic>.from(data['user'] as Map);
    await StorageService.saveUserSession(
      id: user['id']?.toString() ?? '',
      fullName: user['fullName']?.toString() ?? '',
      email: user['email']?.toString() ?? '',
      role: user['role']?.toString(),
      businessId: user['businessId']?.toString(),
      permissions: (user['permissions'] is List)
          ? (user['permissions'] as List)
                .map((value) => value.toString())
                .toList()
          : const [],
      accessToken: data['accessToken']?.toString() ?? '',
      refreshToken: data['refreshToken']?.toString() ?? '',
    );
  }

  void _goAfterAuth() {
    if (!StorageService.isOnboardingComplete) {
      Get.offAllNamed(AppRoute.getWalkthroughScreen());
      return;
    }
    if (!StorageService.isFeatureSettingsComplete) {
      Get.offAllNamed(AppRoute.getFeatureSettingsScreen());
      return;
    }
    Get.offAllNamed(AppRoute.getHomeScreen());
  }

  void _startOtpFlow(OtpFlow flow, String email) {
    currentOtpFlow.value = flow;
    _otpEmail = email;
    _clearOtp();
    _restartOtpTimer();
  }

  void _restartOtpTimer() {
    _stopOtpTimer();
    otpSecondsLeft.value = 120;
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (otpSecondsLeft.value <= 0) {
        _stopOtpTimer();
        return;
      }
      otpSecondsLeft.value--;
    });
  }

  void _stopOtpTimer() {
    _otpTimer?.cancel();
    _otpTimer = null;
  }

  void _clearOtp() {
    for (final controller in otpControllers) {
      controller.clear();
    }
  }

  @override
  void onClose() {
    _stopOtpTimer();
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
