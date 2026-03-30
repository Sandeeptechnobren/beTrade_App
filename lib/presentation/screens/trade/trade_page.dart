import 'package:betrade/core/theme/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../widget/common_header.dart';

class TradePage extends StatefulWidget {
  const TradePage({super.key, required ScrollController scrollController});

  @override
  State<TradePage> createState() => _TradePageState();
}

class _TradePageState extends State<TradePage> {
  bool isYesSelected = true;
  TextEditingController amountController = TextEditingController();
  double amount = 0;

  void updateAmount(String value) {
    setState(() {
      amount = double.tryParse(value) ?? 0;
    });
  }

  void addQuickAmount(double value) {
    setState(() {
      amount += value;
      amountController.text = amount.toStringAsFixed(0);
    });
  }

  bool get isEnabled => amount > 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
          16.w,
          0,
          16.w,
          MediaQuery.of(context).viewInsets.bottom + 16.h,
        ),
        child: SizedBox(
          height: 55.h,
          child: ElevatedButton(
            onPressed: isEnabled ? () {} : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isEnabled
                  ? (isYesSelected ? const Color(0xff1B5E20) : Colors.red)
                  : Colors.grey.shade400,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.r),
              ),
            ),
            child: Text(
              isYesSelected ? "Buy Yes" : "Buy No",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15.sp,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Row(
                children: [
                  CommonHeader(title: "New Trade"),
                  const Spacer(),
                  Container(
                    height: 36.h,
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: const Color(0xffF1F2F6),
                      borderRadius: BorderRadius.circular(25.r),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => isYesSelected = true),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: isYesSelected
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text("Yes", style: AppTextStyle.body),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => isYesSelected = false),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: !isYesSelected
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text("No", style: AppTextStyle.body),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(thickness: 1),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 16.w,
                    right: 16.w,
                    top: 16.w,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// 🔥 TOP CARD
                      Container(
                        height: 96.h,
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.r),
                          image: const DecorationImage(
                            image: AssetImage("assets/images/splash.png"),
                            fit: BoxFit.cover,
                          ),
                          color: const Color(0xff2D0A4C).withOpacity(0.7),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Market • Crypto",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12.sp,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              "Will bitcoin exceed \$200k before the end of 2026?",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20.h),

                      /// 🔥 AMOUNT INPUT
                      Text("Amount", style: AppTextStyle.body),
                      SizedBox(height: 8.h),
                      TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        onChanged: updateAmount,
                        decoration: InputDecoration(
                          hintText: "0.00",
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 14.h,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      SizedBox(height: 12.h),

                      /// 🔥 QUICK AMOUNT
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [10, 20, 50, 100].map((e) {
                          return GestureDetector(
                            onTap: () => addQuickAmount(e.toDouble()),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 8.h,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text("$e GHS", style: AppTextStyle.body),
                            ),
                          );
                        }).toList(),
                      ),

                      SizedBox(height: 20.h),

                      /// 🔥 SUMMARY CARD
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Column(
                          children: [
                            buildRow("Yes Shares", "20.83"),
                            buildRow("Price per Share", "48 GHS"),
                            buildRow("Max Payout", "80.65 GHS"),
                            buildRow(
                              "Potential Profit",
                              "+30.65 GHS",
                              isProfit: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRow(String title, String value, {bool isProfit = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyle.bodyBig),
          Text(value, style: AppTextStyle.bodyBig),
        ],
      ),
    );
  }
}
