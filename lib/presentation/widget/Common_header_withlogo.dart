import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';

class GlobalAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onNotificationTap;
  final bool showNotification;
  final Widget? leading;
  final Color? backgroundColor;

  const GlobalAppBar({
    super.key,
    this.onNotificationTap,
    this.showNotification = true,
    this.leading,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      elevation: 0,
      // Material 3 applies a surfaceTint overlay (and a 3pt elevation) when
      // body content scrolls under the AppBar — that's what was turning the
      // header gray. Zero both out so the bg stays the bg we set.
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      backgroundColor:
      backgroundColor ?? (isDark ? const Color(0xFF2A2A2A) : Colors.white),

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

      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Container(
          height: 1,
          color: isDark
              ? Colors.grey.shade800   // dark mode divider
              : Colors.grey.shade300,  // light mode divider
        ),
      ),

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
  Size get preferredSize => Size.fromHeight(56.h);
}
