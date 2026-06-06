import 'package:betrade/core/theme/app_colors.dart';
import 'package:betrade/core/theme/app_text_style.dart';
import 'package:betrade/presentation/screens/main_screen.dart';
import 'package:betrade/presentation/screens/signin/attach_phone_screen.dart';
import 'package:betrade/presentation/screens/signin/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../core/utils/app_notify.dart';
import '../../data/provider/signin_provider.dart';
import '../screens/splash/signup_screen.dart';

class AuthBottomSheet extends StatefulWidget {
  const AuthBottomSheet({super.key});

  @override
  State<AuthBottomSheet> createState() => _AuthBottomSheetState();
}

class _AuthBottomSheetState extends State<AuthBottomSheet> {
  bool _googleLoading = false;
  bool _appleLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 24.h),
      decoration: BoxDecoration(
        color: AppColors.whiteDynamic(context),
        borderRadius: BorderRadius.vertical(top: Radius.circular(40.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.borderDynamic(context),
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            "Get started quickly",
            style: TextStyle(
              fontFamily: 'SFProRounded',
              fontSize: 24.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimaryDynamic(context),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Choose an option to proceed",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'SFProRounded',
              fontSize: 12.sp,
              color: AppColors.textSecondaryDynamic(context),
            ),
          ),
          SizedBox(height: 24.h),
          _buildGreyButton(context, "Log in to continue", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          }),
          SizedBox(height: 24.h),
          Row(
            children: [
              Expanded(
                child: Divider(color: AppColors.borderDynamic(context)),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Text(
                  "OR",
                  style: TextStyle(
                    color: AppColors.textSecondaryDynamic(context),
                    fontSize: 10.sp,
                  ),
                ),
              ),
              Expanded(
                child: Divider(color: AppColors.borderDynamic(context)),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          _buildPrimaryButton(context, "Create an account", () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SignupScreen(),
                  ),
                );
              }
            });
          }),
          SizedBox(height: 8.h),
          _buildSocialButton(
            context,
            "Continue with",
            "assets/svgs/google.svg",
            loading: _googleLoading,
            onTap: () => _handleGoogleSignIn(context),
          ),
          SizedBox(height: 8.h),
          _buildSocialButton(
            context,
            "Continue with",
            "assets/svgs/apple.svg",
            loading: _appleLoading,
            onTap: () => _handleAppleSignIn(context),
          ),
        ],
      ),
    );
  }

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    if (_googleLoading || _appleLoading) return;
    setState(() => _googleLoading = true);
    final result = await context.read<AuthProvider>().signInWithGoogle();
    if (mounted) setState(() => _googleLoading = false);
    if (!context.mounted) return;
    if (result['cancelled'] == true) return;
    if (result['success'] == true) {
      if (result['needs_phone'] == true) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AttachPhoneScreen(
              email: result['email'] as String?,
            ),
          ),
        );
      } else {
        // pushAndRemoveUntil with (_) => false clears the sheet route too.
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
          (route) => false,
        );
      }
    } else {
      AppNotify.error((result['message'] as String?)?.isNotEmpty == true
          ? result['message']
          : "Sign-in failed. Please try again.");
    }
  }

  Future<void> _handleAppleSignIn(BuildContext context) async {
    if (_googleLoading || _appleLoading) return;
    setState(() => _appleLoading = true);
    final result = await context.read<AuthProvider>().signInWithApple();
    if (mounted) setState(() => _appleLoading = false);
    if (!context.mounted) return;
    if (result['cancelled'] == true) return;
    if (result['success'] == true) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
        (route) => false,
      );
    } else {
      AppNotify.error((result['message'] as String?)?.isNotEmpty == true
          ? result['message']
          : "Apple sign-in failed. Please try again.");
    }
  }

  Widget _buildGreyButton(BuildContext context, String text, VoidCallback onTap) {
    return Material(
      color: AppColors.inputFieldBgDynamic(context),
      borderRadius: BorderRadius.circular(32.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(32.r),
        child: Container(
          width: double.infinity,
          height: 44.h,
          alignment: Alignment.center,
          child: Text(
            text,
            style: AppTextStyle.smallNav.copyWith(
              color: AppColors.textPrimaryDynamic(context),
            ),
          ),
        ),
      ),
    );
  }

  /// Figma primary button (#8E10FC, h44, r32) — used for "Create an account".
  Widget _buildPrimaryButton(
      BuildContext context, String text, VoidCallback onTap) {
    return Material(
      color: const Color(0xFF8E10FC),
      borderRadius: BorderRadius.circular(32.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(32.r),
        child: Container(
          width: double.infinity,
          height: 44.h,
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'SFProRounded',
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFFAFAFA),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(
      BuildContext context,
      String text,
      String icon, {
      required bool loading,
      required VoidCallback onTap,
      }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    // While either social sign-in is running, disable BOTH buttons so the
    // user can't fire a second one; the tapped button shows the spinner.
    final bool anyBusy = _googleLoading || _appleLoading;

    return Material(
      color: AppColors.inputFieldBgDynamic(context),
      borderRadius: BorderRadius.circular(32.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: anyBusy ? null : onTap,
        borderRadius: BorderRadius.circular(32.r),
        child: Container(
          width: double.infinity,
          height: 44.h,
          alignment: Alignment.center,
          child: loading
              ? Center(
                  child: SizedBox(
                    height: 18.h,
                    width: 18.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      text,
                      style: AppTextStyle.smallNav.copyWith(
                        color: AppColors.textPrimaryDynamic(context),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    SvgPicture.asset(
                      icon,
                      height: 18.h,
                      // Apple SVG: dark mein white, light mein black.
                      // Google SVG (colourful) ko untouched chhodo.
                      colorFilter: icon.contains('apple')
                          ? ColorFilter.mode(
                              isDarkMode ? Colors.white : Colors.black,
                              BlendMode.srcIn,
                            )
                          : null,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}