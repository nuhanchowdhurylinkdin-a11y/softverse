import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  ApiConstants._();

  static String get baseUrl {
    final url = dotenv.env['BASE_URL'];
    assert(url != null && url.isNotEmpty, 'BASE_URL is not set in .env');
    return url!;
  }

  static String get signup => '$baseUrl/auth/signup';
  static String get resendSignupOtp => '$baseUrl/auth/signup/resend-otp';
  static String get verifySignupOtp => '$baseUrl/auth/signup/verify-otp';
  static String get login => '$baseUrl/auth/login';
  static String get refresh => '$baseUrl/auth/refresh';
  static String get logout => '$baseUrl/auth/logout';
  static String get me => '$baseUrl/auth/me';
  static String get forgotPassword => '$baseUrl/auth/forgot-password';
  static String get verifyForgotPasswordOtp =>
      '$baseUrl/auth/forgot-password/verify-otp';
  static String get resetPassword => '$baseUrl/auth/reset-password';

  static String get featureSettings => '$baseUrl/feature-settings';
  static String toggleFeature(String key) => '$baseUrl/feature-settings/$key';
  static String get paymentTypes => '$baseUrl/payment-types';

  static String get categories => '$baseUrl/categories';
  static String get customers => '$baseUrl/customers';
  static String customer(String id) => '$baseUrl/customers/$id';
  static String get items => '$baseUrl/items';
  static String get inventory => '$baseUrl/inventory';
  static String item(String id) => '$baseUrl/items/$id';
  static String get checkout => '$baseUrl/checkout';
  static String get pendingCheckout => '$baseUrl/checkout/pending';
  static String checkoutOrder(String id) => '$baseUrl/checkout/$id';
  static String payCheckout(String id) => '$baseUrl/checkout/$id/pay';
  static String refundCheckout(String id) => '$baseUrl/checkout/$id/refund';
  static String checkoutReceipt(String id) => '$baseUrl/checkout/$id/receipt';
  static String get currentShift => '$baseUrl/shifts/current';
  static String get openShift => '$baseUrl/shifts/open';
  static String get closeShift => '$baseUrl/shifts/close';
  static String get shiftMovements => '$baseUrl/shifts/movements';
  static String get shiftHistory => '$baseUrl/shifts/history';
  static String shiftReport(String id) => '$baseUrl/shifts/$id/report';
  static String get transactions => '$baseUrl/transactions';
  static String transaction(String id) => '$baseUrl/transactions/$id';
  static String get taxes => '$baseUrl/taxes';
  static String tax(String id) => '$baseUrl/taxes/$id';
  static String get taxItems => '$baseUrl/taxes/items';
  static String get tables => '$baseUrl/tables';
  static String clearTable(String id) => '$baseUrl/tables/$id/clear';
  static String table(String id) => '$baseUrl/tables/$id';
  static String get uploadImages => '$baseUrl/uploads/images';

  static String resolveAssetUrl(String? url) {
    if (url == null || url.trim().isEmpty) return '';
    final value = url.trim();
    final uri = Uri.tryParse(value);
    if (uri != null && uri.hasScheme) {
      final uploadPath = _normalizeUploadPath(uri.path);
      if (uploadPath != null) return '$baseUrl$uploadPath';
      return value;
    }

    final uploadPath = _normalizeUploadPath(value);
    if (uploadPath != null) return '$baseUrl$uploadPath';
    if (value.startsWith('/')) return '$baseUrl$value';
    return '$baseUrl/$value';
  }

  static String? _normalizeUploadPath(String path) {
    final normalized = path.trim();
    if (normalized.isEmpty) return null;

    if (normalized.startsWith('/media/uploads/')) return normalized;
    if (normalized.startsWith('/uploads/')) return '/media$normalized';
    if (normalized.startsWith('media/uploads/')) return '/$normalized';
    if (normalized.startsWith('uploads/')) return '/media/$normalized';
    return null;
  }
}
