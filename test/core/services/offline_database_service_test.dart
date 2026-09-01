import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softverse/core/services/offline_database_service.dart';
import 'package:softverse/core/services/storage_service.dart';

void main() {
  late Directory databaseDirectory;

  setUpAll(() async {
    databaseDirectory = await Directory.systemTemp.createTemp(
      'softverse_phase_2_',
    );
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
    await OfflineDatabaseService.init(
      testPath: databaseDirectory.path,
      boxSuffix: '_phase_2_test',
    );
  });

  tearDownAll(() async {
    await OfflineDatabaseService.closeForTesting();
    await databaseDirectory.delete(recursive: true);
  });

  test('cache and pending actions are isolated by business and user', () async {
    await _saveSession(businessId: 'business-a', userId: 'user-a');
    await OfflineDatabaseService.saveCache('items', [
      {'id': 'item-a'},
    ]);
    await OfflineDatabaseService.enqueue(
      type: OfflineActionType.createItem,
      payload: {'name': 'Item A'},
    );

    await _saveSession(businessId: 'business-b', userId: 'user-b');
    expect(OfflineDatabaseService.readCache<List<dynamic>>('items'), isNull);
    expect(OfflineDatabaseService.pendingActions(), isEmpty);

    await OfflineDatabaseService.saveCache('items', <dynamic>[]);
    expect(OfflineDatabaseService.readCache<List<dynamic>>('items'), isEmpty);

    await _saveSession(businessId: 'business-a', userId: 'user-a');
    expect(OfflineDatabaseService.readCache<List<dynamic>>('items'), [
      {'id': 'item-a'},
    ]);
    expect(OfflineDatabaseService.pendingActions(), hasLength(1));
  });

  test('logout cleanup removes only the active owner data', () async {
    await _saveSession(businessId: 'business-a', userId: 'user-a');
    await OfflineDatabaseService.clearCurrentOwnerData();
    expect(OfflineDatabaseService.readCache<List<dynamic>>('items'), isNull);
    expect(OfflineDatabaseService.pendingActions(), isEmpty);

    await _saveSession(businessId: 'business-b', userId: 'user-b');
    expect(OfflineDatabaseService.readCache<List<dynamic>>('items'), isEmpty);
  });

  test('feature completion is owner scoped and cleared at logout', () async {
    await _saveSession(businessId: 'business-a', userId: 'user-a');
    await StorageService.setFeatureSettingsComplete(true);
    expect(StorageService.isFeatureSettingsComplete, isTrue);

    await _saveSession(businessId: 'business-b', userId: 'user-b');
    expect(StorageService.isFeatureSettingsComplete, isFalse);

    await _saveSession(businessId: 'business-a', userId: 'user-a');
    expect(StorageService.isFeatureSettingsComplete, isTrue);
    await StorageService.logoutUser();

    await _saveSession(businessId: 'business-a', userId: 'user-a');
    expect(StorageService.isFeatureSettingsComplete, isFalse);
  });

  test('cannot enqueue an action without an authenticated owner', () async {
    await StorageService.logoutUser();

    expect(
      () => OfflineDatabaseService.enqueue(
        type: OfflineActionType.createCheckout,
        payload: const {},
      ),
      throwsStateError,
    );
  });

  test('legacy unowned queue records are quarantined', () async {
    final queue = Hive.box('softverse_sync_queue_phase_2_test');
    final quarantine = Hive.box('softverse_sync_quarantine_phase_2_test');
    await queue.put('legacy-action', {
      'id': 'legacy-action',
      'type': OfflineActionType.createItem.name,
      'payload': {'name': 'Unknown owner'},
    });

    await OfflineDatabaseService.quarantineLegacyActions();

    expect(queue.containsKey('legacy-action'), isFalse);
    expect(quarantine.containsKey('legacy-action'), isTrue);
  });
}

Future<void> _saveSession({
  required String businessId,
  required String userId,
}) {
  return StorageService.saveUserSession(
    id: userId,
    fullName: 'Test User',
    email: '$userId@example.com',
    accessToken: 'access-$userId',
    refreshToken: 'refresh-$userId',
    businessId: businessId,
  );
}
