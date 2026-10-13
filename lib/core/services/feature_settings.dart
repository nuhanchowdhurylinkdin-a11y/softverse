import 'package:get/get.dart';

import '../utils/constants/api_constants.dart';
import 'network_caller.dart';
import 'offline_database_service.dart';

/// The features the business manager switched on in the website's
/// Settings → Features. Every user of the business gets the same set - a
/// cashier can't (and doesn't need to) change them from the till.
class FeatureSettings {
  FeatureSettings._();

  /// Bumped by [notifyChanged] whenever the cache is updated, so a call to
  /// [isEnabled] made inside an `Obx(...)` re-runs on the next toggle —
  /// several screens (e.g. Checkout, More) are built once and kept alive in
  /// an IndexedStack, so nothing else would ever make them re-read the cache.
  static final _version = 0.obs;

  static bool isEnabled(String key) {
    // ignore: unnecessary_statements
    _version.value; // registers this call as an Obx() dependency
    final cached = OfflineDatabaseService.readCache<Map<String, dynamic>>(
      'feature_settings',
    );
    final rawFeatures = cached?['features'];
    if (rawFeatures is! List) return false;
    for (final raw in rawFeatures) {
      if (raw is Map && raw['key']?.toString() == key) {
        return raw['enabled'] == true;
      }
    }
    return false;
  }

  /// Call after writing a fresh feature-settings response to the cache.
  static void notifyChanged() => _version.value++;

  /// Re-reads the business's features from the server into the cache.
  static Future<void> refresh() async {
    final response = await NetworkCaller().getRequest(
      ApiConstants.featureSettings,
    );
    if (!response.isSuccess || response.responseData is! Map) return;
    await OfflineDatabaseService.saveCache(
      'feature_settings',
      Map<String, dynamic>.from(response.responseData as Map),
    );
    notifyChanged();
  }
}
