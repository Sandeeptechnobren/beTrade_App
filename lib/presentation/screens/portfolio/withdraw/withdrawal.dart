import 'package:betrade/core/theme/app_text_style.dart';
import 'package:betrade/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../widget/deposit_success.dart';

class WithdrawPage extends StatefulWidget {
  final ScrollController scrollController;

  const WithdrawPage({super.key, required this.scrollController});

  @override
  State<WithdrawPage> createState() => _DepositPageState();
}

class _DepositPageState extends State<WithdrawPage> {
  int step = 1;

  final TextEditingController amountController = TextEditingController();

  int selectedAmount = 10;

  String paymentMethod = "card";

  final TextEditingController cardNumber = TextEditingController();
  final TextEditingController expiry = TextEditingController();
  final TextEditingController cvc = TextEditingController();

  final TextEditingController phone = TextEditingController();
  String provider = "";

  final List<int> amounts = [10, 20, 50, 100];

  @override
  void initState() {
    amountController.text = "10";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            margin: EdgeInsets.all(12.w),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30.r),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          child: Container(
                            height: 36.w,
                            width: 36.w,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.arrow_back_ios_new, size: 16.sp),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Text("New Withdrawal", style: AppTextStyle.heading),
                      ],
                    ),
                    _stepIndicator(),
                  ],
                ),
                SizedBox(height: 20.h),
                Expanded(child: step == 1 ? step1() : step2()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= STEP INDICATOR =================
  Widget _stepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 32.w,
              width: 32.w,
              child: CircularProgressIndicator(
                value: step / 2,
                strokeWidth: 3,
                backgroundColor: Colors.grey.shade300,
                valueColor: const AlwaysStoppedAnimation(Color(0xFF7B2FF7)),
              ),
            ),
            Text("$step", style: TextStyle(fontSize: 12.sp)),
          ],
        ),
      ],
    );
  }

  // ================= STEP 1 =================
  Widget step1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Amount", style: AppTextStyle.body),

        SizedBox(height: 10.h),

        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: AppColors.iconContainer,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(border: InputBorder.none),
          ),
        ),

        SizedBox(height: 15.h),
        const Spacer(),
        _button("Continue", () {
          setState(() => step = 2);
        }),
      ],
    );
  }

  // ================= STEP 2 =================
  Widget step2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Payment Method", style: AppTextStyle.body),

        SizedBox(height: 10.h),

        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: AppColors.iconContainer,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: DropdownButton<String>(
            value: paymentMethod,
            isExpanded: true,
            underline: const SizedBox(),
            items: [
              DropdownMenuItem(
                value: "card",
                child: Text("Bank Account", style: AppTextStyle.body),
              ),
              DropdownMenuItem(
                value: "momo",
                child: Text("Mobile Money", style: AppTextStyle.body),
              ),
            ],
            onChanged: (val) {
              setState(() {
                paymentMethod = val!;
              });
            },
          ),
        ),

        SizedBox(height: 20.h),

        paymentMethod == "card" ? cardUI() : momoUI(),

        const Spacer(),
        _button("Confirm", () async {
          Navigator.pop(context);

          await Future.delayed(const Duration(milliseconds: 200));

          showSuccessDialog(context);
        }),
      ],
    );
  }

  // ================= CARD
  Widget cardUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Account Number", style: AppTextStyle.body),

        SizedBox(height: 10.h),
        _input(cardNumber, "0000 0000 0000 0000"),

        SizedBox(height: 20.h),

        Text("Account Name", style: AppTextStyle.body),

        SizedBox(height: 10.h),
        _input(cardNumber, "Enter account name"),

        SizedBox(height: 20.h),
        Text("Bank Name", style: AppTextStyle.body),

        SizedBox(height: 10.h),
        _input(cardNumber, "Select an option "),
      ],
    );
  }

  // ================= MOMO =================
  Widget momoUI() {
    return Column(
      children: [
        _dropdown("Select Provider", (val) {
          provider = val!;
        }),

        SizedBox(height: 10.h),

        _input(phone, "Phone Number"),
      ],
    );
  }

  // ================= COMMON INPUT
  Widget _input(TextEditingController controller, String hint) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: AppColors.iconContainer,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(hintText: hint, border: InputBorder.none),
      ),
    );
  }

  Widget _dropdown(String hint, Function(String?) onChanged) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: DropdownButton<String>(
        hint: Text(hint),
        isExpanded: true,
        underline: const SizedBox(),
        items: const [
          DropdownMenuItem(value: "mtn", child: Text("MTN Mobile Money")),
          DropdownMenuItem(value: "vodafone", child: Text("Vodafone Cash")),
        ],
        onChanged: onChanged,
      ),
    );
  }

  // ================= BUTTON =================
  Widget _button(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.r),
          gradient: const LinearGradient(
            colors: [Color(0xff7b2ff7), Color(0xff9d4edd)],
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
