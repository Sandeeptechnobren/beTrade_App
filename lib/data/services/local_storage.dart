import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around SharedPreferences. Single source of truth for the
/// auth token, theme mode, onboarding flag, KYC banner state, and a small
/// JSON blob cache for the countries dropdown.
class LocalStorage {
  static const String themeKey = "theme_mode";

  // ── countries cache ──────────────────────────────────────────────────
  // Why cache `/api/countries`:
  //   The endpoint takes ~800 ms server-side (Laravel cold-boot under
  //   Apache + mod_php) but only returns 2-50 rows of essentially static
  //   data. Reading from disk is sub-millisecond and stops the LoginScreen
  //   from showing a spinner over the country picker on every cold open.
  // TTL:
  //   24 hours is generous — the countries list moves at most a handful of
  //   rows per year. We still refresh in the background on every cold
  //   start so the in-app data stays current.
  static const String _countriesJsonKey = "countries_cache_json";
  static const String _countriesFetchedAtKey = "countries_cache_fetched_at";
  static const Duration countriesCacheTtl = Duration(hours: 24);

  static late SharedPreferences _prefs;
  static Future init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveThemeMode(String mode) async {
    await _prefs.setString(themeKey, mode);
  }

  static String? getThemeMode() {
    return _prefs.getString(themeKey);
  }

  static Future setToken(String token) async {
    await _prefs.setString("token", token);
  }

  static String? getToken() {
    return _prefs.getString("token");
  }

  static Future clearToken() async {
    await _prefs.remove("token");
    await _prefs.remove("doc_upload_status");
  }

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

  // ── Countries cache helpers ─────────────────────────────────────────
  /// Persist the freshly-fetched countries JSON blob + the wall-clock time
  /// at which it landed. We deliberately store the raw JSON string (rather
  /// than re-encoding to model + back) so callers control the shape.
  static Future<void> cacheCountries(String json) async {
    await _prefs.setString(_countriesJsonKey, json);
    await _prefs.setInt(
      _countriesFetchedAtKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Return the cached countries JSON if present and within TTL, else null.
  /// Returning null specifically when stale (not just missing) lets callers
  /// distinguish "cold first launch" from "stale" — they can re-fetch in
  /// both cases but stale callers can still show the stale data first while
  /// waiting for the network.
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
