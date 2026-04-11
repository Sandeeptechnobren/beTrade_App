//
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class ThemeProvider extends ChangeNotifier {
//   bool _isDark = false;
//   bool get isDark => _isDark;
//   ThemeMode get themeMode =>
//       _isDark ? ThemeMode.dark : ThemeMode.light;
//   ThemeProvider() {
//     loadTheme();
//   }
//   void toggleTheme(bool value) async {
//     _isDark = value;
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool("isDark", value);
//     notifyListeners();
//   }
//   void loadTheme() async {
//     final prefs = await SharedPreferences.getInstance();
//     _isDark = prefs.getBool("isDark") ?? false;
//     notifyListeners();
//   }
// }
// lib/data/provider/theam_provider.dart
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  bool get isDark => _themeMode == ThemeMode.dark;
  ThemeMode get themeMode => _themeMode;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // ✅ This will update all screens
  }

  void setLightMode() {
    _themeMode = ThemeMode.light;
    notifyListeners();
  }

  void setDarkMode() {
    _themeMode = ThemeMode.dark;
    notifyListeners();
  }
}