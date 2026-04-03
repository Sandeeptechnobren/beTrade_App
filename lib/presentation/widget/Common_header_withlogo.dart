import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GlobalAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onNotificationTap;
  final bool showNotification;
  final Widget? leading;
  final Color backgroundColor;

  const GlobalAppBar({
    super.key,
    this.onNotificationTap,
    this.showNotification = true,
    this.leading,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: backgroundColor,
      automaticallyImplyLeading: false,

      leading: leading,

      titleSpacing: 0,
      title: Row(
        children: [
          SizedBox(width: 8.w),
          Image.asset(
            "assets/logo/betrade_logo.png",
            height: 33.h,
          ),
        ],
      ),

      actions: [
        if (showNotification)
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: GestureDetector(
              onTap: onNotificationTap,
              child: Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_none,
                  color: Colors.black,
                  size: 20,
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