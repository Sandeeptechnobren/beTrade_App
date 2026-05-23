import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../data/provider/wallet_provider.dart';
import '../../../widget/common_header.dart';
import '../../../widget/deposit_success.dart';

class DepositPage extends StatefulWidget {
  final ScrollController scrollController;
  const DepositPage({super.key, required this.scrollController});
  @override
  State<DepositPage> createState() => _DepositPageState();
}
class _DepositPageState extends State<DepositPage> {
  int step = 1;
  final TextEditingController amountController = TextEditingController();
  int selectedAmount = 0;
  String paymentMethod = "card";
  final TextEditingController cardNumber = TextEditingController();
  final TextEditingController expiry = TextEditingController();
  final TextEditingController cvc = TextEditingController();
  final TextEditingController phone = TextEditingController();
  String provider = "";
  final List<int> amounts = [10, 20, 50, 100];
  @override
  void initState() {
    amountController.text = "0.00";
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(0,0,16.w,0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CommonHeader(title:"New Deposit",showDivider: false,),
                        _stepIndicator(),
                      ],
                    ),
                  ),
                  Divider(thickness: 1),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: step == 1 ? step1() : step2(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
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
  Widget step1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Amount", style: AppTextStyle.body),
        SizedBox(height: 10.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w,vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.inputFieldBgDynamic(context),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(border: InputBorder.none),
          ),
        ),
        SizedBox(height: 15.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: amounts.map((e) {
            bool isSelected = selectedAmount == e;
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedAmount = e;
                  amountController.text = e.toString();
                });
              },
              child:Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    width: 1.w,
                    color: isSelected ? AppColors.electricViolet200 : Colors.grey.shade300,
                  ),
                  color: isSelected
                      ? Colors.purple.withOpacity(0.1)
                      : AppColors.white,
                //   electric-violet-200
                ),
                child: Text(
                  "$e GHS",
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? AppColors.electricViolet900
                        : (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : AppColors.electricViolet900), // ✅ FIX
                  ),
                ),
              )
            );
          }).toList(),
        ),
        const Spacer(),
        _button("Continue", () {
          setState(() => step = 2);
        }),
      ],
    );
  }
  Widget step2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Payment Method", style: AppTextStyle.body),
        SizedBox(height: 10.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: AppColors.inputFieldBgDynamic(context),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: DropdownButton<String>(
            value: paymentMethod,
            isExpanded: true,
            underline: const SizedBox(),
            items: [
              DropdownMenuItem(
                value: "card",
                child: Text("Debit/Credit Card", style: AppTextStyle.body),
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
        Consumer<WalletProvider>(
          builder: (context, wallet, _) {
            return _button(
              wallet.isSubmittingDeposit ? 'Submitting...' : 'Confirm',
              wallet.isSubmittingDeposit ? () {} : _submitDeposit,
            );
          },
        ),
      ],
    );
  }

  /// Submit the deposit intent via WalletProvider.
  /// Shows success dialog on success, snackbar with backend message
  /// on failure (e.g. BELOW_MIN_AMOUNT, ABOVE_MAX_AMOUNT).
  Future<void> _submitDeposit() async {
    final wallet = context.read<WalletProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final amount = double.tryParse(amountController.text.trim()) ?? 0;
    if (amount <= 0) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Please enter an amount.')),
      );
      return;
    }

    final method = paymentMethod == 'card' ? 'card' : 'mobile_money';
    final msisdn = paymentMethod == 'momo' ? phone.text.trim() : null;

    final ok = await wallet.submitDeposit(
      amountGhs: amount,
      method: method,
      msisdn: msisdn,
    );

    if (!mounted) return;

    if (ok) {
      Navigator.pop(context);
      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;
      showSuccessDialog(context);
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            wallet.lastSubmitMessage ?? 'Could not submit deposit.',
          ),
        ),
      );
    }
  }

  Widget cardUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Card Number", style: AppTextStyle.body),
        SizedBox(height: 10.h),
        _input(cardNumber, "0000 0000 0000 0000"),
        SizedBox(height: 20.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child:
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Payment Method", style: AppTextStyle.body),
                    SizedBox(height: 10.h),
                    _input(expiry, "MM/YY")
                  ],
                )
            // _input(expiry, "MM/YY")
            ),
            SizedBox(width: 10.w),
            Expanded(child:
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Payment Method", style: AppTextStyle.body),
                SizedBox(height: 10.h),
                _input(cvc, "CVC")
              ],
            )
            // _input(cvc, "CVC")
            ),
          ],
        ),
      ],
    );
  }
  Widget momoUI() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Payment Provider", style: AppTextStyle.body),
          SizedBox(height: 10.h),
          _dropdown("Select Provider", (val) {
            provider = val!;
          }),
          SizedBox(height: 20.h),
          Text("Phone Number", style: AppTextStyle.body),
          SizedBox(height: 10.h),
          _input(phone, "Phone Number"),
        ],
      ),
    );
  }
  Widget _input(TextEditingController controller, String hint) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: AppColors.inputFieldBgDynamic(context),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintStyle: AppTextStyle.body,
          hintText: hint,
          border: InputBorder.none,
        ),
      ),
    );
  }
  Widget _dropdown(String hint, Function(String?) onChanged) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: AppColors.inputFieldBgDynamic(context),
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
