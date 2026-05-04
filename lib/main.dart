import 'package:betrade/data/provider/category_provider.dart';
import 'package:betrade/data/provider/default_amount_provider.dart';
import 'package:betrade/data/provider/explorer_provider.dart';
import 'package:betrade/data/provider/trade_provider.dart';
import 'package:betrade/data/provider/wallet_provider.dart';
import 'package:betrade/presentation/screens/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'data/provider/bottom_nav_provider.dart';
import 'data/provider/country_provider.dart';
import 'data/provider/profile_provider.dart';
import 'data/provider/signIn_provider.dart';
import 'data/provider/signUp_provider.dart';
import 'data/provider/theam_provider.dart';
import 'data/services/local_storage.dart';

Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint("Flutter Error: ${details.exception}");
    };
    try {
      await LocalStorage.init();
      debugPrint("LocalStorage initialized");
    } catch (e) {
      debugPrint(" LocalStorage Error: $e");
    }
    try {
      await dotenv.load(fileName: ".env");
      if (dotenv.env['API_BASE_URL'] == null) {
        debugPrint("API_BASE_URL missing, using default");
      }
    } catch (e) {
      debugPrint("ENV Load Error: $e");
    }
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    runApp(const MyApp());
  }, (error, stack) {
    debugPrint(" Async Error: $error");
    debugPrint(" Stack: $stack");
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CountryProvider()),
        ChangeNotifierProvider(create: (_) => BottomNavProvider()),
        ChangeNotifierProvider(create: (_) => SignupProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => TradeProvider()),
        ChangeNotifierProvider(create: (_) => ExploreProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => DefaultAmountProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(393, 852),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return MaterialApp(
                title: 'BeTrade',
                debugShowCheckedModeBanner: false,
                themeMode: themeProvider.themeMode,
                theme: ThemeData(
                  brightness: Brightness.light,
                  scaffoldBackgroundColor: Colors.white,
                  useMaterial3: true,
                ),
                darkTheme: ThemeData(
                  brightness: Brightness.dark,
                  scaffoldBackgroundColor: const Color(0xFF121212),
                  useMaterial3: true,
                ),
                home: const SplashScreen(),
              );
            },
          );
        },
      ),
    );
  }
}
