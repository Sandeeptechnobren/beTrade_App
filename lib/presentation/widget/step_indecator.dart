import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;

  const StepIndicator({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(5, (index) {
        int step = index + 1;
        return Container(
          width: 30.w,
          height: 30.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: step <= currentStep
                ? LinearGradient(
              colors: [Colors.purple, Colors.deepPurple],
            )
                : null,
            color: step <= currentStep ? null : Colors.grey.shade300,
          ),
          child: Center(
            child: Text(
              "$step",
              style: TextStyle(
                color: step <= currentStep ? Colors.white : Colors.black,
                fontSize: 12.sp,
              ),
            ),
          ),
        );
      }),
    );
  }
}