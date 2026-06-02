import 'package:flutter/material.dart';

import '../../core/utils/app_notify.dart';

/// Backwards-compatible shim — delegates to [AppNotify] so the 41
/// pre-existing call sites pick up the unified style automatically.
///
/// **For new code, call `AppNotify.success/error/warning/info(…)` directly.**
/// This shim still requires a `BuildContext`, doesn't accept a title or
/// trailing action, and has no `warning` variant — all addressed by
/// `AppNotify`. We'll delete this file once every call site has been
/// migrated in Phase 2.
///
/// Mapping kept stable:
///   - `showError`   → `AppNotify.error`
///   - `showSuccess` → `AppNotify.success`
///   - `showLoader`  → `AppNotify.info` (the legacy loader was just a
///     purple-bg snackbar; `AppNotify.loading` would persist, which is
///     not what the old `showLoader(duration: 3s)` callers expect, so
///     this maps to a single 3 s info toast instead).
class CustomSnackBar {
  CustomSnackBar._();

  static void showError(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    AppNotify.error(message, duration: duration);
  }

  static void showSuccess(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    AppNotify.success(message, duration: duration);
  }

  static void showLoader(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    AppNotify.info(message, duration: duration);
  }
}
