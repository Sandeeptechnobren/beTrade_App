import 'dart:async';
import 'package:betrade/presentation/bottom_navigation/bottom_nav.dart';
import 'package:betrade/presentation/screens/main_screen.dart';
import 'package:flutter/material.dart';
import '../../../data/services/local_storage.dart';
import '../../onboarding/onboarding_screen.dart';
import '../signin/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    navigateUser();
  }

  void navigateUser() async {
    await Future.delayed(const Duration(seconds: 2));

    bool onboardingDone = LocalStorage.isOnboardingDone();
    String? token = LocalStorage.getToken();

    if (!onboardingDone) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
    else if (token == null || token.isEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
    else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    }
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
            ),
          ),
          Center(
            child: Image.asset(
              "assets/images/IconLogo.png",
              height: 175,
              width: 142,
            ),
          ),
        ],
      ),
    );
  }
}