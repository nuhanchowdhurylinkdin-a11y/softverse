import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  ApiConstants._();

  static String get baseUrl {
    final url = dotenv.env['BASE_URL'];
    assert(url != null && url.isNotEmpty, 'BASE_URL is not set in .env');
    return url!;
  }

  // Add your API endpoints here
  // static String get login => '$baseUrl/auth/login';
}
