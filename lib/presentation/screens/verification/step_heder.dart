import 'package:flutter/material.dart';

class StepHeader extends StatelessWidget {
  final int currentStep;

  const StepHeader({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    double progress = (currentStep + 1) / 3;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// Title (dynamic)
          Text(
            _getTitle(currentStep),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          /// Circular Progress
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 40,
                width: 40,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 4,
                  backgroundColor: Colors.grey.shade300,
                  valueColor:
                  const AlwaysStoppedAnimation(Colors.deepPurple),
                ),
              ),
              Text(
                "${currentStep + 1}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getTitle(int step) {
    switch (step) {
      case 0:
        return "Region & Preferences";
      case 1:
        return "ID Verification";
      case 2:
        return "Selfie Verification";
      default:
        return "";
    }
  }
}