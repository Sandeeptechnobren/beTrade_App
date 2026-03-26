import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static late SharedPreferences _prefs;

  // init (app start me call hoga)
  static Future init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ================= TOKEN =================
  static Future setToken(String token) async {
    await _prefs.setString("token", token);
  }

  static String? getToken() {
    return _prefs.getString("token");
  }

  static Future clearToken() async {
    await _prefs.remove("token");
  }

  // ================= ONBOARDING =================
  static Future setOnboardingDone() async {
    await _prefs.setBool("onboardingDone", true);
  }

  static bool isOnboardingDone() {
    return _prefs.getBool("onboardingDone") ?? false;
  }
}