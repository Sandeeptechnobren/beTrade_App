import 'package:flutter/foundation.dart';

/// Sink for forwarding errors to a crash-reporting backend (e.g. Crashlytics).
/// Registered once at startup so [AppLogger] stays decoupled from Firebase.
typedef ErrorSink = void Function(
  Object error,
  StackTrace? stack, {
  String? reason,
  bool fatal,
});

/// Lightweight structured logger.
///
/// - In debug builds it prints to the console with a level tag.
/// - In release builds `debug`/`info` are suppressed; `error` is forwarded to
///   the registered [ErrorSink] (crash reporting) if one is set.
/// - Bearer tokens are redacted so secrets never reach logs/crash reports.
///
/// Replaces the ~200 ad-hoc `print` / `debugPrint` calls across services
/// (CHALLENGES F16). Never pass raw tokens or full PII into a log message.
class AppLogger {
  AppLogger._();

  static ErrorSink? _errorSink;

  /// Wire a crash reporter (e.g. Crashlytics) as the error destination.
  static void registerErrorSink(ErrorSink sink) => _errorSink = sink;

  static final RegExp _bearer = RegExp(r'Bearer\s+[A-Za-z0-9._\-]+');

  static String _redact(String s) =>
      s.replaceAll(_bearer, 'Bearer ***');

  static void d(String tag, String message) {
    if (kDebugMode) debugPrint('[D] $tag: ${_redact(message)}');
  }

  static void i(String tag, String message) {
    if (kDebugMode) debugPrint('[I] $tag: ${_redact(message)}');
  }

  static void w(String tag, String message, [Object? error]) {
    if (kDebugMode) {
      final suffix = error != null ? ' :: ${_redact(error.toString())}' : '';
      debugPrint('[W] $tag: ${_redact(message)}$suffix');
    }
  }

  /// Logs an error and (in any build) forwards it to crash reporting.
  static void e(
    String tag,
    String message, {
    Object? error,
    StackTrace? stack,
    bool fatal = false,
  }) {
    if (kDebugMode) {
      final suffix = error != null ? ' :: ${_redact(error.toString())}' : '';
      debugPrint('[E] $tag: ${_redact(message)}$suffix');
    }
    if (error != null) {
      _errorSink?.call(error, stack, reason: '$tag: $message', fatal: fatal);
    }
  }
}
