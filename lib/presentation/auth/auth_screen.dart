// // import 'package:flutter/material.dart';
// // import 'package:flutter_screenutil/flutter_screenutil.dart';
// // import 'auth_bottom_sheet.dart';
// // class AuthScreen extends StatelessWidget {
// //   const AuthScreen({super.key});
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: Stack(
// //         children: [
// //           Container(
// //             width: double.infinity,
// //             height: double.infinity,
// //             decoration: const BoxDecoration(
// //               image: DecorationImage(image: AssetImage("assets/images/splash.png"), fit: BoxFit.cover,),),
// //           ),
// //           Container(
// //             color: Colors.black.withOpacity(0.3),
// //           ),
// //           Align(
// //             alignment: Alignment.center,
// //             child: Image.asset("assets/images/IconLogo.png", height: 100.h,),
// //           ),
// //           Align(alignment: Alignment.bottomCenter, child: const AuthBottomSheet(),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
//
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:provider/provider.dart';
// import '../../../data/provider/theam_provider.dart';
// import '../widget/dark_mode_toggle.dart';
// import 'auth_bottom_sheet.dart';
//
// class AuthScreen extends StatelessWidget {
//   const AuthScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<ThemeProvider>(
//       builder: (context, themeProvider, child) {
//         final isDark = themeProvider.isDark;
//         return Scaffold(
//           body: Stack(
//             children: [
//               // Background Image
//               Container(
//                 width: double.infinity,
//                 height: double.infinity,
//                 decoration: const BoxDecoration(
//                   image: DecorationImage(
//                     image: AssetImage("assets/images/splash.png"),
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//               // Dynamic Overlay based on theme
//               Container(
//                 color: isDark
//                     ? Colors.black.withOpacity(0.7)
//                     : Colors.black.withOpacity(0.3),
//               ),
//               Positioned(
//                 top: 50.h,
//                 right: 16.w,
//                 child: const DarkModeToggle(
//                   showText: false,
//                   size: 24,
//                 ),
//               ),
//               // Center Logo
//               Align(
//                 alignment: Alignment.center,
//                 child: Image.asset(
//                   "assets/images/IconLogo.png",
//                   height: 100.h,
//                 ),
//               ),
//               // Bottom Sheet
//               const Align(
//                 alignment: Alignment.bottomCenter,
//                 child: AuthBottomSheet(),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
import 'package:betrade/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../data/provider/theam_provider.dart';
import 'auth_bottom_sheet.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDark;

        return Scaffold(
          body: Stack(
            children: [
              // Background Image
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/splash.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Dynamic Overlay
              Container(
                color: isDark
                    ? Colors.black.withOpacity(0.7)
                    : Colors.black.withOpacity(0.3),
              ),
              Positioned(
                top: 50.h,
                right: 16.w,
                child: GestureDetector(
                  onTap: () {
                    themeProvider.toggleTheme(!isDark);
                  },
                  child: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white
                              .withOpacity(0.1) // Soft transparent white
                          : Colors.white.withOpacity(0.95),
                      // Almost white but soft
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.2)
                            : Colors.black.withOpacity(0.05),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      isDark ? Icons.light_mode : Icons.dark_mode,
                      size: 22.sp,
                      color: isDark
                          ? AppColors.disableButtonColor
                          : Colors.black54, // Soft black
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    "assets/images/IconLogo.png",
                    height: 80.h,
                  ),
                ),
              ),
              const Align(
                alignment: Alignment.bottomCenter,
                child: AuthBottomSheet(),
              ),
            ],
          ),
        );
      },
    );
  }
}
