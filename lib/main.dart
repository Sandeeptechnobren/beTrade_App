import 'package:betrade/data/provider/category_provider.dart';
import 'package:betrade/data/provider/explorer_provider.dart';
import 'package:betrade/data/provider/trade_provider.dart';
import 'package:betrade/presentation/screens/splash/splash_screen.dart';
import 'package:betrade/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'data/provider/bottom_nav_provider.dart';
import 'data/provider/country_provider.dart';
import 'data/provider/profile_provider.dart';
import 'data/provider/signUp_provider.dart';
import 'data/provider/theam_provider.dart';
import 'data/services/local_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage.init();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
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
        ChangeNotifierProvider(create: (_) => CountryProvider()),
        ChangeNotifierProvider(create: (_) => SignupProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => TradeProvider()),
        ChangeNotifierProvider(create: (_) => ExploreProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(393, 852),
        minTextAdapt: true,
        splitScreenMode: true,
        // builder: (context, child) {
        //   return MaterialApp(
        //     title: 'BeTrade',
        //     debugShowCheckedModeBanner: false,
        //     theme: ThemeData(
        //       colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        //     ),
        //     home: const SplashScreen(),
        //   );
        // },
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
                ),
                darkTheme: ThemeData(
                  brightness: Brightness.dark,
                  scaffoldBackgroundColor: const Color(0xFF121212),
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
