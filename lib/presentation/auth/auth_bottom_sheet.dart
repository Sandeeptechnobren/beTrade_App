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
import 'package:betrade/presentation/screens/signin/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../screens/splash/signup_screen.dart';
import '../widget/purple_button.dart';

class AuthBottomSheet extends StatelessWidget {
  const AuthBottomSheet({super.key});

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
            onPressed: () async {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SignupScreen()),
              );
            },
          ),
          SizedBox(height: 15.h),
          _buildSocialButton(
            context,
            "Continue with",
            "assets/images/google.png",
                () {},
          ),
          SizedBox(height: 10.h),
          _buildSocialButton(
            context,
            "Continue with",
            "assets/images/apple.png",
                () {},
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildGreyButton(BuildContext context, String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.inputFieldBgDynamic(context),
          borderRadius: BorderRadius.circular(25.r),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: AppTextStyle.smallNav.copyWith(
            color: AppColors.textPrimaryDynamic(context),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(
      BuildContext context,
      String text,
      String icon,
      VoidCallback onTap,
      ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.inputFieldBgDynamic(context),
          borderRadius: BorderRadius.circular(25.r),
        ),
        child: Row(
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
    );
  }
}