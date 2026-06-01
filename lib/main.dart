import 'dart:async';
import 'package:betrade/data/provider/category_provider.dart';
import 'package:betrade/data/provider/default_amount_provider.dart';
import 'package:betrade/data/provider/explorer_provider.dart';
import 'package:betrade/data/provider/positions_provider.dart';
import 'package:betrade/data/provider/trade_detail_provider.dart';
import 'package:betrade/data/provider/trade_provider.dart';
import 'package:betrade/data/provider/wallet_provider.dart';
import 'package:betrade/presentation/screens/splash/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'data/provider/bottom_nav_provider.dart';
import 'data/provider/country_provider.dart';
import 'data/provider/profile_provider.dart';
import 'data/provider/signin_provider.dart';
import 'data/provider/signup_provider.dart';
import 'data/provider/theme_provider.dart';
import 'core/utils/app_logger.dart';
import 'data/services/local_storage.dart';
import 'data/services/notification_services.dart';
import 'firebase_options.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(
    RemoteMessage message,
    ) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint(
    "🔥 BACKGROUND MESSAGE RECEIVED",
  );
  debugPrint(
    "MESSAGE ID: ${message.messageId}",
  );
  debugPrint(
    "TITLE: ${message.notification?.title}",
  );
  debugPrint(
    "BODY: ${message.notification?.body}",
  );
  debugPrint(
    "DATA: ${message.data}",
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await runZonedGuarded(
        () async {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      debugPrint(
        "FIREBASE INITIALIZED SUCCESSFULLY ✅",
      );

      // Crash reporting (CHALLENGES F10). Collection is OFF in debug so local
      // runs don't pollute the dashboard. Flutter framework errors and
      // uncaught async errors (via the zone below) are routed to Crashlytics;
      // AppLogger.e forwards handled service errors too.
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(!kDebugMode);
      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      };
      AppLogger.registerErrorSink((error, stack, {reason, fatal = false}) {
        FirebaseCrashlytics.instance
            .recordError(error, stack, reason: reason, fatal: fatal);
      });

      FirebaseMessaging.onBackgroundMessage(
        _firebaseBackgroundHandler,
      );

      debugPrint(
        "BACKGROUND HANDLER REGISTERED ✅",
      );
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      debugPrint(
        "FOREGROUND PRESENTATION OPTIONS SET ✅",
      );
      try {
        await LocalStorage.init();
        debugPrint(
          "LOCAL STORAGE INITIALIZED ✅",
        );
      } catch (e) {
        debugPrint(
          "LOCAL STORAGE ERROR: $e",
        );
      }
      try {
        await dotenv.load(
          fileName: ".env",
        );
        debugPrint(
          ".env LOADED SUCCESSFULLY ✅",
        );
      } catch (e) {
        debugPrint(
          "ENV LOAD ERROR: $e",
        );
      }
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      debugPrint(
        "PORTRAIT MODE LOCKED ✅",
      );
      runApp(
        const MyApp(),
      );


      Future.microtask(() {
        NotificationService.init();
      });

      debugPrint(
        "NOTIFICATION SERVICE STARTED ✅",
      );
    },
        (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      if (kDebugMode) {
        debugPrint("GLOBAL ASYNC ERROR: $error");
        debugPrint("STACK TRACE: $stack");
      }
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CountryProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => BottomNavProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SignupProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CategoryProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => TradeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => TradeDetailProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ExploreProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => DefaultAmountProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => WalletProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => PositionsProvider(),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(393, 852),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return Consumer<ThemeProvider>(
            builder: (
                context,
                themeProvider,
                child,
                ) {
              return MaterialApp(
                navigatorKey: navigatorKey,
                title: "BeTrade",
                debugShowCheckedModeBanner: false,
                themeMode: themeProvider.themeMode,
                theme: ThemeData(
                  brightness: Brightness.light,
                  scaffoldBackgroundColor: Colors.white,
                  useMaterial3: true,
                ),
                darkTheme: ThemeData(
                  brightness: Brightness.dark,
                  scaffoldBackgroundColor: const Color(
                    0xFF121212,
                  ),
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
