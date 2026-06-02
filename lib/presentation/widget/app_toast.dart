import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/app_notify.dart';

/// Single toast widget shared by every AppNotify call. Variants:
///   success — emerald, check icon
///   error   — red,     x-circle icon
///   warning — amber,   alert-triangle icon
///   info    — violet,  info icon
///   loading — violet,  spinner; persists until AppNotify.dismiss()
///
/// Hosted inside a floating SnackBar by AppNotify._show. Theme-aware via
/// the AppColors `*Dynamic` tokens; uses lucide_icons for a single icon
/// family across the app.
class AppToast extends StatelessWidget {
  const AppToast({
    super.key,
    required this.variant,
    required this.message,
    this.title,
    this.action,
    this.onDismiss,
  });

  final NotifyVariant variant;
  final String? title;
  final String message;
  final NotifyAction? action;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final tokens = _ToastTokens.of(context, variant);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: tokens.bg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: tokens.border, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Leading icon (or spinner for loading)
          _LeadingGlyph(tokens: tokens, variant: variant),
          SizedBox(width: 12.w),
          // Title + message
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null && title!.isNotEmpty) ...[
                  Text(
                    title!,
                    style: TextStyle(
                      fontFamily: 'SFProRounded',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: tokens.fg,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 2.h),
                ],
                Text(
                  message,
                  style: TextStyle(
                    fontFamily: 'SFProRounded',
                    fontSize: 13.sp,
                    fontWeight: title != null
                        ? FontWeight.w400
                        : FontWeight.w500,
                    color: tokens.fg,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          // Trailing — action button OR close-X for loading
          if (action != null) ...[
            SizedBox(width: 8.w),
            _ActionButton(
              label: action!.label,
              color: tokens.fg,
              onTap: () {
                onDismiss?.call();
                action!.onTap();
              },
            ),
          ] else if (variant == NotifyVariant.loading) ...[
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: onDismiss,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.all(2.w),
                child: Icon(LucideIcons.x, color: tokens.fg, size: 18.sp),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LeadingGlyph extends StatelessWidget {
  const _LeadingGlyph({required this.tokens, required this.variant});
  final _ToastTokens tokens;
  final NotifyVariant variant;

  @override
  Widget build(BuildContext context) {
    if (variant == NotifyVariant.loading) {
      return SizedBox(
        width: 20.sp,
        height: 20.sp,
        child: Padding(
          padding: EdgeInsets.all(2.sp),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(tokens.fg),
          ),
        ),
      );
    }
    return Icon(tokens.icon, color: tokens.fg, size: 20.sp);
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton(
      {required this.label, required this.color, required this.onTap});
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: color,
      ),
      onPressed: onTap,
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontFamily: 'SFProRounded',
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Positions an [AppToast] at the TOP of the screen (below the status
/// bar via SafeArea), with a 220 ms slide-down + fade-in animation.
/// Tap the toast to dismiss early; AppNotify schedules the
/// auto-dismiss timer separately.
///
/// Driven by an OverlayEntry inserted by [AppNotify._show]. We use an
/// overlay rather than a SnackBar so the toast can live at the top —
/// Flutter's ScaffoldMessenger only supports bottom placement.
class AppToastOverlay extends StatefulWidget {
  const AppToastOverlay({
    super.key,
    required this.variant,
    required this.message,
    required this.onRemove,
    this.title,
    this.action,
  });

  /// Called when the user taps the toast (or the trailing action /
  /// loading close-X). AppNotify wires this to remove the OverlayEntry.
  final VoidCallback onRemove;
  final NotifyVariant variant;
  final String? title;
  final String message;
  final NotifyAction? action;

  @override
  State<AppToastOverlay> createState() => _AppToastOverlayState();
}

class _AppToastOverlayState extends State<AppToastOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, -0.3),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
  late final Animation<double> _fade = CurvedAnimation(
    parent: _ctrl,
    curve: Curves.easeOut,
  );

  @override
  void initState() {
    super.initState();
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.only(top: 8.h, left: 16.w, right: 16.w),
          child: SlideTransition(
            position: _slide,
            child: FadeTransition(
              opacity: _fade,
              child: Material(
                color: Colors.transparent,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.onRemove,
                  child: AppToast(
                    variant: widget.variant,
                    title: widget.title,
                    message: widget.message,
                    action: widget.action,
                    onDismiss: widget.onRemove,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// {bg, fg, border, icon} for a given variant + theme brightness.
class _ToastTokens {
  const _ToastTokens(this.bg, this.fg, this.border, this.icon);
  final Color bg;
  final Color fg;
  final Color border;
  final IconData icon;

  static _ToastTokens of(BuildContext context, NotifyVariant v) {
    switch (v) {
      case NotifyVariant.success:
        return _ToastTokens(
          AppColors.successBgDynamic(context),
          AppColors.successFgDynamic(context),
          AppColors.successBorderDynamic(context),
          LucideIcons.checkCircle2,
        );
      case NotifyVariant.error:
        return _ToastTokens(
          AppColors.errorBgDynamic(context),
          AppColors.errorFgDynamic(context),
          AppColors.errorBorderDynamic(context),
          LucideIcons.xCircle,
        );
      case NotifyVariant.warning:
        return _ToastTokens(
          AppColors.warningBgDynamic(context),
          AppColors.warningFgDynamic(context),
          AppColors.warningBorderDynamic(context),
          LucideIcons.alertTriangle,
        );
      case NotifyVariant.info:
        return _ToastTokens(
          AppColors.infoBgDynamic(context),
          AppColors.infoFgDynamic(context),
          AppColors.infoBorderDynamic(context),
          LucideIcons.info,
        );
      case NotifyVariant.loading:
        return _ToastTokens(
          AppColors.infoBgDynamic(context),
          AppColors.infoFgDynamic(context),
          AppColors.infoBorderDynamic(context),
          LucideIcons.loader, // unused — spinner replaces the icon
        );
    }
  }
}
