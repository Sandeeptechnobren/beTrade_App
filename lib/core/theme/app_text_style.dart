// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// class AppTextStyle {
//   static const String fontFamily = 'SFProRounded';
//   static TextStyle heading = TextStyle(
//     fontSize: 20.sp,
//     fontWeight: FontWeight.w700,
//     fontFamily: fontFamily,
//   );
//   static TextStyle headingWhite = TextStyle(
//     fontSize: 20.sp,
//     fontWeight: FontWeight.w700,
//     fontFamily: fontFamily,
//     color: Colors.white
//   );
//   static TextStyle subHeading = TextStyle(
//     fontSize: 18.sp,
//     fontWeight: FontWeight.w500,
//     fontFamily: fontFamily,
//   );
//   static TextStyle subHeadingBold = TextStyle(
//     fontSize: 18.sp,
//     fontWeight: FontWeight.w900,
//     fontFamily: fontFamily,
//   );
//   static TextStyle body = TextStyle(
//     fontSize: 16.sp,
//     fontWeight: FontWeight.w600,
//     fontFamily: fontFamily,
//   );
//   static TextStyle bodyBig = TextStyle(
//     fontSize: 16.sp,
//     fontWeight: FontWeight.w400,
//     fontFamily: fontFamily,
//     color: Colors.grey
//   );
//   static TextStyle small = TextStyle(
//     fontSize: 14.sp,
//     fontWeight: FontWeight.w400,
//     fontFamily: fontFamily,
//   );
//   static TextStyle smallGrey = TextStyle(
//     fontSize: 14.sp,
//     fontWeight: FontWeight.w400,
//     fontFamily: fontFamily,
//     color:Colors.grey
//   );
//   static TextStyle smallNav = TextStyle(
//     fontSize: 14.sp,
//     fontWeight: FontWeight.bold,
//     fontFamily: fontFamily,
//   );
//   static TextStyle button = TextStyle(
//     fontSize: 16.sp,
//     fontWeight: FontWeight.w600,
//     fontFamily: fontFamily,
//   );
//   static TextStyle custom({
//     double? size,
//     FontWeight? weight,
//     Color? color,
//   }) {
//     return TextStyle(
//       fontSize: size?.sp,
//       fontWeight: weight,
//       color: color,
//       fontFamily: fontFamily,
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';

class AppTextStyle {
  static const String fontFamily = 'SFProRounded';

  // ❌ OLD (safe — no change)
  static TextStyle heading = TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.w700,
    fontFamily: fontFamily,
  );

  static TextStyle headingWhite = TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.w700,
    fontFamily: fontFamily,
    color: Colors.white,
  );

  static TextStyle subHeading = TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.w500,
    fontFamily: fontFamily,
  );

  static TextStyle subHeadingBold = TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.w900,
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
    color: Colors.grey,
  );

  static TextStyle small = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    fontFamily: fontFamily,
  );

  static TextStyle smallGrey = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    fontFamily: fontFamily,
    color: Colors.grey,
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

  // ✅ NEW (dark mode friendly)

  static TextStyle headingDynamic(BuildContext context) =>
      heading.copyWith(
        color: AppColors.textPrimaryDynamic(context),
      );

  static TextStyle bodyDynamic(BuildContext context) =>
      body.copyWith(
        color: AppColors.textPrimaryDynamic(context),
      );

  static TextStyle bodyBigDynamic(BuildContext context) =>
      bodyBig.copyWith(
        color: AppColors.textSecondaryDynamic(context),
      );

  static TextStyle smallDynamic(BuildContext context) =>
      small.copyWith(
        color: AppColors.textSecondaryDynamic(context),
      );
}