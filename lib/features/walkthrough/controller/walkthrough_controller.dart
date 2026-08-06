import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/services/network_caller.dart';
import '../../../core/services/offline_database_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/sync_service.dart';
import '../../../core/utils/constants/api_constants.dart';
import '../../../core/utils/helpers/app_helper.dart';
import '../../../routes/app_routes.dart';
import '../models/feature_toggle_item.dart';

class WalkthroughController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();
  final pageController = PageController();
  final currentPage = 0.obs;
  final isSavingFeatures = false.obs;

  static const slideCount = 3;

  final features = <FeatureToggleItem>[
    const FeatureToggleItem(
      key: 'shifts',
      title: 'Shifts',
      subtitle: 'Track cash that goes in and out of your drawer',
      icon: Iconsax.clock,
    ),
    const FeatureToggleItem(
      key: 'open_order',
      title: 'Open Order',
      subtitle: 'Allow to save and edit orders before completing a payment',
      icon: Iconsax.ticket,
    ),
    const FeatureToggleItem(
      key: 'kitchen_printers',
      title: 'Kitchen printers',
      subtitle: 'Send orders to kitchen printer or display',
      icon: Iconsax.printer,
    ),
    const FeatureToggleItem(
      key: 'customer_displays',
      title: 'Customer displays',
      subtitle:
          'Display order information to customers at the time of purchase',
      icon: Iconsax.monitor,
    ),
    const FeatureToggleItem(
      key: 'table_options',
      title: 'Table options',
      subtitle: 'Mark orders as dine in, takeout, or for delivery',
      icon: Iconsax.reserve,
    ),
    const FeatureToggleItem(
      key: 'low_stock_notifications',
      title: 'Low stock notifications',
      subtitle: 'Get daily email on items that are low or out of stock',
      icon: Iconsax.notification,
    ),
    const FeatureToggleItem(
      key: 'negative_stock_alerts',
      title: 'Negative stock alerts',
      subtitle:
          'Warn cashiers attempting to sell more inventory than available in stock',
      icon: Iconsax.document,
    ),
    const FeatureToggleItem(
      key: 'credit_sales',
      title: 'Credit Sales',
      subtitle:
          'Credit sales allow businesses to sell now and receive payment later.',
      icon: Iconsax.tag,
    ),
    const FeatureToggleItem(
      key: 'payment_in_installments',
      title: 'Payment in Installments',
      subtitle:
          'It offers a convenient installment payment system to help manage your finances.',
      icon: Iconsax.wallet,
    ),
    const FeatureToggleItem(
      key: 'product_expiration_information',
      title: 'Product Expiration Information',
      subtitle:
          'Expiration Alerts: Keep track of your purchases and access exclusive deals!',
      icon: Iconsax.calendar,
    ),
  ];

  late final featureToggles = List.generate(features.length, (_) => false.obs);

  @override
  void onInit() {
    super.onInit();
    loadFeatureSettings();
  }

  void toggleFeature(int index) =>
      featureToggles[index].value = !featureToggles[index].value;

  void onPageChanged(int index) => currentPage.value = index;

  void nextPage() {
    if (currentPage.value == slideCount - 1) {
      Get.toNamed(AppRoute.getFeatureSettingsScreen());
    } else {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void previousPage() {
    pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> loadFeatureSettings() async {
    final cached = OfflineDatabaseService.readCache<Map<String, dynamic>>(
      'feature_settings',
    );
    if (cached != null) _applySettings(cached);

    final response = await _networkCaller.getRequest(
      ApiConstants.featureSettings,
    );
    if (!response.isSuccess || response.responseData is! Map) return;
    final data = Map<String, dynamic>.from(response.responseData as Map);
    await OfflineDatabaseService.saveCache('feature_settings', data);
    _applySettings(data);
  }

  Future<void> saveFeatureSettings() async {
    final payload = _payloadFromToggles();
    isSavingFeatures.value = true;
    final online = Get.isRegistered<SyncService>()
        ? Get.find<SyncService>().isOnline.value
        : true;
    final response = online
        ? await _networkCaller.patchRequest(
            ApiConstants.featureSettings,
            body: payload,
          )
        : null;

    if (response != null && response.isSuccess) {
      await OfflineDatabaseService.saveCache(
        'feature_settings',
        response.responseData,
      );
    } else {
      await OfflineDatabaseService.saveCache('feature_settings', {
        'features': features
            .asMap()
            .entries
            .map(
              (entry) => {
                'key': entry.value.key,
                'label': entry.value.title,
                'description': entry.value.subtitle,
                'enabled': featureToggles[entry.key].value,
              },
            )
            .toList(),
      });
      await OfflineDatabaseService.enqueue(
        type: OfflineActionType.updateFeatureSettings,
        payload: payload,
      );
      AppHelperFunctions.showWarningSnackBar(
        'Saved offline. It will sync when internet is back.',
      );
    }

    isSavingFeatures.value = false;
    await StorageService.setFeatureSettingsComplete(true);
    Get.offAllNamed(AppRoute.getHomeScreen());
  }

  Future<void> skipFeatureSettings() async {
    await StorageService.setFeatureSettingsComplete(true);
    Get.offAllNamed(AppRoute.getHomeScreen());
  }

  Map<String, dynamic> _payloadFromToggles() {
    final payload = <String, dynamic>{};
    for (var index = 0; index < features.length; index++) {
      payload[_fieldForFeature(features[index].key)] =
          featureToggles[index].value;
    }
    return payload;
  }

  void _applySettings(Map<String, dynamic> data) {
    final rawFeatures = data['features'];
    if (rawFeatures is! List) return;
    for (final raw in rawFeatures) {
      if (raw is! Map) continue;
      final key = raw['key']?.toString();
      final index = features.indexWhere((feature) => feature.key == key);
      if (index >= 0) {
        featureToggles[index].value = raw['enabled'] == true;
      }
    }
  }

  String _fieldForFeature(String key) => switch (key) {
    'open_order' => 'openOrder',
    'kitchen_printers' => 'kitchenPrinters',
    'customer_displays' => 'customerDisplays',
    'table_options' => 'tableOptions',
    'low_stock_notifications' => 'lowStockNotifications',
    'negative_stock_alerts' => 'negativeStockAlerts',
    'credit_sales' => 'creditSales',
    'payment_in_installments' => 'paymentInInstallments',
    'product_expiration_information' => 'productExpirationInformation',
    _ => key,
  };

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
