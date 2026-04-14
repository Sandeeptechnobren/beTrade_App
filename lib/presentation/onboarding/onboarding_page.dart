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
                fontWeight: FontWeight.w700,
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
                            filter: ImageFilter.blur(
                              sigmaX: 20,
                              sigmaY: 20,
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 10),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.1),
                                    Colors.black.withOpacity(0.1),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Text(
                                desc,
                                style: AppTextStyle.headingWhitebig,
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
//
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// class OnboardingPage extends StatelessWidget {
//   final String title;
//   final String desc;
//   final String image;
//   final String emoji;
//
//   const OnboardingPage({
//     super.key,
//     required this.title,
//     required this.desc,
//     required this.image,
//     required this.emoji,
//   });
//
//   Widget _safeImage(String path, {double? height, double? width}) {
//     return Image.asset(
//       path,
//       height: height,
//       width: width,
//       fit: BoxFit.contain,
//       errorBuilder: (context, error, stackTrace) {
//         debugPrint("❌ Image missing: $path");
//         return SizedBox(
//           height: height ?? 100,
//           width: width ?? 100,
//           child: const Icon(Icons.image_not_supported, color: Colors.white54),
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 20.w),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: TextStyle(
//                 fontFamily: 'SFProRounded',
//                 fontFamilyFallback: ['System', 'Roboto'], // ✅ ONLY FIX NEEDED
//                 color: Colors.white,
//                 fontSize: 48.sp,
//                 fontWeight: FontWeight.w700,
//                 height: 1.1,
//               ),
//             ),
//             Expanded(
//               child: Stack(
//                 clipBehavior: Clip.none,
//                 children: [
//                   Center(
//                     child: ConstrainedBox(
//                       constraints: BoxConstraints(maxHeight: 500.h),
//                       child: _safeImage(image, height: 500.h),
//                     ),
//                   ),
//                   Positioned(
//                     left: 16.w,
//                     right: 16.w,
//                     bottom: 20.h,
//                     child: Stack(
//                       clipBehavior: Clip.none,
//                       children: [
//                         Container(
//                           padding: EdgeInsets.all(14.w),
//                           decoration: BoxDecoration(
//                             color: Colors.black.withOpacity(0.4),
//                             borderRadius: BorderRadius.circular(16.r),
//                           ),
//                           child: Text(
//                             desc,
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 18.sp,
//                             ),
//                             softWrap: true,
//                           ),
//                         ),
//                         if (emoji.isNotEmpty)
//                           Positioned(
//                             left: -10.w,
//                             top: -60.h,
//                             child: _safeImage(emoji, height: 80.h),
//                           ),
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
