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
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
              style: TextStyle(fontFamily: 'SFProRounded', color: Colors.white, fontSize: 58.sp, fontWeight: FontWeight.w700, height: 0.9,),),
            Expanded(
              child: Stack(
                children: [
                  Center(child: Image.asset(image, height: 657.h,fit: BoxFit.contain,),),
                  Positioned(left: 16.w, right: 16.w, bottom: 20.h,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [Container(
                        padding: EdgeInsets.all(14.w),
                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), borderRadius: BorderRadius.circular(16.r),),
                          child: Text(desc, style: TextStyle(color: Colors.white, fontSize: 20.sp,),),
                        ),
                        Positioned(
                          left:-10.w,
                          top: -110.h,
                          child: Image.asset(
                           emoji,
                            height:100.h,
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