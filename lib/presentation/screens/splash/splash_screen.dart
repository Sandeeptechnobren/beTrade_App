import 'dart:async';
import 'package:betrade/presentation/auth/auth_screen.dart';
import 'package:betrade/presentation/screens/main_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/local_storage.dart';
import '../../onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_)  async{
      if (!mounted) return;
      precacheImage(const AssetImage("assets/images/splash.png"), context);
      precacheImage(const AssetImage("assets/images/IconLogo.png"), context);
      _navigateUser();
    });
  }



  Future<void> _navigateUser() async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    bool onboardingDone = false;
    String? token;

    try {
      onboardingDone = LocalStorage.isOnboardingDone() ?? false;
      token = LocalStorage.getToken();
    } catch (e) {
      debugPrint(" LocalStorage error: $e");
    }
    if (!mounted) return;
    try {
      if (!onboardingDone) {
        _go(const OnboardingScreen());
        return;
      }
      if (token == null || token.isEmpty) {
        _go(const AuthScreen());
        return;
      }
      final isValid = await AuthService().verifyToken(token);
      if (!mounted) return;
      if (isValid == true) {
        _go(const MainScreen(showWelcomePopup: false));
      } else if (isValid == false) {
        await LocalStorage.clearToken();
        _go(const AuthScreen());
      } else {
        debugPrint("Network issue, skipping token verification");
        _go(const MainScreen(showWelcomePopup: false));
      }
    } catch (e) {
      debugPrint(" Navigation error: $e");
      _go(const MainScreen(showWelcomePopup: false));
    }
  }

  void _go(Widget screen) {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/splash.png",
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) =>
                  Container(color: Colors.grey.shade300),
            ),
          ),
          Center(
            child: Image.asset(
              "assets/images/IconLogo.png",
              height: 175.h,
              width: 142.w,
              errorBuilder: (context, error, stack) => const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }
}
