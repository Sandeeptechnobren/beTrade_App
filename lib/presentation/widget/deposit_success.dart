import 'package:flutter/material.dart';
import '../../core/theme/app_text_style.dart';
import '../widget/purple_button.dart';

void showSuccessDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Deposit Successful", style: AppTextStyle.heading),
              const SizedBox(height: 12),
              Text(
                "Your deposit has been completed successfully. You can save this payment method for faster transactions next time.",
                textAlign: TextAlign.center,
                style: AppTextStyle.bodyBig,
              ),
              const SizedBox(height: 25),
              Button(title: "Save Payment Method", onPressed: () {}),
              const SizedBox(height: 15),
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
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Withdrawal Successful", style: AppTextStyle.heading),
              const SizedBox(height: 12),
              Text(
                "Your withdrawal was completed successfully. Please allow a few moments for the funds to appear in your account.",
                textAlign: TextAlign.center,
                style: AppTextStyle.bodyBig,
              ),
              const SizedBox(height: 25),
              Button(title: "Okay", onPressed: () {}),
            ],
          ),
        ),
      );
    },
  );
}
