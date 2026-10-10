import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../services/business_profile_service.dart';

import '../constants/colors.dart';

enum AppSnackBarType { success, failure, warning, notice }

class AppHelperFunctions {
  AppHelperFunctions._();

  /// A small single-line pill at the top instead of the old full-width
  /// card - it used to cover a big chunk of the screen for 3s even for a
  /// trivial "synced" confirmation. Successes clear quickly; problems stay
  /// a little longer so they can actually be read.
  static void showSnackBar(String message, {AppSnackBarType? type}) {
    _showCompact(message, type ?? AppSnackBarType.failure);
  }

  static void showSnackBarWithTitle(
    String title,
    String message, {
    AppSnackBarType? type,
  }) {
    _showCompact('$title: $message', type ?? AppSnackBarType.failure);
  }

  static void _showCompact(String message, AppSnackBarType type) {
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
    Get.rawSnackbar(
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.transparent,
      boxShadows: const [],
      borderRadius: 0,
      margin: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      padding: EdgeInsets.zero,
      animationDuration: const Duration(milliseconds: 200),
      duration: _durationFor(type),
      isDismissible: true,
      dismissDirection: DismissDirection.up,
      messageText: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: _colorFor(type),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_iconFor(type), color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Duration _durationFor(AppSnackBarType type) => switch (type) {
    AppSnackBarType.success => const Duration(milliseconds: 1500),
    AppSnackBarType.notice => const Duration(milliseconds: 1800),
    AppSnackBarType.warning => const Duration(milliseconds: 2500),
    AppSnackBarType.failure => const Duration(seconds: 3),
  };

  static Color _colorFor(AppSnackBarType type) => switch (type) {
    AppSnackBarType.success => AppColors.stockBadgeText,
    AppSnackBarType.notice => AppColors.onboardingBackground,
    AppSnackBarType.warning => AppColors.checkoutGoldEnd,
    AppSnackBarType.failure => AppColors.dangerRed,
  };

  static IconData _iconFor(AppSnackBarType type) => switch (type) {
    AppSnackBarType.success => Icons.check_circle,
    AppSnackBarType.notice => Icons.info,
    AppSnackBarType.warning => Icons.warning_amber_rounded,
    AppSnackBarType.failure => Icons.error,
  };

  static void showSuccessSnackBar(String message) =>
      showSnackBar(message, type: AppSnackBarType.success);

  static void showErrorSnackBar(String message) =>
      showSnackBar(message, type: AppSnackBarType.failure);

  static void showWarningSnackBar(String message) =>
      showSnackBar(message, type: AppSnackBarType.warning);

  /// Callers almost always hand this a `DateTime` freshly parsed from a
  /// backend ISO timestamp (UTC) - `.toLocal()` here (a no-op if it's
  /// already local) is what actually converts it to the device's clock
  /// instead of silently printing UTC wall-clock time as if it were local.
  static String getFormattedDate(
    DateTime date, {
    String format = 'dd MMM yyyy',
  }) {
    return DateFormat(format).format(date.toLocal());
  }

  static String getFormattedMoney(double value) {
    return NumberFormat('#,##0.00').format(value);
  }

  /// Amount with the business currency symbol, e.g. "\$1,250.00".
  static String formatCurrency(double value) {
    return '${BusinessProfileService.currencySymbol}${getFormattedMoney(value)}';
  }
}
