import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';

class AppTextStyle {
  static const String fontFamily = 'SFProRounded';

  // Production typography pass (QA #2). Reference scale aligned with
  // Material 3 titleLarge (22sp) and the heading sizes used by Cred /
  // PhonePe / Zomato. Body (16sp), small (14sp), subHeading (18sp) and
  // button (16sp) are already at the production sweet spot and were
  // left unchanged to avoid layout shifts. smallNav stays at 14sp
  // because it doubles as the form-label style on the KYC screen, not
  // just the bottom nav.
  static TextStyle heading = TextStyle(
    fontSize: 22.sp,
    fontWeight: FontWeight.w700,
    fontFamily: fontFamily,
  );

  static TextStyle headingWhite = TextStyle(
    fontSize: 22.sp,
    fontWeight: FontWeight.w700,
    fontFamily: fontFamily,
    color: Colors.white,
  );

  static TextStyle headingWhitebig = TextStyle(
    fontSize: 26.sp,
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