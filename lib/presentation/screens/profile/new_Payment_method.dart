import 'package:betrade/presentation/widget/common_bottom_sheet.dart';
import 'package:betrade/presentation/widget/purple_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_style.dart';
import '../../widget/common_header.dart';
import 'all_payment_methods.dart';

class NewPaymentMethodPage extends StatefulWidget {
  const NewPaymentMethodPage({
    super.key,
    required ScrollController scrollController,
  });

  @override
  State<NewPaymentMethodPage> createState() => _NewPaymentMethodPageState();
}

class _NewPaymentMethodPageState extends State<NewPaymentMethodPage> {
  String paymentMethod = "bank";

  final TextEditingController accountNumber = TextEditingController();
  final TextEditingController accountName = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Button(title: "Add", onPressed: () {

          CommonBottomSheet.open(
            context: context,
            builder: (controller) =>
                AllPaymentMethodsPage(scrollController: controller),
          );
        }),
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            CommonHeader(title: "New Payment Method", showDivider: true),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: SingleChildScrollView(
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
                          items: const [
                            DropdownMenuItem(
                              value: "bank",
                              child: Text("Bank Account"),
                            ),
                            DropdownMenuItem(
                              value: "card",
                              child: Text("Card"),
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
                      Text("Account Number", style: AppTextStyle.body),
                      SizedBox(height: 10.h),
                      _input(accountNumber, "0000 0000 0000 0000"),
                      SizedBox(height: 20.h),
                      Text("Account Name", style: AppTextStyle.body),
                      SizedBox(height: 10.h),
                      _input(accountName, "Enter account name"),
                      SizedBox(height: 20.h),
                      Text("Bank Name", style: AppTextStyle.body),
                      SizedBox(height: 10.h),
                      _dropdown("Select an option", (val) {}),
                      SizedBox(height: 30.h),

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

  Widget _input(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyle.body,
        filled: true,
        fillColor:AppColors.inputFieldBgDynamic(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
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
          DropdownMenuItem(value: "sbi", child: Text("SBI")),
          DropdownMenuItem(value: "hdfc", child: Text("HDFC")),
        ],
        onChanged: onChanged,
      ),
    );
  }
}
