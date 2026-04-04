import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_style.dart';

class CommonHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final bool showDivider;

  const CommonHeader({
    super.key,
    required this.title,
    this.onBack,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12.h,
        left: 16.w,
        right: 16.w,
        bottom: 12.h,
      ),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(bottom: BorderSide(color: Colors.grey.shade300, width: 1))
            : null,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack ?? () => Navigator.pop(context),
            child: Container(
              height: 36.w,
              width: 36.w,
              decoration: BoxDecoration(
                color: AppColors.iconBgDynamic(context),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_back_ios_new, size: 16.sp),
            ),
          ),
          SizedBox(width: 10.w),
          Text(title, style: AppTextStyle.heading),
        ],
      ),
    );
  }
}
