import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

import '../utils/constants/api_constants.dart';
import '../../features/home/controller/home_controller.dart';
import 'network_caller.dart';
import 'offline_database_service.dart';

class SyncService extends GetxService {
  final NetworkCaller _networkCaller = NetworkCaller();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  final isOnline = true.obs;
  final isSyncing = false.obs;

  Future<SyncService> init() async {
    final current = await Connectivity().checkConnectivity();
    _setConnectionState(current);
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) async {
      _setConnectionState(results);
      if (isOnline.value) await syncPendingActions();
    });
    if (isOnline.value) unawaited(syncPendingActions());
    return this;
  }

  Future<void> syncPendingActions() async {
    if (!isOnline.value || isSyncing.value) return;
    isSyncing.value = true;
    try {
      final actions = OfflineDatabaseService.pendingActions();
      for (final action in actions) {
        final id = action['id']?.toString();
        if (id == null) continue;
        final type = action['type']?.toString();
        final payload = Map<String, dynamic>.from(action['payload'] as Map);

        final success = await _syncAction(type, payload);
        if (success) {
          await OfflineDatabaseService.removeAction(id);
        } else {
          await OfflineDatabaseService.markAttempt(id);
          break;
        }
      }
    } finally {
      isSyncing.value = false;
    }
  }

  Future<bool> _syncAction(String? type, Map<String, dynamic> payload) async {
    if (type == OfflineActionType.updateFeatureSettings.name) {
      final response = await _networkCaller.patchRequest(
        ApiConstants.featureSettings,
        body: payload,
      );
      return response.isSuccess;
    }

    if (type == OfflineActionType.createItem.name) {
      final imagePath = payload.remove('imagePath')?.toString();
      final response = imagePath != null && imagePath.isNotEmpty
          ? await _networkCaller.multipartRequest(
              ApiConstants.items,
              fields: payload.map(
                (key, value) => MapEntry(
                  key,
                  value is List || value is Map ? jsonEncode(value) : '$value',
                ),
              ),
              file: File(imagePath),
            )
          : await _networkCaller.postRequest(ApiConstants.items, body: payload);
      if (response.isSuccess && Get.isRegistered<HomeController>()) {
        unawaited(Get.find<HomeController>().forceSync(showMessage: false));
      }
      return response.isSuccess;
    }

    if (type == OfflineActionType.createCheckout.name) {
      final response = await _networkCaller.postRequest(
        ApiConstants.checkout,
        body: payload,
      );
      return response.isSuccess;
    }

    return true;
  }

  void _setConnectionState(List<ConnectivityResult> results) {
    isOnline.value = results.any((result) => result != ConnectivityResult.none);
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    super.onClose();
  }
}
