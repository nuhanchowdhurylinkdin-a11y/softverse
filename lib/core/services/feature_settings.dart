import 'package:get/get.dart';

import 'offline_database_service.dart';

/// Reads the cached `/feature-settings` response (see [WalkthroughController]
/// for the fetch/save side) to check whether a feature toggle is on.
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
}
