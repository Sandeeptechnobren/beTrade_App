import 'dart:async';
import 'package:betrade/presentation/auth/auth_screen.dart';
import 'package:betrade/presentation/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/provider/country_provider.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/local_storage.dart';
import '../../onboarding/onboarding_screen.dart';

/// First screen. Decides where to send the user based on:
///   - onboarding flag (first-launch users go through `OnboardingScreen`)
///   - persisted bearer token (signed-in users skip to `MainScreen`)
///   - token-validity probe against `/api/verify-token`
///
/// While the routing decision is in flight, we also kick off the countries
/// fetch in parallel via `CountryProvider`. By the time the user reaches
/// LoginScreen the picker is already populated — no spinner, no waiting.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      precacheImage(const AssetImage("assets/images/splash.png"), context);
      precacheImage(const AssetImage("assets/images/IconLogo.png"), context);
      // Fire-and-forget pre-warm. Don't await — we want the routing decision
      // to proceed in parallel. If countries are still loading when the
      // user reaches LoginScreen, the picker shows its existing spinner;
      // in practice the routing decision (token verify) takes longer.
      _prewarmCountries();
      _navigateUser();
    });
  }

  /// Hydrate countries from disk cache if available, then refresh from the
  /// network in the background. The cache hit is sub-millisecond and lets
  /// the LoginScreen show a flag immediately even before the network
  /// returns.
  void _prewarmCountries() {
    if (!mounted) return;
    final provider = context.read<CountryProvider>();
    final hit = provider.loadFromCacheIfFresh();
    // Always trigger a refresh: with cache hit, runs as background sync;
    // without, this is the first real fetch.
    // ignore: discarded_futures
    provider.fetchCountries(force: hit);
  }

  Future<void> _navigateUser() async {
    if (!mounted) return;

    bool onboardingDone = false;
    String? token;

    try {
      onboardingDone = LocalStorage.isOnboardingDone();
      token = LocalStorage.getToken();
    } catch (e) {
      debugPrint("SplashScreen: LocalStorage read failed: $e");
      // Be conservative — treat as a brand-new install rather than risk
      // sending an unauthenticated user to MainScreen where they'd see the
      // "Session Expired" dialog from the token poller.
      _go(const OnboardingScreen());
      return;
    }

    if (!mounted) return;

    if (!onboardingDone) {
      _go(const OnboardingScreen());
      return;
    }

    if (token == null || token.isEmpty) {
      _go(const AuthScreen());
      return;
    }

    // We have a token. Probe its validity before deciding where to land.
    try {
      final isValid = await AuthService().verifyToken(token);
      if (!mounted) return;

      if (isValid == true) {
        _go(const MainScreen(showWelcomePopup: false));
      } else if (isValid == false) {
        // Token explicitly rejected — wipe it locally and send the user to
        // sign back in. Don't land them on MainScreen because the token
        // poller there will fire a "Session Expired" dialog immediately.
        await LocalStorage.clearToken();
        _go(const AuthScreen());
      } else {
        // Null = transient network/4xx error during a rolling deploy. Trust
        // the persisted token and let MainScreen retry. If the token is
        // actually dead, MainScreen's 300 s poller will surface it.
        debugPrint(
          "SplashScreen: verifyToken returned null — assuming valid, "
          "letting MainScreen recheck on the periodic poll.",
        );
        _go(const MainScreen(showWelcomePopup: false));
      }
    } catch (e) {
      debugPrint("SplashScreen: navigation error: $e");
      // Any unexpected error in the verify path — fall back to AuthScreen,
      // NOT MainScreen. Sending a possibly-unauthenticated user to
      // MainScreen used to cause an immediate "Session Expired" pop-up.
      _go(const AuthScreen());
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
              height: 175,
              width: 142,
              errorBuilder: (context, error, stack) => const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }
}
