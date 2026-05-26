import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ❌ OLD (unchanged — kahin bhi use ho raha ho safe hai)
  static const Color inputFieldBg = Color(0xFFF2F2F7);
  static const Color primary = Color(0xFF7B2FF7);
  static const Color textPrimary = Colors.black;
  static const Color textSecondary = Colors.grey;
  static const Color border = Color(0xFFE5E5EA);
  static const Color grey200 = Color(0xFFEEEEEE); // approx shade200
  static const Color iconContainer = Color(0xFFF4F4F5);
  static const Color iconContainer1 = Color(0xFFC178FF);
  static const Color disableButtonColor = Color(0xFFC687FD);

  static const Color btnGreen = Color(0xFF22c55e);
  static const Color btnRed = Color(0xFFef4444);

  // ✅ NEW (dark mode ke liye — use these gradually)

  static Color inputFieldBgDynamic(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1E1E1E)
          : inputFieldBg;

  static Color grey200Dynamic(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF2A2A2A) // dark mode color
          : grey200;

  static Color textPrimaryDynamic(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : textPrimary;

  // ✅ LIGHT WHITE (same as before type)
  static const Color white = Colors.white;

  static Color whiteDynamic(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF2A2A2A) // dark mode me greyish black
          : white;

  static Color textSecondaryDynamic(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade400
          : textSecondary;

  static Color iconBgDynamic(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF2A2A2A)
          : const Color(0xFFF2F2F7);

  static Color borderDynamic(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade700
          : border;

  static Color iconContainerDynamic(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF2A2A2A)
          : iconContainer;

  static Color cardBackgroundDynamic(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1C1C1E) // Dark mode card bg
          : Colors.white; // Light mode card bg

  static Color buttonSecondaryDynamic(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF2C2C2E) // Dark mode secondary button
          : inputFieldBg; //// Light mode secondary button

  /// Placeholder / hint text color for `TextField.decoration.hintStyle`.
  /// Previously every input set its own ad-hoc colour (`Colors.grey`,
  /// `Colors.grey.shade500`, `AppTextStyle.body`, etc.) — many landed
  /// too dark in light mode and read as real data instead of a hint
  /// (QA #14). This token centralises a single production-grade value
  /// per brightness:
  ///
  ///   * light → `grey.shade400` — clearly lighter than body text
  ///   * dark  → `grey.shade500` — readable on the dark surface but
  ///     still distinguishable from primary text
  static Color hintTextDynamic(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade500
          : Colors.grey.shade400;

  /// Bottom-navigation background. The default Material 3
  /// `BottomNavigationBar` background is `Theme.canvasColor` plus a
  /// surface tint that bleeds in as the body scrolls, which is what
  /// caused the "navbar turns grey on scroll" report (QA #16). Set this
  /// explicitly on the nav widget to anchor the colour.
  static Color bottomNavBackgroundDynamic(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1C1C1E)
          : Colors.white;

  // ✅ NEW - Add these methods
  static Color snackbarErrorDynamic(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade800 // Dark mode: dark grey background
          : Colors.red.shade50; // Light mode: light red background

  static Color snackbarSuccessDynamic(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.green.shade900 // Dark mode: dark green background
          : Colors.green.shade50; // Light mode: light green background

  static Color snackbarInfoDynamic(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.blue.shade900 // Dark mode: dark blue background
          : Colors.blue.shade50; // Light mode: light blue background

// electric-violet-900
  static Color electricViolet900 = Color(0xFF8A50F4);

// electric-violet-200
   static Color electricViolet200 = Color(0xFFC4B5FD);
}
