import 'package:betrade/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AuthLayout extends StatelessWidget {
  final int step;
  final Widget child;
  final VoidCallback onContinue;
  final VoidCallback? onBack;
  final bool isLoading;
  final bool isCurrentStepValid;
  // Optional row rendered directly under the Continue button (e.g. the
  // Google/Apple social-auth buttons on step 1). Null on steps that
  // don't need it.
  final Widget? bottomExtra;

  const AuthLayout({
    super.key,
    required this.step,
    required this.child,
    required this.onContinue,
    this.onBack,
    this.isLoading = false,
    required this.isCurrentStepValid,
    this.bottomExtra,
  });

  double _getProgressValue() {
    if (step <= 0) return 0.0;
    if (step >= 5) return 1.0;
    return step / 5;
  }

  void _handleBack() {
    if (isLoading) return;
    if (onBack != null) {
      onBack!();
    }
  }
  void _handleContinue() {
    if (isLoading) return;
    if (!isCurrentStepValid) return;
    onContinue();
  }

  Widget _buildBottomBar(BuildContext context) {
    double bottomPadding = 15.h;

    try {
      final viewInsets = MediaQuery.of(context).viewInsets.bottom;
      if (viewInsets > 0) {
        bottomPadding = viewInsets + 10.h;
      }
    } catch (e) {
      debugPrint("❌ MediaQuery error: $e");
      bottomPadding = 15.h;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 10.h,
        bottom: bottomPadding,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 55.h,
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    (isLoading || !isCurrentStepValid) ? null : _handleContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                ),
                child: isLoading
                    ? SizedBox(
                        height: 24.h,
                        width: 24.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        step == 5 ? "Submit" : "Continue",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            if (bottomExtra != null) ...[
              SizedBox(height: 12.h),
              bottomExtra!,
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.cardBackgroundDynamic(context),
      bottomNavigationBar: _buildBottomBar(context),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            SizedBox(height: 50.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: (onBack != null && !isLoading) ? _handleBack : null,
                  child: Container(
                    height: 36.w,
                    width: 36.w,
                    decoration: BoxDecoration(
                      color: AppColors.iconBgDynamic(context),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      size: 18.sp,
                      color: AppColors.textPrimaryDynamic(context),
                    ),
                  ),
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 32.w,
                      width: 32.w,
                      child: CircularProgressIndicator(
                        value: _getProgressValue(),
                        strokeWidth: 3,
                        backgroundColor: AppColors.grey200Dynamic(context),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                    Text(
                      "$step",
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryDynamic(context),
                      ),
                    ),
                  ],
                ),
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