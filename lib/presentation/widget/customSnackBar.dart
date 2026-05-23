import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomSnackBar {
  static void showError(
      BuildContext context, {
        required String message,
        Duration duration = const Duration(seconds: 3),
      }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: duration,
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: 80.h, // Button se upar
          left: 16.w,
          right: 16.w,
        ),
        padding: EdgeInsets.zero, //  Default padding remove
        content: Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.red.shade200,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: Colors.red.shade300,
            ),
          ),
          child: Text(
            message,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.red.shade800,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  static void showLoader(
      BuildContext context, {
        required String message,
        Duration duration = const Duration(seconds: 3),
      }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: duration,
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: 80.h, //  Button se upar
          left: 16.w,
          right: 16.w,
        ),
        padding: EdgeInsets.zero, //  Default padding remove
        content: Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade200,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: Colors.deepPurple.shade300,
            ),
          ),
          child: Text(
            message,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.deepPurple.shade800,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  static void showSuccess(
      BuildContext context, {
        required String message,
        Duration duration = const Duration(seconds: 3),
      }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: duration,
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: 80.h, //  Button se upar
          left: 16.w,
          right: 16.w,
        ),
        padding: EdgeInsets.zero, //  Default padding remove
        content: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.green.shade200,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: Colors.green.shade300,
            ),
          ),
          child: Text(
            message,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.green.shade800,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}