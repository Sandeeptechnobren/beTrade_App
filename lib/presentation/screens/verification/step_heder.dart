// import 'package:flutter/material.dart';
//
// class StepHeader extends StatelessWidget {
//   final int currentStep;
//
//   const StepHeader({super.key, required this.currentStep});
//
//   @override
//   Widget build(BuildContext context) {
//     double progress = (currentStep + 1) / 3;
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             _getTitle(currentStep),
//             style: const TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//
//           Stack(
//             alignment: Alignment.center,
//             children: [
//               SizedBox(
//                 height:30,
//                 width: 30,
//                 child: CircularProgressIndicator(
//                   value: progress,
//                   strokeWidth: 4,
//                   backgroundColor: Colors.grey.shade300,
//                   valueColor:
//                   const AlwaysStoppedAnimation(Colors.deepPurple),
//                 ),
//               ),
//               Text(
//                 "${currentStep + 1}",
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   String _getTitle(int step) {
//     switch (step) {
//       case 0:
//         return "Region & Preferences";
//       case 1:
//         return "Upload Your Ghana Card";
//       case 2:
//         return "Selfie Verification";
//       default:
//         return "";
//     }
//   }
// }

import 'package:betrade/core/theme/app_text_style.dart';
import 'package:flutter/material.dart';

class StepHeader extends StatelessWidget {
  final int currentStep;

  const StepHeader({super.key, required this.currentStep});

  // ✅ FIX #1: Safe progress value (clamped between 0.0 and 1.0)
  double _getSafeProgress() {
    // Ensure currentStep is within valid range (0 to 2 for 3 steps)
    final clampedStep = currentStep.clamp(0, 2);
    final progress = (clampedStep + 1) / 3;
    // Final safety clamp between 0.0 and 1.0
    return progress.clamp(0.0, 1.0);
  }

  String _getTitle(int step) {
    final clampedStep = step.clamp(0, 2);
    switch (clampedStep) {
      case 0:
        return "Region & Preferences";
      case 1:
        return "Upload Your Ghana Card";
      case 2:
        return "Selfie Verification";
      default:
        return "Verification";
    }
  }
  int _getDisplayStep() {
    return currentStep.clamp(0, 2) + 1;
  }

  @override
  Widget build(BuildContext context) {
    final safeProgress = _getSafeProgress();
    final title = _getTitle(currentStep);
    final displayStep = _getDisplayStep();

    return Padding(
      padding:EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style:AppTextStyle.heading
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 30,
                width: 30,
                child: CircularProgressIndicator(
                  value: safeProgress,
                  strokeWidth: 4,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                ),
              ),
              Text(
                "$displayStep",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}