import 'package:shared_preferences/shared_preferences.dart';
class LocalStorage {
  static const String themeKey = "theme_mode";
  static Future<void> saveThemeMode(String mode) async {
    await _prefs.setString(themeKey, mode);
  }
  static String? getThemeMode() {
    return _prefs.getString(themeKey);
  }
  static late SharedPreferences _prefs;
  static Future init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  static Future setToken(String token) async {
    print(token);
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
}