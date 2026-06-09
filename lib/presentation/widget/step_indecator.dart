import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;

  const StepIndicator({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(5, (index) {
        int step = index + 1;
        final isActive = step <= currentStep;
        return Container(
          width: 30.w,
          height: 30.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isActive
                ? LinearGradient(
                    colors: [Colors.purple, Colors.deepPurple],
                  )
                : null,
            // Inactive (pending) step bubble: light keeps grey.shade300;
            // dark uses a dark surface so it doesn't glare on #121212.
            color: isActive
                ? null
                : (isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade300),
          ),
          child: Center(
            child: Text(
              "$step",
              style: TextStyle(
                // Active label is white on the gradient. Inactive: light keeps
                // black; dark uses white so it's visible on the dark bubble.
                color: isActive
                    ? Colors.white
                    : (isDark ? Colors.white : Colors.black),
                fontSize: 12.sp,
              ),
            ),
          ),
        );
      }),
    );
  }
}
