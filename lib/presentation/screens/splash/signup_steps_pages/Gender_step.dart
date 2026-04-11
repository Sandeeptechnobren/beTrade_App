// import 'package:betrade/core/theme/app_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// class StepGender extends StatefulWidget {
//   final Function(String) onChanged;
//
//   const StepGender({super.key, required this.onChanged});
//
//   @override
//   State<StepGender> createState() => _StepGenderState();
// }
//
// class _StepGenderState extends State<StepGender> {
//   String selected = "";
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "How do You Identify?",
//           style: TextStyle(
//               fontSize: 20.sp,
//               fontWeight: FontWeight.w600,
//               fontFamily: 'SFProRounded'),
//         ),
//
//         SizedBox(height: 20.h),
//
//         _tile("Male"),
//         _tile("Female"),
//         _tile("Other"),
//       ],
//     );
//   }
//
//   Widget _tile(String text) {
//     final value = text.toLowerCase();
//
//     return GestureDetector(
//       onTap: () {
//         setState(() => selected = value);
//         widget.onChanged(value);
//       },
//       child: Container(
//         margin: EdgeInsets.only(bottom: 12.h),
//         padding: EdgeInsets.all(16.w),
//         decoration: BoxDecoration(
//           color: Colors.grey.shade200,
//           borderRadius: BorderRadius.circular(12.r),
//           border: Border.all(
//             color: selected == value ? Colors.blue : Colors.transparent,
//             width: 1.5,
//           ),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(text),
//             Icon(
//               selected == value
//                   ? Icons.check_circle
//                   : Icons.radio_button_off,
//               color:AppColors.primary,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:betrade/core/theme/app_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// class StepGender extends StatefulWidget {
//   final Function(String) onChanged;
//   final Function(bool) onValidationChanged;
//
//   const StepGender({
//     super.key,
//     required this.onChanged,
//     required this.onValidationChanged,
//   });
//
//   @override
//   State<StepGender> createState() => _StepGenderState();
// }
//
// class _StepGenderState extends State<StepGender> {
//   String selected = "";
//
//   void update(String value) {
//     setState(() => selected = value);
//     widget.onChanged(value);
//     widget.onValidationChanged(value.isNotEmpty);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text("How do You Identify?",
//             style: TextStyle(
//                 fontSize: 20.sp,
//                 fontWeight: FontWeight.w600,
//                 fontFamily: 'SFProRounded')),
//         SizedBox(height: 20.h),
//         _tile("Male"),
//         _tile("Female"),
//         _tile("Other"),
//       ],
//     );
//   }
//
//   Widget _tile(String text) {
//     final value = text.toLowerCase();
//     return GestureDetector(
//       onTap: () => update(value),
//       child: Container(
//         margin: EdgeInsets.only(bottom: 12.h),
//         padding: EdgeInsets.all(16.w),
//         decoration: BoxDecoration(
//           color: Colors.grey.shade200,
//           borderRadius: BorderRadius.circular(12.r),
//           border: Border.all(
//             color: selected == value ? Colors.blue : Colors.transparent,
//             width: 1.5,
//           ),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(text),
//             Icon(
//               selected == value ? Icons.check_circle : Icons.radio_button_off,
//               color: AppColors.primary,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:betrade/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StepGender extends StatefulWidget {
  final Function(String) onChanged;
  final Function(bool) onValidationChanged;

  const StepGender({
    super.key,
    required this.onChanged,
    required this.onValidationChanged,
  });

  @override
  State<StepGender> createState() => _StepGenderState();
}

class _StepGenderState extends State<StepGender> {
  String selected = "";

  void update(String value) {
    setState(() => selected = value);
    widget.onChanged(value);
    widget.onValidationChanged(value.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "How do You Identify?",
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'SFProRounded',
            color: AppColors.textPrimaryDynamic(context),
          ),
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
    final isSelected = selected == value;

    return GestureDetector(
      onTap: () => update(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.inputFieldBgDynamic(context),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.borderDynamic(context),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textPrimaryDynamic(context),
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_off,
              color: isSelected ? AppColors.primary : AppColors.textSecondaryDynamic(context),
              size: 22.sp,
            ),
          ],
        ),
      ),
    );
  }
}