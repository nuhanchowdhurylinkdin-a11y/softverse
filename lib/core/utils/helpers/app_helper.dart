import 'package:flutter/material.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

enum AppSnackBarType { success, failure, warning, notice }

class AppHelperFunctions {
  AppHelperFunctions._();

  static void showSnackBar(String message, {AppSnackBarType? type}) {
    final snackType = type ?? AppSnackBarType.failure;

    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
    Get.rawSnackbar(
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.transparent,
      boxShadows: const [],
      borderRadius: 0,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: EdgeInsets.zero,
      duration: const Duration(seconds: 3),
      messageText: AwesomeSnackbarContent(
        title: _getTitleForType(snackType),
        message: message,
        contentType: _getContentType(snackType),
      ),
    );
  }

  static void showSnackBarWithTitle(
    String title,
    String message, {
    AppSnackBarType? type,
  }) {
    final snackType = type ?? AppSnackBarType.failure;

    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
    Get.rawSnackbar(
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.transparent,
      boxShadows: const [],
      borderRadius: 0,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: EdgeInsets.zero,
      duration: const Duration(seconds: 3),
      messageText: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: _getContentType(snackType),
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

  static ContentType _getContentType(AppSnackBarType type) {
    if (type == AppSnackBarType.success) return ContentType.success;
    if (type == AppSnackBarType.warning) return ContentType.warning;
    if (type == AppSnackBarType.notice) return ContentType.help;
    return ContentType.failure;
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
