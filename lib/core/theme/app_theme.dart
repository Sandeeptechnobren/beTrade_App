import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Centralized light + dark theme for the whole app.
///
/// Wired into [MaterialApp] in `main.dart` as `theme: AppTheme.light` and
/// `darkTheme: AppTheme.dark`, switched by `ThemeProvider.themeMode`.
///
/// Because this builds a *complete* [ThemeData], most Material widgets
/// (Scaffold, AppBar, Card, Dialog, BottomSheet, TextField, Switch,
/// SnackBar, BottomNavigationBar, …) adapt to light/dark automatically —
/// individual screens only need overrides for bespoke colors.
class AppTheme {
  AppTheme._();

  static const String _font = 'SFProRounded';

  // ── Brand ──────────────────────────────────────────────────────────
  static const Color _brand = Color(0xFF7B2FF7); // AppColors.primary
  static const Color _brandSecondary = Color(0xFF8A50F4);
  static const Color _danger = Color(0xFFEF4444);

  // ── Light palette (keeps the existing design) ──────────────────────
  static const Color _lScaffold = Colors.white;
  static const Color _lSurface = Colors.white;
  static const Color _lCard = Colors.white;
  static const Color _lDivider = Color(0xFFE4E4E7);
  static const Color _lTextPrimary = Color(0xFF09090B);
  static const Color _lTextSecondary = Color(0xFF71717A);
  static const Color _lFieldFill = Color(0xFFF2F2F7);

  // ── Dark palette (production-grade — per spec) ─────────────────────
  static const Color _dBackground = Color(0xFF121212);
  static const Color _dSurface = Color(0xFF1E1E1E);
  static const Color _dCard = Color(0xFF242424);
  static const Color _dDivider = Color(0xFF383838);
  static const Color _dTextPrimary = Color(0xFFFFFFFF);
  static const Color _dTextSecondary = Color(0xFFB3B3B3);
  static const Color _dFieldFill = Color(0xFF1E1E1E);

  // ── LIGHT ───────────────────────────────────────────────────────────
  static ThemeData get light => _build(
        scheme: ColorScheme.light(
          primary: _brand,
          onPrimary: Colors.white,
          secondary: _brandSecondary,
          onSecondary: Colors.white,
          surface: _lSurface,
          onSurface: _lTextPrimary,
          error: _danger,
          onError: Colors.white,
          outline: _lDivider,
        ),
        scaffold: _lScaffold,
        card: _lCard,
        divider: _lDivider,
        textPrimary: _lTextPrimary,
        textSecondary: _lTextSecondary,
        appBarBg: Colors.white,
        fieldFill: _lFieldFill,
        sheetBg: Colors.white,
        snackBg: const Color(0xFF323232),
      );

  // ── DARK ────────────────────────────────────────────────────────────
  static ThemeData get dark => _build(
        scheme: ColorScheme.dark(
          primary: _brand,
          onPrimary: Colors.white,
          secondary: _brandSecondary,
          onSecondary: Colors.white,
          surface: _dSurface,
          onSurface: _dTextPrimary,
          error: _danger,
          onError: Colors.white,
          outline: _dDivider,
        ),
        scaffold: _dBackground,
        card: _dCard,
        divider: _dDivider,
        textPrimary: _dTextPrimary,
        textSecondary: _dTextSecondary,
        appBarBg: _dBackground,
        fieldFill: _dFieldFill,
        sheetBg: _dSurface,
        snackBg: _dCard,
      );

  // ── Shared builder ──────────────────────────────────────────────────
  static ThemeData _build({
    required ColorScheme scheme,
    required Color scaffold,
    required Color card,
    required Color divider,
    required Color textPrimary,
    required Color textSecondary,
    required Color appBarBg,
    required Color fieldFill,
    required Color sheetBg,
    required Color snackBg,
  }) {
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c, width: w),
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: _font,
      scaffoldBackgroundColor: scaffold,
      canvasColor: scaffold,
      primaryColor: _brand,
      dividerColor: divider,
      hintColor: textSecondary,
      splashColor: _brand.withValues(alpha: 0.08),
      highlightColor: _brand.withValues(alpha: 0.04),

      appBarTheme: AppBarThemeData(
        backgroundColor: appBarBg,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          fontFamily: _font,
        ),
      ),

      cardTheme: CardThemeData(
        color: card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: sheetBg,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          fontFamily: _font,
        ),
        contentTextStyle: TextStyle(
          color: textSecondary,
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          fontFamily: _font,
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: sheetBg,
        modalBackgroundColor: sheetBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: sheetBg,
        selectedItemColor: _brand,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showUnselectedLabels: true,
      ),

      dividerTheme: DividerThemeData(
        color: divider,
        thickness: 1,
        space: 1,
      ),

      iconTheme: IconThemeData(color: textPrimary),
      primaryIconTheme: IconThemeData(color: textPrimary),

      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: fieldFill,
        hintStyle: TextStyle(color: textSecondary, fontFamily: _font),
        labelStyle: TextStyle(color: textSecondary, fontFamily: _font),
        border: border(divider),
        enabledBorder: border(divider),
        focusedBorder: border(_brand, 1.5),
        errorBorder: border(_danger),
        focusedErrorBorder: border(_danger, 1.5),
      ),

      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: _brand,
        selectionColor: Color(0x407B2FF7),
        selectionHandleColor: _brand,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? Colors.white : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? _brand : null,
        ),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? _brand : Colors.transparent,
        ),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: BorderSide(color: textSecondary),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? _brand : textSecondary,
        ),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _brand,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: snackBg,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontFamily: _font,
        ),
        behavior: SnackBarBehavior.floating,
        actionTextColor: _brandSecondary,
      ),

      popupMenuTheme: PopupMenuThemeData(
        color: sheetBg,
        surfaceTintColor: Colors.transparent,
        textStyle: TextStyle(color: textPrimary, fontFamily: _font),
      ),

      listTileTheme: ListTileThemeData(
        iconColor: textPrimary,
        textColor: textPrimary,
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: textPrimary,
        unselectedLabelColor: textSecondary,
        indicatorColor: _brand,
      ),

      textTheme: _textTheme(textPrimary, textSecondary),
    );
  }

  static TextTheme _textTheme(Color primary, Color secondary) {
    TextStyle s(double size, FontWeight w, Color c) => TextStyle(
          fontSize: size.sp,
          fontWeight: w,
          color: c,
          fontFamily: _font,
        );
    return TextTheme(
      displayLarge: s(28, FontWeight.w700, primary),
      headlineMedium: s(22, FontWeight.w700, primary),
      titleLarge: s(20, FontWeight.w700, primary),
      titleMedium: s(18, FontWeight.w600, primary),
      bodyLarge: s(16, FontWeight.w500, primary),
      bodyMedium: s(14, FontWeight.w400, primary),
      bodySmall: s(13, FontWeight.w400, secondary),
      labelLarge: s(16, FontWeight.w600, primary),
      labelMedium: s(14, FontWeight.w500, secondary),
      labelSmall: s(12, FontWeight.w400, secondary),
    );
  }
}
