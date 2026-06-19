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
  static const String _lastSyncKey = "last_sync_ts";

  // ── countries cache ──────────────────────────────────────────────────
  // Why cache `/api/countries`: the endpoint is slow server-side (~800 ms
  // cold) but returns essentially-static data. Disk reads are sub-ms and
  // stop the LoginScreen from spinning over the country picker on every cold
  // open. 24 h TTL; we still refresh in the background on every cold start.
  static const String _countriesJsonKey = "countries_cache_json";
  static const String _countriesFetchedAtKey = "countries_cache_fetched_at";
  static const Duration countriesCacheTtl = Duration(hours: 24);

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
    // A successful cache write == a successful fetch == a sync. Record the most
    // recent one so the offline UI can tell the user how stale the data is.
    await _prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
  }

  static String? getCachedData(String key) {
    return _prefs.getString("cache_$key");
  }

  /// When any cached data was last refreshed from the server, or null if the
  /// app has never synced (e.g. first launch while offline).
  static DateTime? getLastSync() {
    final ms = _prefs.getInt(_lastSyncKey);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  static Future<void> clearCache() async {
    final keys = _prefs.getKeys();
    for (String key in keys) {
      if (key.startsWith("cache_")) {
        await _prefs.remove(key);
      }
    }
    await _prefs.remove(_lastSyncKey);
  }

  // ── Countries cache helpers ─────────────────────────────────────────
  /// Persist the freshly-fetched countries JSON blob + the wall-clock time
  /// at which it landed. Stores the raw JSON string so callers control shape.
  static Future<void> cacheCountries(String json) async {
    await _prefs.setString(_countriesJsonKey, json);
    await _prefs.setInt(
      _countriesFetchedAtKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Return the cached countries JSON if present and within TTL, else null.
  /// Returning null when stale (not just missing) lets callers distinguish
  /// "cold first launch" from "stale". Pass [ignoreTtl] to read stale data
  /// (e.g. to show it instantly while a background refresh runs).
  static String? readCachedCountries({bool ignoreTtl = false}) {
    final json = _prefs.getString(_countriesJsonKey);
    if (json == null || json.isEmpty) return null;
    if (ignoreTtl) return json;

    final fetchedAtMs = _prefs.getInt(_countriesFetchedAtKey) ?? 0;
    if (fetchedAtMs == 0) return null;

    final age = DateTime.now().millisecondsSinceEpoch - fetchedAtMs;
    if (age > countriesCacheTtl.inMilliseconds) return null;

    return json;
  }
}
