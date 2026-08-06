import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _idKey = 'userId';
  static const String _nameKey = 'fullName';
  static const String _emailKey = 'email';
  static const String _roleKey = 'role';
  static const String _businessIdKey = 'businessId';
  static const String _onboardingCompleteKey = 'onboardingComplete';
  static const String _featureSettingsCompleteKey = 'featureSettingsComplete';
  static const String _themeModeKey = 'themeMode';

  static SharedPreferences? _preferences;

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static bool hasToken() => _preferences?.getString(_accessTokenKey) != null;

  static String? get accessToken => _preferences?.getString(_accessTokenKey);
  static String? get refreshToken => _preferences?.getString(_refreshTokenKey);
  static String? get userId => _preferences?.getString(_idKey);
  static String? get fullName => _preferences?.getString(_nameKey);
  static String? get email => _preferences?.getString(_emailKey);
  static String? get role => _preferences?.getString(_roleKey);
  static String? get businessId => _preferences?.getString(_businessIdKey);
  static bool get isOnboardingComplete =>
      _preferences?.getBool(_onboardingCompleteKey) ?? false;
  static bool get isFeatureSettingsComplete =>
      _preferences?.getBool(_featureSettingsCompleteKey) ?? false;

  static Future<void> saveUserSession({
    required String id,
    required String fullName,
    required String email,
    required String accessToken,
    required String refreshToken,
    String? role,
    String? businessId,
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
  }

  static Future<void> updateTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _preferences?.setString(_accessTokenKey, accessToken);
    await _preferences?.setString(_refreshTokenKey, refreshToken);
  }

  static Future<void> logoutUser() async {
    await _preferences?.remove(_accessTokenKey);
    await _preferences?.remove(_refreshTokenKey);
    await _preferences?.remove(_idKey);
    await _preferences?.remove(_nameKey);
    await _preferences?.remove(_emailKey);
    await _preferences?.remove(_roleKey);
    await _preferences?.remove(_businessIdKey);
  }

  static Future<void> setOnboardingComplete(bool value) async {
    await _preferences?.setBool(_onboardingCompleteKey, value);
  }

  static Future<void> setFeatureSettingsComplete(bool value) async {
    await _preferences?.setBool(_featureSettingsCompleteKey, value);
  }

  static String get themeMode =>
      _preferences?.getString(_themeModeKey) ?? 'system';

  static Future<void> setThemeMode(String mode) async {
    await _preferences?.setString(_themeModeKey, mode);
  }
}
