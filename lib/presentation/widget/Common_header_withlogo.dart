import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_style.dart';

class GlobalAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onNotificationTap;
  final bool showNotification;
  final Widget? leading;
  final Color? backgroundColor;

  /// Bottom hairline. Default true (Home/Explore/Portfolio/Profile keep
  /// it). Rankings sets false because its tab bar draws the only divider
  /// right under the tabs.
  final bool showDivider;

  const GlobalAppBar({
    super.key,
    this.onNotificationTap,
    this.showNotification = true,
    this.leading,
    this.backgroundColor,
    this.showDivider = true,
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
      // Header matches the scaffold bg (like Home) so the notification
      // circle (#2A2A2A) keeps its contrast in dark mode instead of
      // blending into a same-colored header.
      backgroundColor:
          backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,

      automaticallyImplyLeading: false,
      leading: leading,
      titleSpacing: 0,
      // Figma "Frame 1" row height is 60 (59 toolbar + 1px hairline).
      toolbarHeight: 59.h,

      title: Padding(
        padding: EdgeInsets.only(left:16.w),
        child: Row(
          children: [
            Image.asset("assets/logo/IconLogo.png", height:32.h,width: 27.w,),
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
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                          fontFamily: AppTextStyle.fontFamily,
                        ),
                      ),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.top,
                        child: Transform.translate(
                          offset: const Offset(1, -1.5),
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

      bottom: showDivider
          ? PreferredSize(
              preferredSize: Size.fromHeight(1),
              child: Container(
                height: 1,
                color: isDark
                    ? Colors.grey.shade800       // dark mode divider
                    : const Color(0xFFE4E4E7),   // Figma #E4E4E7
              ),
            )
          : null,

      actions: [
        if (showNotification)
          Padding(
            padding: EdgeInsets.only(right:16.w),
            child: GestureDetector(
              onTap: onNotificationTap,
              child:
              Container(
                width: 40.w,
                height: 40.h,
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  // Figma #F4F4F5
                  color: AppColors.iconContainerDynamic(context),
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  "assets/svgs/Bell.svg",
                  width: 24.w,
                  height: 24.h,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(showDivider ? 60.h : 59.h);
}
