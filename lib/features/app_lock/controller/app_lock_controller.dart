import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/services/network_caller.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/constants/api_constants.dart';
import '../../../core/utils/helpers/app_helper.dart';
import '../../../routes/app_routes.dart';
import '../../auth/controller/auth_controller.dart';

/// Locks the till like a phone does: when the screen goes off / the app is
/// left in the background, or after a while without a touch, the signed-in
/// user unlocks it with their PIN - nobody is logged out for stepping away.
class AppLockController extends GetxController with WidgetsBindingObserver {
  static const backgroundGrace = Duration(seconds: 15);
  static const idleTimeout = Duration(minutes: 5);
  static const pinLength = 4;

  final NetworkCaller _networkCaller = NetworkCaller();

  final isLocked = false.obs;
  final pin = ''.obs;
  final isVerifying = false.obs;
  final errorText = RxnString();

  /// null until known; false shows the "set your PIN" form.
  final hasPin = RxnBool();
  final isChangingPin = false.obs;
  final isSavingPin = false.obs;
  final passwordController = TextEditingController();
  final newPinController = TextEditingController();
  final confirmPinController = TextEditingController();

  DateTime? _pausedAt;
  Timer? _idleTimer;

  static const _noLockRoutes = {
    '/splashScreen',
    '/onboardingScreen',
    '/loginScreen',
    '/registrationScreen',
    '/forgetPasswordScreen',
    '/enterOtpScreen',
    '/resetPasswordScreen',
    '/walkthroughScreen',
    '/appLockScreen',
  };

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    touch();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _pausedAt = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      final pausedAt = _pausedAt;
      _pausedAt = null;
      if (pausedAt != null &&
          DateTime.now().difference(pausedAt) >= backgroundGrace) {
        lock();
      } else {
        touch();
      }
    }
  }

  /// Any touch on the screen restarts the idle countdown.
  void touch() {
    _idleTimer?.cancel();
    _idleTimer = Timer(idleTimeout, lock);
  }

  Future<void> lock() async {
    if (isLocked.value || !StorageService.hasToken()) return;
    if (_noLockRoutes.contains(Get.currentRoute)) {
      touch();
      return;
    }
    isLocked.value = true;
    _resetEntry();
    unawaited(_loadPinStatus());
    await Get.toNamed(AppRoute.getAppLockScreen());
  }

  Future<void> _loadPinStatus() async {
    if (StorageService.localPinHash != null) hasPin.value = true;
    final response = await _networkCaller.getRequest(ApiConstants.myPin);
    if (response.isSuccess && response.responseData is Map) {
      hasPin.value = (response.responseData as Map)['hasPin'] == true;
    } else {
      hasPin.value ??= StorageService.localPinHash != null;
    }
  }

  void addDigit(String digit) {
    if (isVerifying.value || pin.value.length >= pinLength) return;
    errorText.value = null;
    pin.value += digit;
    if (pin.value.length == pinLength) unlock();
  }

  void removeDigit() {
    if (pin.value.isEmpty) return;
    pin.value = pin.value.substring(0, pin.value.length - 1);
  }

  Future<void> unlock() async {
    final entered = pin.value;
    isVerifying.value = true;
    final response = await _networkCaller.postRequest(
      ApiConstants.verifyMyPin,
      body: {'pin': entered},
    );
    isVerifying.value = false;

    if (response.isSuccess) {
      await StorageService.setLocalPinHash(_hash(entered));
      _finishUnlock();
      return;
    }
    // Offline: the PIN last confirmed by the server on this device.
    final offline = response.statusCode == 0 || response.statusCode == 408;
    if (offline && StorageService.localPinHash == _hash(entered)) {
      _finishUnlock();
      return;
    }
    pin.value = '';
    errorText.value = offline
        ? 'No connection - enter the PIN last used on this device'
        : 'Wrong PIN';
  }

  /// First time (or "Change PIN"): confirm with the password, pick a PIN.
  Future<void> savePin() async {
    final newPin = newPinController.text.trim();
    if (!RegExp(r'^\d{4}$').hasMatch(newPin)) {
      AppHelperFunctions.showWarningSnackBar('The PIN must be 4 digits');
      return;
    }
    if (newPin != confirmPinController.text.trim()) {
      AppHelperFunctions.showWarningSnackBar('The PINs do not match');
      return;
    }
    isSavingPin.value = true;
    final response = await _networkCaller.postRequest(
      ApiConstants.myPin,
      body: {'currentPassword': passwordController.text, 'pin': newPin},
    );
    isSavingPin.value = false;
    if (!response.isSuccess) {
      AppHelperFunctions.showErrorSnackBar(response.errorMessage);
      return;
    }
    await StorageService.setLocalPinHash(_hash(newPin));
    hasPin.value = true;
    AppHelperFunctions.showSuccessSnackBar('PIN saved');
    if (isChangingPin.value) {
      isChangingPin.value = false;
      _clearForm();
      Get.back();
    } else {
      _finishUnlock();
    }
  }

  /// From More: set or change the PIN without locking.
  void openChangePin() {
    isChangingPin.value = true;
    hasPin.value = false;
    _clearForm();
    Get.toNamed(AppRoute.getAppLockScreen());
  }

  void cancelChangePin() {
    isChangingPin.value = false;
    _clearForm();
    Get.back();
  }

  /// "Not you?" - leave the till for the next user.
  Future<void> signOut() async {
    isLocked.value = false;
    _resetEntry();
    await Get.find<AuthController>().logout();
  }

  void _finishUnlock() {
    isLocked.value = false;
    _resetEntry();
    _clearForm();
    touch();
    Get.back();
  }

  void _resetEntry() {
    pin.value = '';
    errorText.value = null;
  }

  void _clearForm() {
    passwordController.clear();
    newPinController.clear();
    confirmPinController.clear();
  }

  String _hash(String value) => sha256
      .convert(utf8.encode('softverse-pin:${StorageService.userId}:$value'))
      .toString();

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _idleTimer?.cancel();
    passwordController.dispose();
    newPinController.dispose();
    confirmPinController.dispose();
    super.onClose();
  }
}
