import 'package:betrade/core/theme/app_colors.dart';
import 'package:betrade/core/theme/app_text_style.dart';
import 'package:betrade/presentation/widget/common_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
        padding: const EdgeInsets.all(16.0),
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
            CommonHeader(title: "Payments Methods"),
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  children: [
                    _item(context, "visa", "VISA", "******856"),
                    _divider(),
                    _item(context, "master", "MasterCard", "******856"),
                    _divider(),
                    _item(context, "mtn", "MTN Mobile Money", "******061"),
                    _divider(),
                    _item(context, "bank", "Bank Account", "******234"),
                    _divider(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Divider(color: Colors.grey.shade300, thickness: 1),
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
          child: Image.asset("assets/logo/tras.png", height: 20.h),
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
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
              color: Colors.blue,
            ),
          ),
        );
      case "master":
        return _logoBox(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(radius: 7.r, backgroundColor: Colors.red),
              CircleAvatar(radius: 7.r, backgroundColor: Colors.orange),
            ],
          ),
        );
      case "mtn":
        return _logoBox(
          child: Text(
            "MTN",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
              color: Colors.blue,
            ),
          ),
        );
      default:
        return _logoBox(child: Icon(Icons.lock, size: 20.sp));
    }
  }

  Widget _logoBox({required Widget child}) {
    return Container(
      height: 44.h,
      width: 64.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.grey, width: 0.5),
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
              color: Colors.white,
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
                      color: Colors.red,
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
                      color: Colors.grey.shade200,
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
