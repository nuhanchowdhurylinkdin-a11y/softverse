import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

import '../utils/constants/api_constants.dart';
import 'network_caller.dart';
import 'offline_database_service.dart';

/// Caches the business's own profile (name/address/phone/logo) - entered on
/// the separate Business Admin web dashboard, via `GET .../profile` - so
/// receipts printed from this POS app can show the merchant's real details
/// instead of a hardcoded "Softverse POS".
class BusinessProfileService {
  BusinessProfileService._();

  static const _cacheKey = 'business_profile';

  /// Bumped whenever the cache is refreshed, so a call made inside an
  /// `Obx(...)` re-runs after [fetch] - mirrors [FeatureSettings].
  static final _version = 0.obs;

  static img.Image? _logoImage;
  static String? _logoImageUrl;

  static String get name {
    _version.value;
    final value = _cached()?['businessName']?.toString().trim();
    return (value == null || value.isEmpty) ? 'Softverse POS' : value;
  }

  static String get address {
    _version.value;
    return _cached()?['businessAddress']?.toString().trim() ?? '';
  }

  static String get phone {
    _version.value;
    return _cached()?['businessPhone']?.toString().trim() ?? '';
  }

  /// The Receipt Settings' dedicated printed-receipt logo takes priority
  /// over the business profile's own logo, matching the backend PDF
  /// generator's precedence. Once that logo was explicitly removed on the
  /// dashboard, it must stay gone - falling back to the business logo here
  /// (like an unconfigured logo does) would silently bring it right back.
  static String get logoUrl {
    _version.value;
    final cached = _cached();
    final printed = cached?['printedReceiptLogoUrl']?.toString().trim();
    if (printed != null && printed.isNotEmpty) {
      return ApiConstants.resolveAssetUrl(printed);
    }
    if (cached?['printedReceiptLogoRemoved'] == true) return '';
    final raw = cached?['businessLogoUrl']?.toString().trim();
    return (raw == null || raw.isEmpty) ? '' : ApiConstants.resolveAssetUrl(raw);
  }

  static String get header {
    _version.value;
    return _cached()?['receiptHeader']?.toString().trim() ?? '';
  }

  static String get footer {
    _version.value;
    return _cached()?['receiptFooter']?.toString().trim() ?? '';
  }

  static Map<String, dynamic>? _cached() =>
      OfflineDatabaseService.readCache<Map<String, dynamic>>(_cacheKey);

  /// Fetches the business profile and receipt settings independently, so a
  /// role without receipt-settings access (or a temporary failure on either
  /// call) still keeps whichever half succeeds instead of losing both.
  static Future<void> fetch() async {
    final networkCaller = NetworkCaller();
    final responses = await Future.wait([
      networkCaller.getRequest(ApiConstants.businessProfile),
      networkCaller.getRequest(ApiConstants.receiptSettings),
    ]);

    final merged = <String, dynamic>{};
    final profileResponse = responses[0];
    if (profileResponse.isSuccess && profileResponse.responseData is Map) {
      merged.addAll(Map<String, dynamic>.from(profileResponse.responseData as Map));
    }
    final receiptResponse = responses[1];
    if (receiptResponse.isSuccess && receiptResponse.responseData is Map) {
      final receipt = Map<String, dynamic>.from(
        receiptResponse.responseData as Map,
      );
      merged['receiptHeader'] = receipt['header'];
      merged['receiptFooter'] = receipt['footer'];
      merged['printedReceiptLogoUrl'] = receipt['printedReceiptLogoUrl'];
      merged['printedReceiptLogoRemoved'] = receipt['printedReceiptLogoRemoved'];
    }
    if (merged.isEmpty) return;

    await OfflineDatabaseService.saveCache(_cacheKey, merged);
    _version.value++;
  }

  /// Downloads and decodes the logo for thermal printing, caching the
  /// decoded image in memory so a receipt never re-downloads it - a slow or
  /// unreachable logo URL must never delay or break printing at the till.
  static Future<img.Image?> loadLogoImage() async {
    final url = logoUrl;
    if (url.isEmpty) return null;
    if (_logoImage != null && _logoImageUrl == url) return _logoImage;
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 3));
      if (response.statusCode != 200) return null;
      final decoded = img.decodeImage(response.bodyBytes);
      if (decoded == null) return null;
      _logoImage = decoded;
      _logoImageUrl = url;
      return decoded;
    } catch (_) {
      return null;
    }
  }
}
