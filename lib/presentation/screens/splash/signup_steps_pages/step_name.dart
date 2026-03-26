import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StepName extends StatefulWidget {
  final Function(String firstName, String lastName) onChanged;

  const StepName({super.key, required this.onChanged});

  @override
  State<StepName> createState() => _StepNameState();
}

class _StepNameState extends State<StepName> {
  String firstName = "";
  String lastName = "";

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "What’s Your Name?",
          style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              fontFamily: 'SFProRounded'),
        ),

        SizedBox(height: 20.h),

        _inputField(
          hint: "First Name",
          onChanged: (val) {
            firstName = val;
            widget.onChanged(firstName, lastName);
          },
        ),

        SizedBox(height: 15.h),

        _inputField(
          hint: "Last Name",
          onChanged: (val) {
            lastName = val;
            widget.onChanged(firstName, lastName);
          },
        ),
      ],
    );
  }

  Widget _inputField({
    required String hint,
    required Function(String) onChanged,
  }) {
    return Container(
      height: 55.h,
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      decoration: BoxDecoration(
        color: Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
        ),
      ),
    );
  }
}