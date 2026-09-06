import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/localization/app_translations.dart';
import '../../../core/services/storage_service.dart';

enum HomeScreenLayout { grid, list }

class GeneralController extends GetxController {
  final cameraScanEnabled = true.obs;
  final homeScreenLayout = HomeScreenLayout.list.obs;
  final language = (StorageService.language ?? 'Use device settings').obs;

  void toggleCameraScan(bool value) => cameraScanEnabled.value = value;

  void selectHomeScreenLayout(HomeScreenLayout layout) =>
      homeScreenLayout.value = layout;

  void selectLanguage(String value) {
    language.value = value;
    StorageService.setLanguage(value);
    Get.updateLocale(_localeFor(value));
  }

  Locale _localeFor(String value) => switch (value) {
    'Bengali' => const Locale('bn', 'BD'),
    'English' => AppTranslations.fallbackLocale,
    _ => Get.deviceLocale ?? AppTranslations.fallbackLocale,
  };

  String get homeScreenLayoutLabel =>
      homeScreenLayout.value == HomeScreenLayout.grid ? 'Grid' : 'List';
}
