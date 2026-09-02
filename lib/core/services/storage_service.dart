import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _idKey = 'userId';
  static const String _nameKey = 'fullName';
  static const String _emailKey = 'email';
  static const String _roleKey = 'role';
  static const String _businessIdKey = 'businessId';
  static const String _permissionsKey = 'permissions';
  static const String _onboardingCompleteKey = 'onboardingComplete';
  static const String _featureSettingsCompleteKey = 'featureSettingsComplete';
  static const String _themeModeKey = 'themeMode';

  static SharedPreferences? _preferences;

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
    // This legacy global flag could incorrectly complete setup for the next
    // account on the device. New values are owner-scoped below.
    await _preferences?.remove(_featureSettingsCompleteKey);
  }

  static bool hasToken() => _preferences?.getString(_accessTokenKey) != null;

  static String? get accessToken => _preferences?.getString(_accessTokenKey);
  static String? get refreshToken => _preferences?.getString(_refreshTokenKey);
  static String? get userId => _preferences?.getString(_idKey);
  static String? get fullName => _preferences?.getString(_nameKey);
  static String? get email => _preferences?.getString(_emailKey);
  static String? get role => _preferences?.getString(_roleKey);
  static String? get businessId => _preferences?.getString(_businessIdKey);
  static List<String> get permissions {
    final raw = _preferences?.getString(_permissionsKey);
    if (raw == null || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw);
    return decoded is List
        ? decoded.map((value) => value.toString()).toList()
        : const [];
  }

  static bool get isOnboardingComplete =>
      _preferences?.getBool(_onboardingCompleteKey) ?? false;
  static bool get isFeatureSettingsComplete {
    final key = _featureSettingsKey;
    return key == null ? false : (_preferences?.getBool(key) ?? false);
  }

  static String? get _featureSettingsKey {
    final currentBusinessId = businessId?.trim();
    final currentUserId = userId?.trim();
    if (currentBusinessId == null ||
        currentBusinessId.isEmpty ||
        currentUserId == null ||
        currentUserId.isEmpty) {
      return null;
    }
    return '${_featureSettingsCompleteKey}_${currentBusinessId}_$currentUserId';
  }

  static Future<void> saveUserSession({
    required String id,
    required String fullName,
    required String email,
    required String accessToken,
    required String refreshToken,
    String? role,
    String? businessId,
    List<String> permissions = const [],
  }) async {
    await _preferences?.setString(_idKey, id);
    await _preferences?.setString(_nameKey, fullName);
    await _preferences?.setString(_emailKey, email);
    await _preferences?.setString(_accessTokenKey, accessToken);
    await _preferences?.setString(_refreshTokenKey, refreshToken);
    if (role != null) await _preferences?.setString(_roleKey, role);
    if (businessId != null) {
      await _preferences?.setString(_businessIdKey, businessId);
    }
    await _preferences?.setString(_permissionsKey, jsonEncode(permissions));
  }

  static Future<void> updateTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _preferences?.setString(_accessTokenKey, accessToken);
    await _preferences?.setString(_refreshTokenKey, refreshToken);
  }

  static Future<void> logoutUser() async {
    final featureSettingsKey = _featureSettingsKey;
    if (featureSettingsKey != null) {
      await _preferences?.remove(featureSettingsKey);
    }
    await _preferences?.remove(_accessTokenKey);
    await _preferences?.remove(_refreshTokenKey);
    await _preferences?.remove(_idKey);
    await _preferences?.remove(_nameKey);
    await _preferences?.remove(_emailKey);
    await _preferences?.remove(_roleKey);
    await _preferences?.remove(_businessIdKey);
    await _preferences?.remove(_permissionsKey);
  }

  static Future<void> setOnboardingComplete(bool value) async {
    await _preferences?.setBool(_onboardingCompleteKey, value);
  }

  static Future<void> setFeatureSettingsComplete(bool value) async {
    final key = _featureSettingsKey;
    if (key == null) return;
    await _preferences?.setBool(key, value);
  }

  static String get themeMode =>
      _preferences?.getString(_themeModeKey) ?? 'system';

  static Future<void> setThemeMode(String mode) async {
    await _preferences?.setString(_themeModeKey, mode);
  }
}
