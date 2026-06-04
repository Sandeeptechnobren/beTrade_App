import 'package:betrade/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../data/provider/theme_provider.dart';
import 'auth_bottom_sheet.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});
  Widget _buildBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/splash.png"),
          fit: BoxFit.cover,
          onError: (exception, stackTrace) {
            debugPrint(" Background image missing: $exception");
          },
        ),
      ),
    );
  }
  Widget _buildLogo() {
    return Image.asset(
      "assets/images/IconLogo.png",
      height: 80.h,
      errorBuilder: (context, error, stackTrace) {
        debugPrint("Logo image missing: $error");
        return Container(
          height: 175.h,
          width: 142.w,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.image_not_supported,
            size: 40.sp,
            color: Colors.white54,
          ),
        );
      },
    );
  }
  //
  // Widget _buildThemeToggle(ThemeProvider themeProvider, bool isDark) {
  //   return GestureDetector(
  //     onTap: () {
  //       try {
  //         themeProvider.toggleTheme(!isDark);
  //       } catch (e) {
  //         debugPrint(" Theme toggle error: $e");
  //       }
  //     },
  //     child: Container(
  //       padding: EdgeInsets.all(10.w),
  //       decoration: BoxDecoration(
  //         color: isDark
  //             ? Colors.white.withOpacity(0.1)
  //             : Colors.white.withOpacity(0.95),
  //         shape: BoxShape.circle,
  //         border: Border.all(
  //           color: isDark
  //               ? Colors.white.withOpacity(0.2)
  //               : Colors.black.withOpacity(0.05),
  //           width: 1,
  //         ),
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.black.withOpacity(0.08),
  //             blurRadius: 6,
  //             offset: const Offset(0, 2),
  //           ),
  //         ],
  //       ),
  //       child: Icon(
  //         isDark ? Icons.light_mode : Icons.dark_mode,
  //         size: 22.sp,
  //         color: isDark
  //             ? AppColors.disableButtonColor
  //             : Colors.black54,
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              _buildBackground(),
              Container(
                color: (themeProvider.isDark
                    ? Colors.black.withOpacity(0.7)
                    : Colors.black.withOpacity(0.3)),
              ),
              // Positioned(
              //   top: MediaQuery.of(context).padding.top + 20.h,
              //   right: 16.w,
              //   child: Consumer<ThemeProvider>(
              //     builder: (context, themeProvider, child) {
              //       return _buildThemeToggle(themeProvider, themeProvider.isDark);
              //     },
              //   ),
              // ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  child: _buildLogo(),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: const AuthBottomSheet(),
              ),
            ],
          );
        },
      ),
    );
  }
}