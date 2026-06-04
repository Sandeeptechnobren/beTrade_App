// import 'package:flutter/material.dart';
//
// class ThemeProvider extends ChangeNotifier {
//   ThemeMode _themeMode = ThemeMode.light;
//
//   bool get isDark => _themeMode == ThemeMode.dark;
//   ThemeMode get themeMode => _themeMode;
//
//   void toggleTheme(bool isDark) {
//     _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
//     notifyListeners();
//   }
//
//   void setLightMode() {
//     _themeMode = ThemeMode.light;
//     notifyListeners();
//   }
//
//   void setDarkMode() {
//     _themeMode = ThemeMode.dark;
//     notifyListeners();
//   }
// }

import 'package:flutter/material.dart';
import '../services/local_storage.dart';

class ThemeProvider extends ChangeNotifier {
  // Dark mode is live. The active theme follows the persisted preference:
  // Profile toggle → SharedPreferences → restored on the next launch.
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadTheme();
  }

  // App start pe saved theme load hoga
  void _loadTheme() {
    final savedTheme = LocalStorage.getThemeMode();

    if (savedTheme == "dark") {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }

    notifyListeners();
  }

  // Toggle + Save
  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;

    LocalStorage.saveThemeMode(
      isDark ? "dark" : "light",
    );

    notifyListeners();
  }

  void setLightMode() {
    _themeMode = ThemeMode.light;
    LocalStorage.saveThemeMode("light");
    notifyListeners();
  }

  void setDarkMode() {
    _themeMode = ThemeMode.dark;
    LocalStorage.saveThemeMode("dark");
    notifyListeners();
  }
}