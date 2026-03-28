import 'package:betrade/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class IconContainer extends StatelessWidget {
  final IconData icon;
  final Color color, iconColor;
  const IconContainer({
    super.key,
    required this.icon,
    required this.color,
    required this.iconColor,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(50.r),
      onTap: () => Navigator.pop(context),
      child: Container(
        height: 40.h,
        width: 40.w,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 20.sp, color: iconColor),
      ),
    );
  }
}
