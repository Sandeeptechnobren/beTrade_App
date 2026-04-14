// import 'dart:async';
// import 'package:betrade/presentation/auth/auth_screen.dart';
// import 'package:betrade/presentation/bottom_navigation/bottom_nav.dart';
// import 'package:betrade/presentation/screens/main_screen.dart';
// import 'package:flutter/material.dart';
// import '../../../data/services/local_storage.dart';
// import '../../onboarding/onboarding_screen.dart';
// import '../signin/login_screen.dart';
//
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> {
//
//   @override
//   void initState() {
//     super.initState();
//     navigateUser();
//   }
//
//   void navigateUser() async {
//     await Future.delayed(const Duration(seconds: 2));
//     if (!mounted) return;
//     bool onboardingDone = LocalStorage.isOnboardingDone();
//     String? token = LocalStorage.getToken();
//
//     if (!onboardingDone) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const OnboardingScreen()),
//       );
//     }
//     else if (token == null || token.isEmpty) {
//       Navigator.pushReplacement(
//         context,
//         // MaterialPageRoute(builder: (_) => const LoginScreen()),
//         MaterialPageRoute(builder: (_) => const AuthScreen()),
//       );
//     }
//     else {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const MainScreen(showWelcomePopup: false,)),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           Positioned.fill(
//             child: Image.asset(
//               "assets/images/splash.png",
//               fit: BoxFit.cover,
//             ),
//           ),
//           Center(
//             child: Image.asset(
//               "assets/images/IconLogo.png",
//               height: 175,
//               width: 142,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'dart:async';
import 'package:betrade/presentation/auth/auth_screen.dart';
import 'package:betrade/presentation/screens/main_screen.dart';
import 'package:flutter/material.dart';
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

    // ✅ SINGLE postFrameCallback - No race condition
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Preload images
      precacheImage(const AssetImage("assets/images/splash.png"), context);
      precacheImage(const AssetImage("assets/images/IconLogo.png"), context);

      // Navigate
      _navigateUser();
    });
  }

  void _navigateUser() async {
    // Small delay for smooth transition (optional, remove if not needed)
    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    // Safe LocalStorage access
    bool onboardingDone = false;
    String? token;

    try {
      onboardingDone = LocalStorage.isOnboardingDone() ?? false;
      token = LocalStorage.getToken();
    } catch (e) {
      debugPrint("❌ LocalStorage error: $e");
      // Default values already set, continue
    }

    if (!mounted) return;

    // Navigation logic
    try {
      if (!onboardingDone) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      } else if (token == null || token.isEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AuthScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen(showWelcomePopup: false)),
        );
      }
    } catch (e) {
      debugPrint("❌ Navigation error: $e");
      // Fallback - retry after delay
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) _navigateUser();
        });
      }
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
              errorBuilder: (context, error, stack) =>
                  Container(color: Colors.grey.shade300),
            ),
          ),
          Center(
            child: Image.asset(
              "assets/images/IconLogo.png",
              height: 175,
              width: 142,
              errorBuilder: (context, error, stack) =>
              const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }
}