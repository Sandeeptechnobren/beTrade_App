// // lib/presentation/widget/dark_mode_toggle.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:provider/provider.dart';
// import '../../data/provider/theam_provider.dart';
//
// class DarkModeToggle extends StatelessWidget {
//   final bool showText;
//   final double size;
//
//   const DarkModeToggle({
//     super.key,
//     this.showText = false,
//     this.size = 24,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     // ✅ Using Consumer for real-time updates
//     return Consumer<ThemeProvider>(
//       builder: (context, themeProvider, child) {
//         final isDark = themeProvider.isDark;
//
//         return GestureDetector(
//           onTap: () {
//             // ✅ Toggle theme - this will update EVERYWHERE
//             themeProvider.toggleTheme(!isDark);
//           },
//           child: Container(
//             padding: showText
//                 ? EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h)
//                 : EdgeInsets.all(8.w),
//             decoration: BoxDecoration(
//               color: isDark
//                   ? Colors.white.withOpacity(0.1)
//                   : Colors.black.withOpacity(0.05),
//               borderRadius: BorderRadius.circular(30.r),
//             ),
//             child: showText
//                 ? Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(
//                   isDark ? Icons.light_mode : Icons.dark_mode,
//                   size: size.sp,
//                   color: isDark ? Colors.white : Colors.black87,
//                 ),
//                 SizedBox(width: 8.w),
//                 Text(
//                   isDark ? "Light Mode" : "Dark Mode",
//                   style: TextStyle(
//                     fontSize: 14.sp,
//                     color: isDark ? Colors.white : Colors.black87,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             )
//                 : Icon(
//               isDark ? Icons.light_mode : Icons.dark_mode,
//               size: size.sp,
//               color: isDark ? Colors.white : Colors.black87,
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
// lib/presentation/widget/dark_mode_toggle.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../data/provider/theam_provider.dart';

class DarkModeToggle extends StatelessWidget {
  final bool showText;
  final double size;
  final bool showBackground; // ✅ New property

  const DarkModeToggle({
    super.key,
    this.showText = false,
    this.size = 24,
    this.showBackground = true, // ✅ Default true
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDark;

        return GestureDetector(
          onTap: () {
            themeProvider.toggleTheme(!isDark);
          },
          child: Container(
            padding: showText
                ? EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h)
                : EdgeInsets.all(10.w), // ✅ Increased padding for better tap area
            decoration: showBackground ? BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.15)
                  : Colors.black.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.3)
                    : Colors.black.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ) : null,
            child: showText
                ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isDark ? Icons.light_mode : Icons.dark_mode,
                  size: size.sp,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                SizedBox(width: 8.w),
                Text(
                  isDark ? "Light Mode" : "Dark Mode",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            )
                : Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              size: size.sp,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        );
      },
    );
  }
}