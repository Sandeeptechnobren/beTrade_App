import 'package:betrade/core/theme/app_text_style.dart';
import 'package:betrade/presentation/screens/profile/new_Payment_method.dart';
import 'package:betrade/presentation/widget/common_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';
import '../../widget/common_header.dart';
import '../../widget/purple_button.dart';

class PaymentMethodsPage extends StatelessWidget {
  const PaymentMethodsPage({super.key, required ScrollController scrollController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CommonHeader(title: "Payment Methods"),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.r),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 10.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Row(
                        children: [
                          SizedBox(width: 36.w),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 70.w,
                            width: 70.w,
                            decoration: BoxDecoration(
                              color: AppColors.inputFieldBgDynamic(context),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              color: Colors.grey,
                              size: 30.sp,
                            ),
                          ),
                          SizedBox(height:10.h),
                          Text(
                            "No Payment Methods",
                           style: AppTextStyle.body,
                          ),
                          SizedBox(height: 8.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 40.w),
                            child: Text(
                              "Add a payment method to deposit or withdraw funds.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                      child: Button(title: "Add New", onPressed:(){

                          CommonBottomSheet.open(
                            context: context,
                            builder: (controller) =>
                                NewPaymentMethodPage(scrollController: controller),
                          );

                      }),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}