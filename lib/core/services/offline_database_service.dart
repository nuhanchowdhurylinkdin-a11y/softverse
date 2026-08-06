import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

enum OfflineActionType { updateFeatureSettings, createItem, createCheckout }

class OfflineDatabaseService {
  OfflineDatabaseService._();

  static const _cacheBoxName = 'softverse_cache';
  static const _queueBoxName = 'softverse_sync_queue';

  static late final Box _cacheBox;
  static late final Box _queueBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    _cacheBox = await Hive.openBox(_cacheBoxName);
    _queueBox = await Hive.openBox(_queueBoxName);
  }

  static Future<void> saveCache(String key, Object? value) async {
    await _cacheBox.put(key, jsonEncode(value));
  }

  static T? readCache<T>(String key) {
    final raw = _cacheBox.get(key);
    if (raw is! String || raw.isEmpty) return null;
    return jsonDecode(raw) as T;
  }

  static Future<void> enqueue({
    required OfflineActionType type,
    required Map<String, dynamic> payload,
  }) async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    await _queueBox.put(id, {
      'id': id,
      'type': type.name,
      'payload': payload,
      'createdAt': DateTime.now().toIso8601String(),
      'attempts': 0,
    });
  }

  static List<Map<String, dynamic>> pendingActions() {
    return _queueBox.values
        .whereType<Map>()
        .map((entry) => Map<String, dynamic>.from(entry))
        .toList()
      ..sort((a, b) => '${a['createdAt']}'.compareTo('${b['createdAt']}'));
  }

  static Future<void> removeAction(String id) => _queueBox.delete(id);

  static Future<void> markAttempt(String id) async {
    final raw = _queueBox.get(id);
    if (raw is! Map) return;
    final entry = Map<String, dynamic>.from(raw);
    entry['attempts'] = (entry['attempts'] as int? ?? 0) + 1;
    await _queueBox.put(id, entry);
  }
}
