import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_text_style.dart';
import '../widget/purple_button.dart';

void showSuccessDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 25.h,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Deposit Successful",
                style: AppTextStyle.heading.copyWith(fontSize: 20.sp),
              ),
              SizedBox(height: 12.h),
              Text(
                "Your deposit has been completed successfully. You can save this payment method for faster transactions next time.",
                textAlign: TextAlign.center,
                style: AppTextStyle.bodyBig.copyWith(fontSize: 14.sp),
              ),
              SizedBox(height: 25.h),
              Button(
                title: "Save Payment Method",
                onPressed: () {},
              ),
              SizedBox(height: 15.h),
              Button(
                title: "Done",
                onPressed: () {
                  Navigator.pop(context);
                },
                isPrimary: false,
              ),
            ],
          ),
        ),
      );
    },
  );
}
void withdrawalSuccessDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 25.h,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Withdrawal Successful",
                style: AppTextStyle.heading.copyWith(fontSize: 20.sp),
              ),
              SizedBox(height: 12.h),
              Text(
                "Your withdrawal was completed successfully. Please allow a few moments for the funds to appear in your account.",
                textAlign: TextAlign.center,
                style: AppTextStyle.bodyBig.copyWith(fontSize: 14.sp),
              ),
              SizedBox(height: 25.h),
              Button(
                title: "Okay",
                onPressed: () {
                  Navigator.pop(context);
                },
                isPrimary: true,
              ),
            ],
          ),
        ),
      );
    },
  );
}