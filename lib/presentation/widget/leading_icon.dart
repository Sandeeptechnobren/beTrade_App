import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LeadingIcon extends StatelessWidget {
  const LeadingIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(50.r),
      onTap: () => Navigator.pop(context),
      child: Container(
        height: 40.h,
        width: 40.w,
        decoration: const BoxDecoration(
          color: Color(0xFFF4F4F5),
          shape: BoxShape.circle, // ✅ perfect circle
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.arrow_back_ios_new,
          size: 18.sp,
          color: Colors.black,
        ),
      ),
    );
  }
}
