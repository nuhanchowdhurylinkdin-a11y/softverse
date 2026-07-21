import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AppHelperFunctions {
  AppHelperFunctions._();

  static void showSnackBar(String message, {ContentType? type}) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: _getTitleForType(type ?? ContentType.failure),
        message: message,
        contentType: type ?? ContentType.failure,
      ),
    );
    ScaffoldMessenger.of(Get.context!)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static void showSuccessSnackBar(String message) =>
      showSnackBar(message, type: ContentType.success);

  static void showErrorSnackBar(String message) =>
      showSnackBar(message, type: ContentType.failure);

  static void showWarningSnackBar(String message) =>
      showSnackBar(message, type: ContentType.warning);

  static String _getTitleForType(ContentType type) {
    if (type == ContentType.success) return 'Success';
    if (type == ContentType.failure) return 'Error';
    if (type == ContentType.warning) return 'Warning';
    return 'Notice';
  }

  static String getFormattedDate(DateTime date,
      {String format = 'dd MMM yyyy'}) {
    return DateFormat(format).format(date);
  }
}
