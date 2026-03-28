import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'auth_bottom_sheet.dart';
class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(image: AssetImage("assets/images/splash.png"), fit: BoxFit.cover,),),
          ),
          Container(
            color: Colors.black.withOpacity(0.3),
          ),
          Align(
            alignment: Alignment.center,
            child: Image.asset("assets/images/IconLogo.png", height: 100.h,),
          ),
          Align(alignment: Alignment.bottomCenter, child: const AuthBottomSheet(),
          ),
        ],
      ),
    );
  }
}