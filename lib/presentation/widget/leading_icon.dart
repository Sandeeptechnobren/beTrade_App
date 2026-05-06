
import 'package:betrade/core/theme/app_colors.dart';
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
        height: 30.h,
        width: 30.w,
        decoration: BoxDecoration(
          color: AppColors.iconBgDynamic(context),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.arrow_back_ios_new,
          size: 18.sp,
          color: AppColors.textPrimaryDynamic(context), // Dynamic icon color
        ),
      ),
    );
  }
}