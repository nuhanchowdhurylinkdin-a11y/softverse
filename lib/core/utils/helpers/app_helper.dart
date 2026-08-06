import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

enum AppSnackBarType { success, failure, warning, notice }

class AppHelperFunctions {
  AppHelperFunctions._();

  static void showSnackBar(String message, {AppSnackBarType? type}) {
    final snackType = type ?? AppSnackBarType.failure;
    final style = _getStyleForType(snackType);

    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
    Get.snackbar(
      _getTitleForType(snackType),
      message,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      borderRadius: 18,
      backgroundColor: style.color,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      icon: Icon(style.icon, color: Colors.white, size: 28),
      shouldIconPulse: false,
      boxShadows: [
        BoxShadow(
          color: style.color.withValues(alpha: 0.25),
          blurRadius: 18,
          offset: const Offset(0, 10),
        ),
      ],
      mainButton: TextButton(
        onPressed: Get.closeCurrentSnackbar,
        child: const Icon(Icons.close, color: Colors.white, size: 22),
      ),
    );
  }

  static void showSuccessSnackBar(String message) =>
      showSnackBar(message, type: AppSnackBarType.success);

  static void showErrorSnackBar(String message) =>
      showSnackBar(message, type: AppSnackBarType.failure);

  static void showWarningSnackBar(String message) =>
      showSnackBar(message, type: AppSnackBarType.warning);

  static String _getTitleForType(AppSnackBarType type) {
    if (type == AppSnackBarType.success) return 'Success';
    if (type == AppSnackBarType.failure) return 'Error';
    if (type == AppSnackBarType.warning) return 'Warning';
    return 'Notice';
  }

  static _SnackBarStyle _getStyleForType(AppSnackBarType type) {
    if (type == AppSnackBarType.success) {
      return const _SnackBarStyle(Icons.check_circle, Color(0xFF20B26B));
    }
    if (type == AppSnackBarType.warning) {
      return const _SnackBarStyle(Icons.warning_rounded, Color(0xFFFF9820));
    }
    if (type == AppSnackBarType.failure) {
      return const _SnackBarStyle(Icons.error_rounded, Color(0xFFEA4D4D));
    }
    return const _SnackBarStyle(Icons.info_rounded, Color(0xFF337BFF));
  }

  static String getFormattedDate(
    DateTime date, {
    String format = 'dd MMM yyyy',
  }) {
    return DateFormat(format).format(date);
  }

  static String getFormattedMoney(double value) {
    return NumberFormat('#,##0.00').format(value);
  }
}

class _SnackBarStyle {
  final IconData icon;
  final Color color;

  const _SnackBarStyle(this.icon, this.color);
}
