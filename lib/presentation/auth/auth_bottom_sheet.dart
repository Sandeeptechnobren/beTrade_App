// import 'package:betrade/core/theme/app_colors.dart';
// import 'package:betrade/core/theme/app_text_style.dart';
// import 'package:betrade/presentation/screens/signin/login_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../screens/splash/signup_screen.dart';
// import '../widget/purple_button.dart';
//
// class AuthBottomSheet extends StatelessWidget {
//   const AuthBottomSheet({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
//       decoration: BoxDecoration(
//         color:Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 40.w,
//             height: 4.h,
//             decoration: BoxDecoration(
//               color: Colors.grey.shade300,
//               borderRadius: BorderRadius.circular(10.r),
//             ),
//           ),
//           SizedBox(height: 30.h),
//           Text("Get started quickly", style: AppTextStyle.heading),
//           SizedBox(height: 5.h),
//           Text(
//             "Choose an option to proceed",
//             style: TextStyle(fontSize: 10, color: Colors.grey),
//           ),
//           SizedBox(height: 20.h),
//           _buildGreyButton("Log in to continue", () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => LoginScreen()),
//             );
//           }),
//           SizedBox(height: 15.h),
//           Row(
//             children: [
//               Expanded(child: Divider(color: Colors.grey.shade300)),
//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 10.w),
//                 child: Text(
//                   "OR",
//                   style: TextStyle(color: Colors.grey, fontSize: 10),
//                 ),
//               ),
//               Expanded(child: Divider(color: Colors.grey.shade300)),
//             ],
//           ),
//           SizedBox(height: 15.h),
//           Button(
//             title: "Create an Account",
//             isPrimary: true,
//             onPressed: () async {
//               Navigator.pop(context);
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => const SignupScreen()),
//               );
//             },
//           ),
//           SizedBox(height: 15.h),
//           _buildSocialButton(
//             "Continue with",
//             "assets/images/google.png",
//             () {},
//           ),
//           SizedBox(height: 10.h),
//           _buildSocialButton("Continue with", "assets/images/apple.png", () {}),
//           SizedBox(height: 10.h),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildGreyButton(String text, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: double.infinity,
//         padding: EdgeInsets.symmetric(vertical: 14.h),
//         decoration: BoxDecoration(
//           color: AppColors.inputFieldBg,
//           borderRadius: BorderRadius.circular(25.r),
//         ),
//         alignment: Alignment.center,
//         child: Text(text, style: AppTextStyle.smallNav),
//       ),
//     );
//   }
//
//   Widget _buildSocialButton(String text, String icon, VoidCallback onTap) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.symmetric(vertical: 12.h),
//       decoration: BoxDecoration(
//         color: AppColors.inputFieldBg,
//         borderRadius: BorderRadius.circular(25.r),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(text, style: AppTextStyle.smallNav),
//           SizedBox(width: 10.w),
//           Image.asset(icon, height: 18.h),
//         ],
//       ),
//     );
//   }
// }

import 'package:betrade/core/theme/app_colors.dart';
import 'package:betrade/core/theme/app_text_style.dart';
import 'package:betrade/presentation/screens/main_screen.dart';
import 'package:betrade/presentation/screens/signin/attach_phone_screen.dart';
import 'package:betrade/presentation/screens/signin/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../core/utils/app_notify.dart';
import '../../data/provider/signin_provider.dart';
import '../screens/splash/signup_screen.dart';
import '../widget/purple_button.dart';

class AuthBottomSheet extends StatefulWidget {
  const AuthBottomSheet({super.key});

  @override
  State<AuthBottomSheet> createState() => _AuthBottomSheetState();
}

class _AuthBottomSheetState extends State<AuthBottomSheet> {
  // Per-button loading flags so the tapped social button shows a spinner
  // (clear "tap registered + working" feedback) while its sign-in runs.
  bool _googleLoading = false;
  bool _appleLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: AppColors.whiteDynamic(context),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
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
          SizedBox(height: 30.h),
          Text(
            "Get started quickly",
            style: AppTextStyle.heading.copyWith(
              color: AppColors.textPrimaryDynamic(context),
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            "Choose an option to proceed",
            style: TextStyle(
              fontSize: 10.sp,
              color: AppColors.textSecondaryDynamic(context),
            ),
          ),
          SizedBox(height: 20.h),
          _buildGreyButton(context, "Log in to continue", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          }),
          SizedBox(height: 15.h),
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
          SizedBox(height: 15.h),
          Button(
            title: "Create an account",
            isPrimary: true,
            // onPressed: () async {
            //   Navigator.pop(context);
            //   // Navigator.push(
            //   //   context,
            //   //   MaterialPageRoute(builder: (_) => const SignupScreen()),
            //   // );
            //   Navigator.pushReplacement(
            //     context,
            //     MaterialPageRoute(
            //       builder: (_) => const SignupScreen(),
            //     ),
            //   );
            // },
              onPressed: () async {
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
              }
          ),
          SizedBox(height: 15.h),
          _buildSocialButton(
            context,
            "Continue with",
            "assets/images/google.png",
            loading: _googleLoading,
            onTap: () => _handleGoogleSignIn(context),
          ),
          SizedBox(height: 10.h),
          _buildSocialButton(
            context,
            "Continue with",
            "assets/images/apple.png",
            loading: _appleLoading,
            onTap: () => _handleAppleSignIn(context),
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  /// Continue-with-Google from the entry auth sheet. Shows a spinner on the
  /// Google button while signing in; on success routes to AttachPhoneScreen
  /// (new user) or MainScreen, else shows a toast. A cancelled chooser stays
  /// silent.
  Future<void> _handleGoogleSignIn(BuildContext context) async {
    if (_googleLoading || _appleLoading) return;
    setState(() => _googleLoading = true);
    final result = await context.read<AuthProvider>().signInWithGoogle();
    if (mounted) setState(() => _googleLoading = false);
    if (!context.mounted) return;
    if (result['cancelled'] == true) return;
    if (result['success'] == true) {
      if (result['needs_phone'] == true) {
        // Dismiss the bottom sheet first, then push the attach-phone screen.
        Navigator.pop(context);
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

  /// Continue-with-Apple from the entry auth sheet. Mirrors the login/signup
  /// screens: a successful Apple sign-in is a full backend login, so we land
  /// on MainScreen. A cancelled sheet stays silent; errors show a toast.
  /// (Stateless sheet, so [AuthProvider.signInWithApple] guards re-entry.)
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
      borderRadius: BorderRadius.circular(25.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(25.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 14.h),
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
      borderRadius: BorderRadius.circular(25.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: anyBusy ? null : onTap,
        borderRadius: BorderRadius.circular(25.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 12.h),
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
                    Image.asset(
                      icon,
                      height: 18.h,
                      // Apple icon ke liye dark mode mein white chahiye
                      color: isDarkMode && icon.contains('apple')
                          ? Colors.white
                          : null,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}