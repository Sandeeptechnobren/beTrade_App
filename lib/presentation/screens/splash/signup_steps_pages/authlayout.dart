import 'package:betrade/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AuthLayout extends StatelessWidget {
  final int step;
  final Widget child;
  final VoidCallback onContinue;
  final VoidCallback? onBack;

  const AuthLayout({
    super.key,
    required this.step,
    required this.child,
    required this.onContinue,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 50),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(
          left: 20.w,
          right: 20.w,
          top: 10.h,
          bottom: MediaQuery.of(context).viewInsets.bottom > 0
              ? MediaQuery.of(context).viewInsets.bottom + 10.h
              : 15.h,
        ),
        child: SafeArea(
          child: SizedBox(
            height: 55.h,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8e10fc),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
              child: Text(
                "Continue",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            SizedBox(height: 50.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: onBack,
                  child: Container(
                    height:36.w,
                    width: 36.w,
                    decoration: BoxDecoration(
                      color: AppColors.inputFieldBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.arrow_back_ios_new, size: 18.sp),
                  ),
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 32.w,
                      width: 32.w,
                      child: CircularProgressIndicator(
                        value: step / 5,
                        strokeWidth: 3,
                        backgroundColor: Colors.grey.shade300,
                        valueColor:
                        const AlwaysStoppedAnimation(Color(0xFF7B2FF7)),
                      ),
                    ),
                    Text("$step", style: TextStyle(fontSize: 12.sp)),
                  ],
                )
              ],
            ),

            SizedBox(height: 40.h),

            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}