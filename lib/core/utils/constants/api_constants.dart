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

  static String get categories => '$baseUrl/categories';
  static String get items => '$baseUrl/items';
  static String item(String id) => '$baseUrl/items/$id';
  static String get checkout => '$baseUrl/checkout';
  static String checkoutOrder(String id) => '$baseUrl/checkout/$id';
  static String payCheckout(String id) => '$baseUrl/checkout/$id/pay';
  static String checkoutReceipt(String id) => '$baseUrl/checkout/$id/receipt';
  static String get tables => '$baseUrl/tables';
  static String clearTable(String id) => '$baseUrl/tables/$id/clear';
  static String table(String id) => '$baseUrl/tables/$id';

  static String resolveAssetUrl(String? url) {
    if (url == null || url.trim().isEmpty) return '';
    final value = url.trim();
    final uri = Uri.tryParse(value);
    final baseUri = Uri.tryParse(baseUrl);
    if (uri != null && uri.hasScheme) {
      final normalizedUri = uri.path.startsWith('/uploads/')
          ? uri.replace(path: '/media${uri.path}')
          : uri;
      if (baseUri != null &&
          (normalizedUri.host == 'localhost' ||
              normalizedUri.host == '127.0.0.1') &&
          normalizedUri.port != baseUri.port) {
        return normalizedUri
            .replace(host: baseUri.host, port: baseUri.port)
            .toString();
      }
      return normalizedUri.toString();
    }
    if (value.startsWith('/')) return '$baseUrl$value';
    return '$baseUrl/$value';
  }
}
