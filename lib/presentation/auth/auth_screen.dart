import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
      height: 160.h,
      width: 120.w,
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              _buildBackground(),
              Container(
                color: isDark
                    ? Colors.black.withOpacity(0.7)
                    : Colors.black.withOpacity(0.3),
              ),
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