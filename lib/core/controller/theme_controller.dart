import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/storage_service.dart';

class ThemeController extends GetxController {
  final _mode = ThemeMode.system.obs;

  ThemeMode get themeMode => _mode.value;

  @override
  void onInit() {
    super.onInit();
    final saved = StorageService.themeMode;
    _mode.value = switch (saved) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _mode.value = mode;
    Get.changeThemeMode(mode);
    final label = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      _ => 'system',
    };
    await StorageService.setThemeMode(label);
  }

  Future<void> toggle() async {
    final next = switch (_mode.value) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
    await setThemeMode(next);
  }

  String get label => switch (_mode.value) {
    ThemeMode.light => 'Light',
    ThemeMode.dark => 'Dark',
    _ => 'System',
  };

  IconData get icon => switch (_mode.value) {
    ThemeMode.light => Icons.light_mode,
    ThemeMode.dark => Icons.dark_mode,
    _ => Icons.brightness_auto,
  };
}
