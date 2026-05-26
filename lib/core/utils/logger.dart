import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Lightweight logging facade. Centralised so release builds don't dump
/// auth tokens, full backend responses, or user PII into `adb logcat`
/// where they're observable on any device.
///
/// Use these helpers instead of bare `print(...)` or `debugPrint(...)`
/// for anything that could touch sensitive data:
///
///   * [d]         — debug. Stripped by tree-shaking in release builds.
///   * [i]         — info. Kept in release; pass only non-sensitive
///                   lifecycle strings ("OTP sent", "Wallet refreshed").
///   * [e]         — error. Kept in release. Safe to wire into Sentry
///                   or Crashlytics later.
///   * [dRedacted] — debug with auto-masking. Use for tokens, OTPs,
///                   phone numbers, or any other secret value.
///
/// All output goes through `dart:developer.log` with a project-scoped
/// `name:` so it's filterable in DevTools and `flutter logs`.
class AppLogger {
  AppLogger._();

  /// Debug-only. Calls behind this method are eliminated by Dart's
  /// tree-shaker in `--release` builds because `kDebugMode` resolves to
  /// a `const false`. Use this for noisy dev logs (status codes, flow
  /// markers, etc.).
  static void d(String tag, String message) {
    if (kDebugMode) {
      developer.log(message, name: tag);
    }
  }

  /// Info — survives release. Reserve for short, non-sensitive
  /// lifecycle events (e.g. "OTP sent", "Logout complete"). Never pass
  /// a full backend response or a bearer token.
  static void i(String tag, String message) {
    developer.log(message, name: tag);
  }

  /// Warning — survives release. Use when something unexpected happened
  /// but the app can keep going (e.g. token refresh fallback, retry).
  static void w(String tag, String message, [Object? error]) {
    developer.log(
      message,
      name: tag,
      level: 900,
      error: error,
    );
  }

  /// Error — survives release. Stack trace is included in debug only;
  /// in release we strip it to avoid leaking file paths or implementation
  /// internals. Safe to forward to crash reporting later.
  static void e(
    String tag,
    String message, [
    Object? error,
    StackTrace? stack,
  ]) {
    developer.log(
      message,
      name: tag,
      level: 1000,
      error: error,
      stackTrace: kDebugMode ? stack : null,
    );
  }

  /// Debug log with automatic masking. Use for any value that might be
  /// a token, OTP, phone number, or other secret — keeps first 4 +
  /// last 4 chars so you can sanity-check identity without exposing
  /// the full string.
  static void dRedacted(String tag, String label, String? value) {
    if (kDebugMode) {
      developer.log('$label: ${redact(value)}', name: tag);
    }
  }

  /// Mask a value for safe logging. Returns `****` for short values and
  /// `XXXX…YYYY` for longer ones. Exposed so callers can build their own
  /// formatted strings.
  static String redact(String? value) {
    if (value == null || value.isEmpty) return '<empty>';
    if (value.length <= 8) return '****';
    return '${value.substring(0, 4)}…${value.substring(value.length - 4)}';
  }
}
