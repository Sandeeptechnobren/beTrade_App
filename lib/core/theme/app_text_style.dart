import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTextStyle {
  static const String fontFamily = 'SFProRounded';
  static TextStyle heading = TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.w600,
    fontFamily: fontFamily,
  );
  static TextStyle subHeading = TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.w500,
    fontFamily: fontFamily,
  );
  static TextStyle body = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    fontFamily: fontFamily,
  );
  static TextStyle bodyBig = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
    fontFamily: fontFamily,
    color: Colors.grey
  );
  static TextStyle small = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    fontFamily: fontFamily,
  );
  static TextStyle smallNav = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.bold,
    fontFamily: fontFamily,
  );
  static TextStyle button = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    fontFamily: fontFamily,
  );
  static TextStyle custom({
    double? size,
    FontWeight? weight,
    Color? color,
  }) {
    return TextStyle(
      fontSize: size?.sp,
      fontWeight: weight,
      color: color,
      fontFamily: fontFamily,
    );
  }
}