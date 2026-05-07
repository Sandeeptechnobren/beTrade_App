// import 'package:betrade/data/provider/category_provider.dart';
// import 'package:betrade/data/provider/default_amount_provider.dart';
// import 'package:betrade/data/provider/explorer_provider.dart';
// import 'package:betrade/data/provider/positions_provider.dart';
// import 'package:betrade/data/provider/trade_detail_provider.dart';
// import 'package:betrade/data/provider/trade_provider.dart';
// import 'package:betrade/data/provider/wallet_provider.dart';
// import 'package:betrade/presentation/screens/splash/signup_screen.dart';
// import 'package:betrade/presentation/screens/splash/splash_screen.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:provider/provider.dart';
// import 'dart:async';
// import 'data/provider/bottom_nav_provider.dart';
// import 'data/provider/country_provider.dart';
// import 'data/provider/profile_provider.dart';
// import 'data/provider/signin_provider.dart';
// import 'data/provider/signup_provider.dart';
// import 'data/provider/theme_provider.dart';
// import 'data/services/local_storage.dart';
// import 'data/services/notification_services.dart';
// import 'firebase_options.dart';

// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   debugPrint("Background message: ${message.messageId}");
// }

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized(); // ✅ FIRST

//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

//   runZonedGuarded(() async {
//     FlutterError.onError = (FlutterErrorDetails details) {
//       FlutterError.presentError(details);
//       debugPrint("Flutter Error: ${details.exception}");
//     };

//     try {
//       await LocalStorage.init();
//       debugPrint("LocalStorage initialized");
//     } catch (e) {
//       debugPrint(" LocalStorage Error: $e");
//     }

//     try {
//       await dotenv.load(fileName: ".env");
//     } catch (e) {
//       debugPrint("ENV Load Error: $e");
//     }

//     await SystemChrome.setPreferredOrientations([
//       DeviceOrientation.portraitUp,
//       DeviceOrientation.portraitDown,
//     ]);

//     runApp(const MyApp());
//   }, (error, stack) {
//     debugPrint(" Async Error: $error");
//   });
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => AuthProvider()),
//         ChangeNotifierProvider(create: (_) => CountryProvider()),
//         ChangeNotifierProvider(create: (_) => BottomNavProvider()),
//         ChangeNotifierProvider(create: (_) => SignupProvider()),
//         ChangeNotifierProvider(create: (_) => ProfileProvider()),
//         ChangeNotifierProvider(create: (_) => CategoryProvider()),
//         ChangeNotifierProvider(create: (_) => TradeProvider()),
//         ChangeNotifierProvider(create: (_) => TradeDetailProvider()),
//         ChangeNotifierProvider(create: (_) => ExploreProvider()),
//         ChangeNotifierProvider(create: (_) => ThemeProvider()),
//         ChangeNotifierProvider(create: (_) => DefaultAmountProvider()),
//         ChangeNotifierProvider(create: (_) => WalletProvider()),
//         ChangeNotifierProvider(create: (_) => PositionsProvider()),
//       ],
//       child: ScreenUtilInit(
//         designSize: const Size(393, 852),
//         minTextAdapt: true,
//         splitScreenMode: true,
//         builder: (context, child) {
//           return Consumer<ThemeProvider>(
//             builder: (context, themeProvider, child) {
//               return MaterialApp(
//                 navigatorKey: navigatorKey,
//                 title: 'BeTrade',
//                 debugShowCheckedModeBanner: false,
//                 themeMode: themeProvider.themeMode,
//                 theme: ThemeData(
//                   brightness: Brightness.light,
//                   scaffoldBackgroundColor: Colors.white,
//                   useMaterial3: true,
//                 ),
//                 darkTheme: ThemeData(
//                   brightness: Brightness.dark,
//                   scaffoldBackgroundColor: const Color(0xFF121212),
//                   useMaterial3: true,
//                 ),
//                 home: const SplashScreen(),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

// Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   debugPrint("Background message: ${message.messageId}");
// }
//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized(); // ✅ FIRST
//
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//
//   FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
//
//   runZonedGuarded(() async {
//     FlutterError.onError = (FlutterErrorDetails details) {
//       FlutterError.presentError(details);
//       debugPrint("Flutter Error: ${details.exception}");
//     };
//
//     try {
//       await LocalStorage.init();
//       debugPrint("LocalStorage initialized");
//     } catch (e) {
//       debugPrint(" LocalStorage Error: $e");
//     }
//
//     try {
//       await dotenv.load(fileName: ".env");
//     } catch (e) {
//       debugPrint("ENV Load Error: $e");
//     }
//
//     await SystemChrome.setPreferredOrientations([
//       DeviceOrientation.portraitUp,
//       DeviceOrientation.portraitDown,
//     ]);
//
//     runApp(const MyApp());
//   }, (error, stack) {
//     debugPrint(" Async Error: $error");
//   });
// }

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import 'firebase_options.dart';
import 'data/services/local_storage.dart';
import 'data/services/notification_services.dart';
import 'data/provider/bottom_nav_provider.dart';
import 'data/provider/category_provider.dart';
import 'data/provider/country_provider.dart';
import 'data/provider/default_amount_provider.dart';
import 'data/provider/explorer_provider.dart';
import 'data/provider/positions_provider.dart';
import 'data/provider/profile_provider.dart';
import 'data/provider/signin_provider.dart';
import 'data/provider/signup_provider.dart';
import 'data/provider/theme_provider.dart';
import 'data/provider/trade_detail_provider.dart';
import 'data/provider/trade_provider.dart';
import 'data/provider/wallet_provider.dart';

// Screens
import 'presentation/screens/splash/splash_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Background handler (keep minimal)
@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  debugPrint("Background message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await runZonedGuarded(() async {
    // ---------------- Firebase Init ----------------
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);

    // ---------------- Local Storage ----------------
    await LocalStorage.init();

    // ---------------- Env ----------------
    await dotenv.load(fileName: ".env");

    // ---------------- Notification Setup ----------------
    await NotificationService.init();

    // iOS foreground notification config (safe for Android too)
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // ---------------- Device Orientation ----------------
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // ---------------- Run App ----------------
    runApp(const MyApp());
  }, (error, stack) {
    debugPrint("Async Error: $error");
  });

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint("Flutter Error: ${details.exception}");
  };
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
        ChangeNotifierProvider(create: (_) => TradeDetailProvider()),
        ChangeNotifierProvider(create: (_) => ExploreProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => DefaultAmountProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => PositionsProvider()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(393, 852),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return MaterialApp(
                navigatorKey: navigatorKey,
                debugShowCheckedModeBanner: false,
                title: 'BeTrade',
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
