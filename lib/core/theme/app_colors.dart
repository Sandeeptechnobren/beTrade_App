// import 'package:flutter/material.dart';
//
// class AppColors {
//   AppColors._();
//   static const Color inputFieldBg = Color(0xFFF2F2F7);
//   static const Color primary = Color(0xFF7B2FF7);
//   static const Color textPrimary = Colors.black;
//   static const Color textSecondary = Colors.grey;
//   static const Color border = Color(0xFFE5E5EA);
//
//   static const Color iconContainer =  Color(0xFFF4F4F5);
//   static const Color iconContainer1 =  Color(0xFFC178FF);
//   static const Color disableButtonColor =  Color(0xFFC687FD);
//   //button Color
//   static const Color btnGreen = Color(0xFF22c55e);
//   static const Color btnRed = Color(0xFFef4444);
// }

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
}
