import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local persistence.
///
/// - The auth **bearer token** is stored in the OS secure store
///   (Keychain on iOS, Keystore-backed encrypted prefs on Android) via
///   [FlutterSecureStorage]. It is mirrored into an in-memory cache so the
///   rest of the app can keep reading it **synchronously** via [getToken].
/// - Non-sensitive flags (onboarding, KYC banner status) stay in plain
///   [SharedPreferences].
class LocalStorage {
  static const String _tokenKey = "token";

  static late SharedPreferences _prefs;

  // Android/iOS defaults are Keystore/Keychain-backed; the plugin encrypts at
  // rest automatically (the old `encryptedSharedPreferences` flag is removed).
  static const FlutterSecureStorage _secure = FlutterSecureStorage();

  /// In-memory mirror of the bearer token so [getToken] stays synchronous.
  static String? _token;

  static Future init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadToken();
  }

  /// Loads the token into [_token] and migrates any legacy plaintext token
  /// (older builds wrote it to SharedPreferences) into secure storage.
  static Future<void> _loadToken() async {
    try {
      _token = await _secure.read(key: _tokenKey);

      if (_token == null || _token!.isEmpty) {
        final legacy = _prefs.getString(_tokenKey);
        if (legacy != null && legacy.isNotEmpty) {
          await _secure.write(key: _tokenKey, value: legacy);
          _token = legacy;
        }
      }

      // Never leave a plaintext copy behind.
      if (_prefs.containsKey(_tokenKey)) {
        await _prefs.remove(_tokenKey);
      }
    } catch (_) {
      _token = null;
    }
  }

  // ---- Auth token (secure) ----
  static Future setToken(String token) async {
    _token = token;
    await _secure.write(key: _tokenKey, value: token);
  }

  static String? getToken() => _token;

  static Future clearToken() async {
    _token = null;
    await _secure.delete(key: _tokenKey);
    await _prefs.remove("doc_upload_status");
  }

  // ---- Onboarding (non-sensitive) ----
  static Future setOnboardingDone() async {
    await _prefs.setBool("onboardingDone", true);
  }

  static bool isOnboardingDone() {
    return _prefs.getBool("onboardingDone") ?? false;
  }

  /// Persists the user's KYC `doc_upload_status` so the KYC reminder banner
  /// survives app close/reopen until the user actually completes verification.
  static Future setDocUploadStatus(int status) async {
    await _prefs.setInt("doc_upload_status", status);
  }

  static int? getDocUploadStatus() {
    return _prefs.getInt("doc_upload_status");
  }

  static Future clearDocUploadStatus() async {
    await _prefs.remove("doc_upload_status");
  }

  // ---- Cache (Generic JSON storage) ----
  static Future<void> cacheData(String key, String jsonData) async {
    await _prefs.setString("cache_$key", jsonData);
  }

  static String? getCachedData(String key) {
    return _prefs.getString("cache_$key");
  }

  static Future<void> clearCache() async {
    final keys = _prefs.getKeys();
    for (String key in keys) {
      if (key.startsWith("cache_")) {
        await _prefs.remove(key);
      }
    }
  }
}
