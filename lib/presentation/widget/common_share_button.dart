// import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// class CommonShareButton extends StatelessWidget {
//   final VoidCallback onTap;
//   final double size;
//   final Color iconColor;
//   final Color backgroundColor;
//   final bool showBackground;
//
//   const CommonShareButton({
//     super.key,
//     required this.onTap,
//     this.size = 20,
//     this.iconColor = Colors.black,
//     this.backgroundColor = const Color(0xFFE0E0E0),
//     this.showBackground = true,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     Widget icon = Icon(
//       CupertinoIcons.arrowshape_turn_up_right,
//       size: size.sp,
//       color: iconColor,
//     );
//
//     return GestureDetector(
//       onTap: onTap,
//       child: showBackground
//           ? Container(
//         height: 36.w,
//         width: 36.w,
//         decoration: BoxDecoration(
//           color: backgroundColor,
//           shape: BoxShape.circle,
//         ),
//         child: Center(child: icon),
//       )
//           : icon,
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CommonShareButton extends StatelessWidget {
  final VoidCallback onTap;
  final double size;

  final Color? iconColor;       // ✅ nullable
  final Color? backgroundColor; // ✅ nullable

  final bool showBackground;

  const CommonShareButton({
    super.key,
    required this.onTap,
    this.size = 20,
    this.iconColor,
    this.backgroundColor,
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ✅ Dynamic defaults
    final bgColor = backgroundColor ??
        (isDark
            ? const Color(0xFF2A2A2A)   // dark mode
            : const Color(0xFFE0E0E0)); // light mode

    final icColor = iconColor ??
        (isDark ? Colors.white : Colors.black);

    Widget icon = Icon(
      CupertinoIcons.arrowshape_turn_up_right,
      size: size.sp,
      color: icColor,
    );

    return GestureDetector(
      onTap: onTap,
      child: showBackground
          ? Container(
        height: 36.w,
        width: 36.w,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        child: Center(child: icon),
      )
          : icon,
    );
  }
}