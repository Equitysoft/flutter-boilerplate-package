import 'package:shared_preferences/shared_preferences.dart';

/// PrefsService - A singleton service for managing SharedPreferences
/// This service provides easy access to local storage across the app
class PrefsService {
  static PrefsService? _instance;
  static SharedPreferences? _prefs;

  PrefsService._();

  /// Get singleton instance
  static PrefsService get instance {
    _instance ??= PrefsService._();
    return _instance!;
  }

  /// Initialize SharedPreferences - Call this in main() before runApp()
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Get SharedPreferences instance
  SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception(
        'PrefsService not initialized. Call PrefsService.init() first.',
      );
    }
    return _prefs!;
  }

  // ==================== Keys ====================
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserName = 'user_name';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyFcmToken = 'fcm_token';
  static const String _keyDeviceId = 'device_id';
  static const String _keyLanguageCode = 'language_code';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyIsFirstLaunch = 'is_first_launch';
  static const String _keyNotificationEnabled = 'notification_enabled';

  // ==================== Token Management ====================

  /// Get access token
  String? get accessToken => prefs.getString(_keyAccessToken);

  /// Set access token
  Future<bool> setAccessToken(String token) =>
      prefs.setString(_keyAccessToken, token);

  /// Get refresh token
  String? get refreshToken => prefs.getString(_keyRefreshToken);

  /// Set refresh token
  Future<bool> setRefreshToken(String token) =>
      prefs.setString(_keyRefreshToken, token);

  /// Clear tokens (logout)
  Future<void> clearTokens() async {
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
  }

  // ==================== User Info ====================

  /// Get user ID
  String? get userId => prefs.getString(_keyUserId);

  /// Set user ID
  Future<bool> setUserId(String id) => prefs.setString(_keyUserId, id);

  /// Get user email
  String? get userEmail => prefs.getString(_keyUserEmail);

  /// Set user email
  Future<bool> setUserEmail(String email) =>
      prefs.setString(_keyUserEmail, email);

  /// Get user name
  String? get userName => prefs.getString(_keyUserName);

  /// Set user name
  Future<bool> setUserName(String name) => prefs.setString(_keyUserName, name);

  /// Check if user is logged in
  bool get isLoggedIn => prefs.getBool(_keyIsLoggedIn) ?? false;

  /// Set login status
  Future<bool> setIsLoggedIn(bool value) =>
      prefs.setBool(_keyIsLoggedIn, value);

  // ==================== FCM & Device ====================

  /// Get FCM token
  String? get fcmToken => prefs.getString(_keyFcmToken);

  /// Set FCM token
  Future<bool> setFcmToken(String token) =>
      prefs.setString(_keyFcmToken, token);

  /// Get device ID
  String? get deviceId => prefs.getString(_keyDeviceId);

  /// Set device ID
  Future<bool> setDeviceId(String id) => prefs.setString(_keyDeviceId, id);

  // ==================== App Settings ====================

  /// Get language code
  String get languageCode => prefs.getString(_keyLanguageCode) ?? 'en';

  /// Set language code
  Future<bool> setLanguageCode(String code) =>
      prefs.setString(_keyLanguageCode, code);

  /// Get theme mode (0: system, 1: light, 2: dark)
  int get themeMode => prefs.getInt(_keyThemeMode) ?? 0;

  /// Set theme mode
  Future<bool> setThemeMode(int mode) => prefs.setInt(_keyThemeMode, mode);

  /// Check if first launch
  bool get isFirstLaunch => prefs.getBool(_keyIsFirstLaunch) ?? true;

  /// Set first launch status
  Future<bool> setIsFirstLaunch(bool value) =>
      prefs.setBool(_keyIsFirstLaunch, value);

  /// Check if notification enabled
  bool get isNotificationEnabled =>
      prefs.getBool(_keyNotificationEnabled) ?? true;

  /// Set notification enabled
  Future<bool> setNotificationEnabled(bool value) =>
      prefs.setBool(_keyNotificationEnabled, value);

  // ==================== Generic Methods ====================

  /// Get string value by key
  String? getString(String key) => prefs.getString(key);

  /// Set string value by key
  Future<bool> setString(String key, String value) =>
      prefs.setString(key, value);

  /// Get int value by key
  int? getInt(String key) => prefs.getInt(key);

  /// Set int value by key
  Future<bool> setInt(String key, int value) => prefs.setInt(key, value);

  /// Get bool value by key
  bool? getBool(String key) => prefs.getBool(key);

  /// Set bool value by key
  Future<bool> setBool(String key, bool value) => prefs.setBool(key, value);

  /// Get double value by key
  double? getDouble(String key) => prefs.getDouble(key);

  /// Set double value by key
  Future<bool> setDouble(String key, double value) =>
      prefs.setDouble(key, value);

  /// Get string list by key
  List<String>? getStringList(String key) => prefs.getStringList(key);

  /// Set string list by key
  Future<bool> setStringList(String key, List<String> value) =>
      prefs.setStringList(key, value);

  /// Remove a key
  Future<bool> remove(String key) => prefs.remove(key);

  /// Check if key exists
  bool containsKey(String key) => prefs.containsKey(key);

  /// Clear all data
  Future<bool> clearAll() => prefs.clear();

  /// Clear user data (on logout)
  Future<void> clearUserData() async {
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyIsLoggedIn);
  }
}
