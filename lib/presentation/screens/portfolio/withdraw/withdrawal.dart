import 'package:betrade/core/theme/app_text_style.dart';
import 'package:betrade/presentation/widget/customSnackBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/provider/wallet_provider.dart';
import '../../../widget/common_header.dart';
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
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController accountNameController = TextEditingController();
  final TextEditingController bankNameController = TextEditingController();
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
                        CommonHeader(title: "New Withdrawal",showDivider: false,),
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
          padding: EdgeInsets.symmetric(horizontal: 12.w),
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
        const Spacer(),
        _button("Continue", () {
          setState(() => step = 2);
        }),
      ],
    );
  }

  Widget step2() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
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
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
        Consumer<WalletProvider>(
          builder: (context, wallet, _) {
            return _button(
              wallet.isSubmittingWithdraw ? 'Submitting...' : 'Confirm',
              wallet.isSubmittingWithdraw ? () {} : _submitWithdraw,
            );
          },
        ),
      ],
    );
  }

  /// Submit the withdrawal intent via WalletProvider.
  /// Backend locks the wallet, validates balance, debits immediately
  /// (so no double-spend), creates a pending Transaction. We surface
  /// INSUFFICIENT_FUNDS specifically since it's the most common error.
  Future<void> _submitWithdraw() async {
    final wallet = context.read<WalletProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final parentContext = context;

    final amount = double.tryParse(amountController.text.trim()) ?? 0;
    if (amount <= 0) {
      CustomSnackBar.showError(context, message: "Please enter an amount.");
      // messenger.showSnackBar(
      //   const SnackBar(content: Text('Please enter an amount.')),
      // );
      return;
    }

    // Build a destination string from the form fields. For card path,
    // use the masked account number; for momo, use provider + phone.
    String destination;
    String? msisdn;
    if (paymentMethod == 'card') {
      final acct = accountNumberController.text.trim();
      destination = acct.isEmpty ? 'card' : 'card:$acct';
    } else {
      msisdn = phone.text.trim();
      final providerLabel = provider.isEmpty ? 'momo' : provider;
      destination = msisdn.isEmpty
          ? providerLabel
          : '$providerLabel:$msisdn';
    }

    final ok = await wallet.submitWithdraw(
      amountGhs: amount,
      destination: destination,
      msisdn: msisdn,
    );

    if (!mounted) return;

    if (ok) {
      Navigator.pop(context);
      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;
      withdrawalSuccessDialog(parentContext);
    } else {
      // Show typed-error message; INSUFFICIENT_FUNDS is mapped by the
      // backend to a user-readable string already.
      CustomSnackBar.showError(context, message:  wallet.lastSubmitMessage ?? 'Could not submit withdrawal.');
      // messenger.showSnackBar(
      //   SnackBar(
      //     content: Text(
      //       wallet.lastSubmitMessage ?? 'Could not submit withdrawal.',
      //     ),
      //   ),
      // );
    }
  }

  Widget cardUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Account Number", style: AppTextStyle.body),
        SizedBox(height: 10.h),
        _input(accountNumberController, "0000 0000 0000 0000"),

        SizedBox(height: 20.h),
        Text("Account Name", style: AppTextStyle.body),
        SizedBox(height: 10.h),
        _input(accountNameController, "Enter account name"),

        SizedBox(height: 20.h),
        Text("Bank Name", style: AppTextStyle.body),
        SizedBox(height: 10.h),
        _input(bankNameController, "Select an option"),
      ],
    );
  }

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

  Widget _input(TextEditingController controller, String hint) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: AppColors.inputFieldBgDynamic(context),
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
