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

  // ── Semantic tokens for AppNotify (toasts, confirm + success dialogs,
  //    inline alert banners). Tailwind-ish palettes — each variant has a
  //    {bg, fg, border} triplet, with a Dynamic helper that switches on
  //    Brightness. Use these instead of `Colors.red.shadeXxx` so light/dark
  //    + brand tinting stay consistent across the app. (Rollout: 2026-06-01.)

  // Success — emerald
  static Color successBgDynamic(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF052E16) // emerald-950
          : const Color(0xFFF0FDF4); // emerald-50
  static Color successFgDynamic(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF86EFAC) // emerald-300
          : const Color(0xFF15803D); // emerald-700
  static Color successBorderDynamic(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF166534) // emerald-800
          : const Color(0xFF86EFAC); // emerald-300

  // Error — red (icon-strong variants pair with btnRed = #EF4444)
  static Color errorBgDynamic(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF450A0A) // red-950
          : const Color(0xFFFEF2F2); // red-50
  static Color errorFgDynamic(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFFFCA5A5) // red-300
          : const Color(0xFFB91C1C); // red-700
  static Color errorBorderDynamic(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF991B1B) // red-800
          : const Color(0xFFFCA5A5); // red-300

  // Warning — amber
  static Color warningBgDynamic(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF451A03) // amber-950
          : const Color(0xFFFFFBEB); // amber-50
  static Color warningFgDynamic(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFFFCD34D) // amber-300
          : const Color(0xFFA16207); // amber-700
  static Color warningBorderDynamic(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF92400E) // amber-800
          : const Color(0xFFFCD34D); // amber-300

  // Info / loading — brand violet (anchors the app identity)
  static Color infoBgDynamic(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF2E1065) // violet-950
          : const Color(0xFFF5F3FF); // violet-50
  static Color infoFgDynamic(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFFC4B5FD) // violet-300
          : const Color(0xFF6D28D9); // violet-700
  static Color infoBorderDynamic(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF5B21B6) // violet-800
          : const Color(0xFFC4B5FD); // violet-300
}
