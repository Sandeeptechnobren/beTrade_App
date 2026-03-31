import 'package:betrade/core/theme/app_colors.dart';
import 'package:betrade/core/theme/app_text_style.dart';
import 'package:betrade/presentation/widget/common_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
class WalletHistoryPage extends StatefulWidget {
  const WalletHistoryPage({super.key});
  @override
  State<WalletHistoryPage> createState() => _WalletHistoryPageState();
}
class _WalletHistoryPageState extends State<WalletHistoryPage> {
  String selectedType = "Deposits";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
               CommonHeader(title: "Wallet History"),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      setState(() {
                        selectedType = value;
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    color: Colors.white,
                    elevation: 8,
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: "Deposits",
                        padding: EdgeInsets.zero,
                        child: _menuItem("Deposits"),
                      ),
                      PopupMenuItem(
                        value: "Withdrawals",
                        padding: EdgeInsets.zero,
                        child: _menuItem("Withdrawals"),
                      ),
                    ],
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25.r),
                        border: Border.all(color: AppColors.inputFieldBg),
                      ),
                      child: Row(
                        children: [
                          Text(selectedType, style: AppTextStyle.body),
                          SizedBox(width: 4.w),
                          Icon(Icons.keyboard_arrow_down, size: 20.sp),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                children: [
                  SizedBox(height: 10.h),
                  Text("Today", style: AppTextStyle.body),
                  SizedBox(height: 10.h),
                  _item(
                    "Mobile Money",
                    "0543762061 • MTN",
                    selectedType == "Deposits" ? "+10 GHS" : "-50 GHS",
                    selectedType == "Deposits",
                  ),
                  SizedBox(height: 16.h),
                  Text("Dec 10, 2024", style: AppTextStyle.body),
                  SizedBox(height: 10.h),
                  _item(
                    "Debit/Credit Card",
                    "•••• 4567",
                    selectedType == "Deposits" ? "+25 GHS" : "-100 GHS",
                    selectedType == "Deposits",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _menuItem(String text) {
    final isSelected = selectedType == text;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFE9DDF5) : Colors.transparent,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(text, style: AppTextStyle.body),
    );
  }
  Widget _item(String title, String subtitle, String amount, bool isDeposit) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          Container(
            height: 40.h,
            width: 40.w,
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: isDeposit
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
              color: isDeposit ? Colors.green : Colors.red,
              size: 18.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyle.body),
                Text(subtitle, style: AppTextStyle.small),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: isDeposit ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
            ),
          ),
        ],
      ),
    );
  }
}
