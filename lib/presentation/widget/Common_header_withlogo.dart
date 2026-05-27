import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';

class GlobalAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onNotificationTap;
  final bool showNotification;
  final Widget? leading;
  final Color? backgroundColor;

  /// When `false`, suppress the 1 px grey hairline drawn under the
  /// title row. Useful when the screen wants its own divider further
  /// down (e.g. Rankings places the divider under the tab strip so the
  /// active tab's underline sits on it).
  final bool showBottomDivider;

  /// Optional widget rendered tightly under the title row in the
  /// AppBar's native `bottom` slot. When provided, it REPLACES the
  /// hairline divider (and `showBottomDivider` is ignored).
  /// Used by the Rankings screen to host its 4-tab TabBar so the
  /// labels hug the BeTrade™ row with no extra vertical padding.
  final PreferredSizeWidget? bottom;

  const GlobalAppBar({
    super.key,
    this.onNotificationTap,
    this.showNotification = true,
    this.leading,
    this.backgroundColor,
    this.showBottomDivider = true,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      elevation: 0,
      backgroundColor:
      backgroundColor ?? (isDark ? const Color(0xFF2A2A2A) : Colors.white),
      // Material 3 AppBars apply a surface-tint overlay that darkens the
      // bar when content scrolls under it — this is the cause of QA #2.2
      // ("scrolling on the homepage turns the navbar grey"). Disable both
      // the tint and the under-scroll elevation so the navbar stays at the
      // backgroundColor we picked.
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,

      // Explicit toolbarHeight so Material doesn't fall back to the
      // hard-coded `kToolbarHeight = 56.0` constant — that would
      // disagree with our `56.h` preferredSize on devices whose
      // ScreenUtil scaling factor isn't exactly 1.0, causing the title
      // row to render at a different Y than on screens that don't pass
      // a `bottom` widget. Locking this here keeps the BeTrade™ row
      // pixel-identical across Explore / Rankings / Portfolio / Profile.
      toolbarHeight: 56.h,
      automaticallyImplyLeading: false,
      leading: leading,
      titleSpacing: 0,

      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: [
            Image.asset("assets/logo/IconLogo.png", height: 35.h),
            SizedBox(width: 5.w),
            Builder(
              builder: (context) {
                final isDark =
                    Theme.of(context).brightness == Brightness.dark;
                final textColor =
                isDark ? Colors.white : const Color(0xFF1A0D2B);

                return RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "BeTrade",
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.top,
                        child: Transform.translate(
                          offset: const Offset(1, -5),
                          child: Text(
                            "™",
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),

      // Bottom slot precedence: explicit `bottom` > divider > nothing.
      // The Rankings TabBar lives here via `bottom`.
      bottom: bottom ??
          (showBottomDivider
              ? PreferredSize(
                  preferredSize: Size.fromHeight(1),
                  child: Container(
                    height: 1,
                    color: isDark
                        ? Colors.grey.shade800 // dark mode divider
                        : Colors.grey.shade300, // light mode divider
                  ),
                )
              : null),

      actions: [
        if (showNotification)
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: GestureDetector(
              onTap: onNotificationTap,
              child: Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: AppColors.inputFieldBgDynamic(context),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Image.asset(
                    "assets/images/Bell.png",
                    width: 20.w,
                    height: 20.h,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize {
    // Toolbar (56.h) + whichever bottom widget is active (custom bottom,
    // divider, or nothing). Without this, the AppBar would clip a
    // taller `bottom` (like a TabBar) because Material reserves only
    // the title-row height.
    final extra = bottom?.preferredSize.height ??
        (showBottomDivider ? 1.0 : 0.0);
    return Size.fromHeight(56.h + extra);
  }
}
