// import 'package:flutter/material.dart';
//
// class ThemeProvider extends ChangeNotifier {
//   bool _isDark = false;
//
//   bool get isDark => _isDark;
//
//   ThemeMode get themeMode =>
//       _isDark ? ThemeMode.dark : ThemeMode.light;
//
//   void toggleTheme(bool value) {
//     _isDark = value;
//     notifyListeners();
//   }
// }

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;
  bool get isDark => _isDark;
  ThemeMode get themeMode =>
      _isDark ? ThemeMode.dark : ThemeMode.light;
  ThemeProvider() {
    loadTheme();
  }
  void toggleTheme(bool value) async {
    _isDark = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isDark", value);
    notifyListeners();
  }
  void loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool("isDark") ?? false;
    notifyListeners();
  }
}