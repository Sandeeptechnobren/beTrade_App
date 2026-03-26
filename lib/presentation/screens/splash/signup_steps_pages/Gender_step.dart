import 'package:betrade/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StepGender extends StatefulWidget {
  final Function(String) onChanged;

  const StepGender({super.key, required this.onChanged});

  @override
  State<StepGender> createState() => _StepGenderState();
}

class _StepGenderState extends State<StepGender> {
  String selected = "";

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "How do You Identify?",
          style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              fontFamily: 'SFProRounded'),
        ),

        SizedBox(height: 20.h),

        _tile("Male"),
        _tile("Female"),
        _tile("Other"),
      ],
    );
  }

  Widget _tile(String text) {
    final value = text.toLowerCase();

    return GestureDetector(
      onTap: () {
        setState(() => selected = value);
        widget.onChanged(value);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: selected == value ? Colors.blue : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text),
            Icon(
              selected == value
                  ? Icons.check_circle
                  : Icons.radio_button_off,
              color:AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}