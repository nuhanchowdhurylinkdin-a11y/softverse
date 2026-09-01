import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import 'storage_service.dart';

enum OfflineActionType { updateFeatureSettings, createItem, createCheckout }

class OfflineDatabaseService {
  OfflineDatabaseService._();

  static const _cacheBoxName = 'softverse_cache';
  static const _queueBoxName = 'softverse_sync_queue';
  static const _quarantineBoxName = 'softverse_sync_quarantine';
  static const _ownerKeyPrefix = 'owner/';

  static Box? _cacheBox;
  static Box? _queueBox;
  static Box? _quarantineBox;

  static Future<void> init({String? testPath, String boxSuffix = ''}) async {
    if (testPath == null) {
      await Hive.initFlutter();
    } else {
      Hive.init(testPath);
    }

    _cacheBox = await Hive.openBox('$_cacheBoxName$boxSuffix');
    _queueBox = await Hive.openBox('$_queueBoxName$boxSuffix');
    _quarantineBox = await Hive.openBox('$_quarantineBoxName$boxSuffix');
    await _discardLegacyGlobalCaches();
    await quarantineLegacyActions();
  }

  static String? get _ownerPrefix {
    final businessId = StorageService.businessId?.trim();
    final userId = StorageService.userId?.trim();
    if (businessId == null ||
        businessId.isEmpty ||
        userId == null ||
        userId.isEmpty) {
      return null;
    }
    return '$_ownerKeyPrefix$businessId/$userId/';
  }

  static Future<void> saveCache(String key, Object? value) async {
    final prefix = _ownerPrefix;
    if (prefix == null) return;
    await _requireCacheBox().put('$prefix$key', jsonEncode(value));
  }

  static T? readCache<T>(String key) {
    final prefix = _ownerPrefix;
    if (prefix == null) return null;
    final raw = _requireCacheBox().get('$prefix$key');
    if (raw is! String || raw.isEmpty) return null;
    return jsonDecode(raw) as T;
  }

  static Future<void> enqueue({
    required OfflineActionType type,
    required Map<String, dynamic> payload,
  }) async {
    final businessId = StorageService.businessId?.trim();
    final userId = StorageService.userId?.trim();
    if (businessId == null ||
        businessId.isEmpty ||
        userId == null ||
        userId.isEmpty) {
      throw StateError('An authenticated owner is required to queue actions.');
    }

    final id = DateTime.now().microsecondsSinceEpoch.toString();
    await _requireQueueBox().put(id, {
      'id': id,
      'type': type.name,
      'payload': payload,
      'businessId': businessId,
      'userId': userId,
      'createdAt': DateTime.now().toIso8601String(),
      'attempts': 0,
    });
  }

  static List<Map<String, dynamic>> pendingActions() {
    final businessId = StorageService.businessId?.trim();
    final userId = StorageService.userId?.trim();
    if (businessId == null ||
        businessId.isEmpty ||
        userId == null ||
        userId.isEmpty) {
      return const [];
    }

    return _requireQueueBox().values
        .whereType<Map>()
        .map((entry) => Map<String, dynamic>.from(entry))
        .where(
          (entry) =>
              entry['businessId'] == businessId && entry['userId'] == userId,
        )
        .toList()
      ..sort((a, b) => '${a['createdAt']}'.compareTo('${b['createdAt']}'));
  }

  static Future<void> removeAction(String id) async {
    final entry = _ownedAction(id);
    if (entry == null) return;
    await _requireQueueBox().delete(id);
  }

  static Future<void> markAttempt(String id) async {
    final entry = _ownedAction(id);
    if (entry == null) return;
    entry['attempts'] = (entry['attempts'] as int? ?? 0) + 1;
    await _requireQueueBox().put(id, entry);
  }

  static Future<void> clearCurrentOwnerData() async {
    final prefix = _ownerPrefix;
    final businessId = StorageService.businessId?.trim();
    final userId = StorageService.userId?.trim();
    if (prefix == null || businessId == null || userId == null) return;

    final cacheKeys = _requireCacheBox().keys
        .where((key) => key is String && key.startsWith(prefix))
        .toList();
    await _requireCacheBox().deleteAll(cacheKeys);

    final actionKeys = _requireQueueBox().keys.where((key) {
      final raw = _requireQueueBox().get(key);
      return raw is Map &&
          raw['businessId'] == businessId &&
          raw['userId'] == userId;
    }).toList();
    await _requireQueueBox().deleteAll(actionKeys);
  }

  static Future<void> quarantineLegacyActions() async {
    final queue = _requireQueueBox();
    final legacyKeys = queue.keys.where((key) {
      final raw = queue.get(key);
      if (raw is! Map) return true;
      final businessId = raw['businessId']?.toString().trim();
      final userId = raw['userId']?.toString().trim();
      return businessId == null ||
          businessId.isEmpty ||
          userId == null ||
          userId.isEmpty;
    }).toList();

    for (final key in legacyKeys) {
      await _requireQuarantineBox().put(key, queue.get(key));
    }
    await queue.deleteAll(legacyKeys);
  }

  static Future<void> closeForTesting() async {
    await _cacheBox?.close();
    await _queueBox?.close();
    await _quarantineBox?.close();
    _cacheBox = null;
    _queueBox = null;
    _quarantineBox = null;
  }

  static Map<String, dynamic>? _ownedAction(String id) {
    final raw = _requireQueueBox().get(id);
    if (raw is! Map) return null;
    final entry = Map<String, dynamic>.from(raw);
    if (entry['businessId'] != StorageService.businessId ||
        entry['userId'] != StorageService.userId) {
      return null;
    }
    return entry;
  }

  static Future<void> _discardLegacyGlobalCaches() async {
    final cache = _requireCacheBox();
    final legacyKeys = cache.keys
        .where((key) => key is! String || !key.startsWith(_ownerKeyPrefix))
        .toList();
    await cache.deleteAll(legacyKeys);
  }

  static Box _requireCacheBox() =>
      _cacheBox ?? (throw StateError('Offline database is not initialized.'));

  static Box _requireQueueBox() =>
      _queueBox ?? (throw StateError('Offline database is not initialized.'));

  static Box _requireQuarantineBox() =>
      _quarantineBox ??
      (throw StateError('Offline database is not initialized.'));
}
