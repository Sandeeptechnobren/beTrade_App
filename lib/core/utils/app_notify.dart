import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../presentation/widget/app_confirm_dialog.dart';
import '../../presentation/widget/app_success_dialog.dart';
import '../../presentation/widget/app_toast.dart';
import 'backend_errors.dart';

/// Variants for `AppNotify` toasts. Drives the icon + colour triplet
/// inside `AppToast`.
enum NotifyVariant { success, error, warning, info, loading }

/// Optional trailing action on a toast — e.g. "Retry", "Undo", "View".
/// Tapping fires `onTap` and dismisses the toast.
class NotifyAction {
  const NotifyAction({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
}

/// App-wide notification facade. Single entry point for every
/// user-visible toast, confirm prompt, and success ceremony.
///
/// Backed by a global `ScaffoldMessengerKey` wired in `main.dart`, so
/// callers don't need a `BuildContext` for toasts. Useful from providers,
/// services, post-await callbacks, and post-pop completions where
/// holding a live context is fragile.
///
/// Quick reference:
///   ```dart
///   AppNotify.success('Profile updated.');
///   AppNotify.error('Could not load wallet.',
///       action: NotifyAction(label: 'Retry', onTap: () => wallet.fetch()));
///   AppNotify.warning('Market closes in 5 minutes.');
///   AppNotify.info('Your default amount is 10 GHS.');
///
///   AppNotify.loading('Loading your settings…');
///   // …work…
///   AppNotify.dismiss();
///
///   AppNotify.fromCode(code: result.code,
///       fallback: 'Could not place the trade.');
///
///   final ok = await AppNotify.confirm(
///     context: context,
///     title: 'Logout?', body: 'You\'ll need to sign in again.',
///     confirmText: 'Logout', destructive: true,
///   );
///   if (ok) await auth.logout();
///
///   await AppNotify.successDialog(
///     context: context,
///     title: 'Deposit Successful',
///     body: 'Your deposit has been completed.',
///     primaryText: 'Done',
///   );
///   ```
class AppNotify {
  AppNotify._();

  /// Wired into `MaterialApp.scaffoldMessengerKey` in `main.dart`.
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  // ── Toast variants ───────────────────────────────────────────────

  static void success(
    String message, {
    String? title,
    NotifyAction? action,
    Duration duration = const Duration(seconds: 3),
  }) =>
      _show(NotifyVariant.success, message,
          title: title, action: action, duration: duration);

  static void error(
    String message, {
    String? title,
    NotifyAction? action,
    Duration duration = const Duration(seconds: 4),
  }) =>
      _show(NotifyVariant.error, message,
          title: title, action: action, duration: duration);

  static void warning(
    String message, {
    String? title,
    NotifyAction? action,
    Duration duration = const Duration(seconds: 4),
  }) =>
      _show(NotifyVariant.warning, message,
          title: title, action: action, duration: duration);

  static void info(
    String message, {
    String? title,
    NotifyAction? action,
    Duration duration = const Duration(seconds: 3),
  }) =>
      _show(NotifyVariant.info, message,
          title: title, action: action, duration: duration);

  /// Persistent loading toast with a spinner and a close-X. Call
  /// [dismiss] when the work finishes — or it will sit on screen for
  /// the full SnackBar lifetime (24 h cap).
  static void loading(String message, {String? title}) => _show(
        NotifyVariant.loading,
        message,
        title: title,
        duration: const Duration(days: 1),
      );

  /// Hide the current toast (loading or otherwise).
  static void dismiss() => messengerKey.currentState?.hideCurrentSnackBar();

  // ── Backend code → toast ─────────────────────────────────────────

  /// Show an error toast for a typed backend code. Looks the code up in
  /// [BackendErrors]; falls back to [fallback] when unknown/null.
  /// Use everywhere the API surfaces a `code` field (BuyResponse,
  /// WalletProvider.lastInitiateCode/lastSubmitCode, etc.) — never
  /// pass the raw backend `message` to the user.
  static void fromCode({
    required String? code,
    required String fallback,
    NotifyAction? action,
  }) {
    error(
      BackendErrors.messageFor(code, fallback: fallback),
      action: action,
    );
  }

  // ── Modal: confirm ──────────────────────────────────────────────

  /// Yes/No-style confirmation dialog. Returns `true` if confirmed,
  /// `false` on cancel or barrier dismiss. Pass [destructive] to tint
  /// the confirm button red (delete, logout, forfeit, etc.).
  ///
  /// [context] is required (a dialog needs a Navigator above it). Most
  /// callers pass `context` from the originating screen; providers/
  /// services without a context should defer to a UI layer.
  static Future<bool> confirm({
    required BuildContext context,
    required String title,
    required String body,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool destructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.32),
      builder: (_) => AppConfirmDialog(
        title: title,
        body: body,
        confirmText: confirmText,
        cancelText: cancelText,
        destructive: destructive,
      ),
    );
    return result ?? false;
  }

  // ── Modal: success ceremony ─────────────────────────────────────

  /// Full-screen success dialog. Use for **important** wins (deposit /
  /// withdraw / KYC submitted) — small wins (profile saved) should use
  /// [success] instead.
  ///
  /// Both callbacks default to popping the dialog. Override either to
  /// chain another navigation (e.g. open SavedPaymentMethodsSheet from
  /// the deposit-success secondary).
  static Future<void> successDialog({
    required BuildContext context,
    required String title,
    required String body,
    String primaryText = 'Done',
    VoidCallback? onPrimary,
    String? secondaryText,
    VoidCallback? onSecondary,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.32),
      builder: (dialogCtx) => AppSuccessDialog(
        title: title,
        body: body,
        primaryText: primaryText,
        onPrimary: onPrimary ?? () => Navigator.pop(dialogCtx),
        secondaryText: secondaryText,
        onSecondary: onSecondary,
      ),
    );
  }

  // ── Internals ────────────────────────────────────────────────────

  static void _show(
    NotifyVariant variant,
    String message, {
    String? title,
    NotifyAction? action,
    required Duration duration,
  }) {
    final messenger = messengerKey.currentState;
    if (messenger == null) {
      // No messenger yet (called before MaterialApp built or during
      // teardown). Best we can do is drop it — the alternative is a
      // crash. Log if needed for debugging.
      assert(() {
        debugPrint(
            '⚠ AppNotify._show called with no ScaffoldMessenger '
            '(variant=$variant, message="$message")');
        return true;
      }());
      return;
    }
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        duration: duration,
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: 80.h, left: 16.w, right: 16.w),
        padding: EdgeInsets.zero,
        content: AppToast(
          variant: variant,
          title: title,
          message: message,
          action: action,
          onDismiss: messenger.hideCurrentSnackBar,
        ),
      ),
    );
  }
}
