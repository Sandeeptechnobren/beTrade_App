import 'package:betrade/core/theme/app_text_style.dart';
import 'package:betrade/presentation/widget/common_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../widget/purple_button.dart';

class AllPaymentMethodsPage extends StatelessWidget {
  const AllPaymentMethodsPage({
    super.key,
    required ScrollController scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
        child: Button(
          title: "Add New",
          onPressed: () {
            //
            // CommonBottomSheet.open(
            //   context: context,
            //   builder: (controller) =>
            //       AllPaymentMethodsPage(scrollController: controller),
            // );
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            CommonHeader(title: "Payment Methods"),
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.inputFieldBgDynamic(context),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  children: [
                    _item(context, "visa", "VISA", "******856"),
                SizedBox(height: 10.h,),
                    _item(context, "master", "MasterCard", "******856"),
                    SizedBox(height: 10.h,),
                    _item(context, "mtn", "MTN Mobile Money", "******061"),
                    SizedBox(height: 10.h,),
                    _item(context, "bank", "Bank Account", "******234"),
                    SizedBox(height: 10.h,),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _item(BuildContext context, String type, String title, String number) {
    return Row(
      children: [
        _icon(type),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyle.bodyBig),
              SizedBox(height: 2.h),
              Text(
                number,
                style: TextStyle(fontSize: 11.sp, color: Colors.grey),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: () {
            showDeletePopup(context);
          },
          child: Icon(
            LucideIcons.trash2,
            size: 20.sp,
            color: const Color(0xFFDC2626),
          ),
        ),
      ],
    );
  }

  Widget _icon(String type) {
    switch (type) {
      case "visa":
        return _logoBox(
          child: Text(
            "VISA",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              fontSize: 14.sp,
              color: const Color(0xFF1A1F71),
              letterSpacing: 0.5,
            ),
          ),
        );
      case "master":
        return _logoBox(
          child: SizedBox(
            width: 30.w,
            height: 18.h,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  child: Container(
                    width: 18.w,
                    height: 18.h,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEB001B),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  left: 12.w,
                  child: Container(
                    width: 18.w,
                    height: 18.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF79E1B).withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      case "mtn":
        return _logoBox(
          background: const Color(0xFFFFCC00),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Text(
              "MTN\nMobile\nMoney",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 7.sp,
                color: const Color(0xFFD32F2F),
                height: 1.0,
              ),
            ),
          ),
        );
      default:
        return _logoBox(
          background: Colors.black,
          border: false,
          child: Icon(
            LucideIcons.dollarSign,
            size: 22.sp,
            color: Colors.white,
          ),
        );
    }
  }

  Widget _logoBox({
    required Widget child,
    Color? background,
    bool border = true,
  }) {
    return Container(
      height: 44.h,
      width: 64.w,
      decoration: BoxDecoration(
        color: background ?? Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: border
            ? Border.all(color: Colors.grey.shade300, width: 0.8)
            : null,
      ),
      alignment: Alignment.center,
      child: child,
    );
  }

  void showDeletePopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColors.inputFieldBgDynamic(context),
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Delete Payment Method?",
                  style:AppTextStyle.heading
                ),
                SizedBox(height: 10.h),
                Text(
                  "You won’t be able to use this method for deposits or withdrawals unless you add it again.",
                  textAlign: TextAlign.center,
                  style:AppTextStyle.bodyBig
                ),

                SizedBox(height: 20.h),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    decoration: BoxDecoration(
                      color: Color(0xFF991b1b),
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: Center(
                      child: Text(
                        "Delete",
                        style:AppTextStyle.custom(
                          color:Colors.white,
                          size: 16.sp,
                          weight:FontWeight.w700
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    decoration: BoxDecoration(
                      color: AppColors.whiteDynamic(context),
                      border: Border.all(
                        color: Colors.grey,
                        width: 0.5
                      ),
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: Center(
                      child: Text(
                        "Cancel",
                        style:AppTextStyle.bodyBig
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
