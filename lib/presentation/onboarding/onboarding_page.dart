// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// class OnboardingPage extends StatelessWidget {
//   final String title;
//   final String desc;
//   final String image;
//   final String emoji;
//   const OnboardingPage({
//     super.key,
//     required this.title,
//     required this.desc,
//     required this.image,
//     required this.emoji,
//   });
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 20.w),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(title,
//               style: TextStyle(fontFamily: 'SFProRounded', color: Colors.white, fontSize: 58.sp, fontWeight: FontWeight.w700, height: 0.9,),),
//             Expanded(
//               child: Stack(
//                 children: [
//                   Center(child: Image.asset(image, height: 657.h,fit: BoxFit.contain,),),
//                   Positioned(left: 16.w, right: 16.w, bottom: 20.h,
//                     child: Stack(
//                       clipBehavior: Clip.none,
//                       children: [Container(
//                         padding: EdgeInsets.all(14.w),
//                           decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), borderRadius: BorderRadius.circular(16.r),),
//                           child: Text(desc, style: TextStyle(color: Colors.white, fontSize: 20.sp,),),
//                         ),
//                         Positioned(
//                           left:-10.w,
//                           top: -110.h,
//                           child: Image.asset(
//                            emoji,
//                             height:100.h,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:ui';

import 'package:betrade/core/theme/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OnboardingPage extends StatelessWidget {
  final String title;
  final String desc;
  final String image;
  final String emoji;

  const OnboardingPage({
    super.key,
    required this.title,
    required this.desc,
    required this.image,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'SFProRounded',
                color: Colors.white,
                fontSize: 58.sp,
                // Figma: weight 600.
                fontWeight: FontWeight.w600,
                height: 0.9,
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  Center(
                    child: Image.asset(
                      image,
                      height: 657.h,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0.w,
                    bottom: 5.h,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            // Figma: backdrop blur 15px.
                            filter: ImageFilter.blur(
                              sigmaX: 15,
                              sigmaY: 15,
                            ),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.w, vertical: 14.h),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                // Figma: rgba(0,0,0,0.2) tint over the blur.
                                color: Colors.black.withOpacity(0.2),
                              ),
                              child: Text(
                                desc,
                                // Figma: SF Pro Rounded 22, weight 600.
                                style: AppTextStyle.headingWhitebig.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: -10.w,
                          top: -105.h,
                          child: Image.asset(
                            emoji,
                            height: 100.h,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

