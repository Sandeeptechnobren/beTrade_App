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
    await _prefs.setString("token", token);
  }
  static String? getToken() {
    return _prefs.getString("token");
  }
  static Future clearToken() async {
    await _prefs.remove("token");
  }
  static Future setOnboardingDone() async {
    await _prefs.setBool("onboardingDone", true);
  }
  static bool isOnboardingDone() {
    return _prefs.getBool("onboardingDone") ?? false;
  }
}