// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// class StepName extends StatefulWidget {
//   final Function(String firstName, String lastName) onChanged;
//
//   const StepName({super.key, required this.onChanged});
//
//   @override
//   State<StepName> createState() => _StepNameState();
// }
//
// class _StepNameState extends State<StepName> {
//   String firstName = "";
//   String lastName = "";
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "What’s Your Name?",
//           style: TextStyle(
//               fontSize: 20.sp,
//               fontWeight: FontWeight.w600,
//               fontFamily: 'SFProRounded'),
//         ),
//
//         SizedBox(height: 20.h),
//
//         _inputField(
//           hint: "First Name",
//           onChanged: (val) {
//             firstName = val;
//             widget.onChanged(firstName, lastName);
//           },
//         ),
//
//         SizedBox(height: 15.h),
//
//         _inputField(
//           hint: "Last Name",
//           onChanged: (val) {
//             lastName = val;
//             widget.onChanged(firstName, lastName);
//           },
//         ),
//       ],
//     );
//   }
//
//   Widget _inputField({
//     required String hint,
//     required Function(String) onChanged,
//   }) {
//     return Container(
//       height: 55.h,
//       padding: EdgeInsets.symmetric(horizontal: 15.w),
//       decoration: BoxDecoration(
//         color: Color(0xFFF1F1F1),
//         borderRadius: BorderRadius.circular(12.r),
//       ),
//       child: TextField(
//         onChanged: onChanged,
//         decoration: InputDecoration(
//           border: InputBorder.none,
//           hintText: hint,
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// class StepName extends StatefulWidget {
//   final Function(String firstName, String lastName) onChanged;
//   final Function(bool) onValidationChanged;
//
//   const StepName({
//     super.key,
//     required this.onChanged,
//     required this.onValidationChanged,
//   });
//
//   @override
//   State<StepName> createState() => _StepNameState();
// }
//
// class _StepNameState extends State<StepName> {
//   String firstName = "";
//   String lastName = "";
//
//   void validate() {
//     bool isValid = firstName.trim().isNotEmpty && lastName.trim().isNotEmpty;
//     widget.onValidationChanged(isValid);
//     widget.onChanged(firstName, lastName);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text("What’s Your Name?",
//             style: TextStyle(
//                 fontSize: 20.sp,
//                 fontWeight: FontWeight.w600,
//                 fontFamily: 'SFProRounded')),
//         SizedBox(height: 20.h),
//         _inputField(hint: "First Name", onChanged: (val) {
//           firstName = val;
//           validate();
//         }),
//         SizedBox(height: 15.h),
//         _inputField(hint: "Last Name", onChanged: (val) {
//           lastName = val;
//           validate();
//         }),
//       ],
//     );
//   }
//
//   Widget _inputField({
//     required String hint,
//     required Function(String) onChanged,
//   }) {
//     return Container(
//       height: 55.h,
//       padding: EdgeInsets.symmetric(horizontal: 15.w),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF1F1F1),
//         borderRadius: BorderRadius.circular(12.r),
//       ),
//       child: TextField(
//         onChanged: onChanged,
//         decoration: InputDecoration(border: InputBorder.none, hintText: hint),
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../../../core/theme/app_colors.dart';
//
// class StepName extends StatefulWidget {
//   final Function(String firstName, String lastName) onChanged;
//   final Function(bool) onValidationChanged;
//
//   const StepName({
//     super.key,
//     required this.onChanged,
//     required this.onValidationChanged,
//   });
//
//   @override
//   State<StepName> createState() => _StepNameState();
// }
//
// class _StepNameState extends State<StepName> {
//   String firstName = "";
//   String lastName = "";
//
//   void validate() {
//     bool isValid = firstName.trim().isNotEmpty && lastName.trim().isNotEmpty;
//     widget.onValidationChanged(isValid);
//     widget.onChanged(firstName, lastName);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "What’s Your Name?",
//           style: TextStyle(
//             fontSize: 20.sp,
//             fontWeight: FontWeight.w600,
//             fontFamily: 'SFProRounded',
//             color: AppColors.textPrimaryDynamic(context),
//           ),
//         ),
//         SizedBox(height: 20.h),
//         _inputField(
//           hint: "First Name",
//           onChanged: (val) {
//             firstName = val;
//             validate();
//           },
//         ),
//         SizedBox(height: 15.h),
//         _inputField(
//           hint: "Last Name",
//           onChanged: (val) {
//             lastName = val;
//             validate();
//           },
//         ),
//       ],
//     );
//   }
//
//   Widget _inputField({
//     required String hint,
//     required Function(String) onChanged,
//   }) {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
//
//     return Container(
//       height: 55.h,
//       padding: EdgeInsets.symmetric(horizontal: 15.w),
//       decoration: BoxDecoration(
//         color: AppColors.inputFieldBgDynamic(context),
//         borderRadius: BorderRadius.circular(12.r),
//         border: Border.all(
//           color: AppColors.borderDynamic(context),
//         ),
//       ),
//       child: TextField(
//         onChanged: onChanged,
//         style: TextStyle(
//           color: AppColors.textPrimaryDynamic(context),
//           fontSize: 14.sp,
//         ),
//         decoration: InputDecoration(
//           border: InputBorder.none,
//           hintText: hint,
//           hintStyle: TextStyle(
//             color: AppColors.textSecondaryDynamic(context),
//             fontSize: 14.sp,
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

class StepName extends StatefulWidget {
  final Function(String firstName, String lastName) onChanged;
  final Function(bool) onValidationChanged;

  const StepName({
    super.key,
    required this.onChanged,
    required this.onValidationChanged,
  });

  @override
  State<StepName> createState() => _StepNameState();
}

class _StepNameState extends State<StepName> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  bool _isDisposed = false;
  String _firstName = "";
  String _lastName = "";

  @override
  void initState() {
    super.initState();
    _firstNameController.addListener(_onFirstNameChanged);
    _lastNameController.addListener(_onLastNameChanged);
  }

  @override
  void dispose() {
    _isDisposed = true;
    _firstNameController.removeListener(_onFirstNameChanged);
    _lastNameController.removeListener(_onLastNameChanged);
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _onFirstNameChanged() {
    if (_isDisposed || !mounted) return;
    _firstName = _firstNameController.text;
    _validate();
  }

  void _onLastNameChanged() {
    if (_isDisposed || !mounted) return;
    _lastName = _lastNameController.text;
    _validate();
  }

  void _validate() {
    if (_isDisposed || !mounted) return;

    final isValid = _firstName.trim().isNotEmpty && _lastName.trim().isNotEmpty;

    try {
      widget.onValidationChanged(isValid);
      widget.onChanged(_firstName, _lastName);
    } catch (e) {
      debugPrint("❌ Name validation error: $e");
    }
  }

  // ✅ FIX #1: Safe theme with fallback
  bool _isDarkMode(BuildContext context) {
    try {
      return Theme.of(context).brightness == Brightness.dark;
    } catch (e) {
      return false;
    }
  }

  // ✅ FIX #2: System font with fallbacks (NO CRASH)
  TextStyle _getTitleStyle() {
    return TextStyle(
      fontSize: 20.sp,
      fontWeight: FontWeight.w600,
      fontFamilyFallback: ['SFProRounded', 'System', 'Helvetica Neue', 'Arial'],
      color: AppColors.textPrimaryDynamic(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isDisposed) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "What's Your Name?",
          style: _getTitleStyle(),
        ),
        SizedBox(height: 20.h),
        _inputField(
          controller: _firstNameController,
          hint: "First Name",
        ),
        SizedBox(height: 15.h),
        _inputField(
          controller: _lastNameController,
          hint: "Last Name",
        ),
      ],
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
  }) {
    final isDarkMode = _isDarkMode(context);

    return Container(
      height: 55.h,
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      decoration: BoxDecoration(
        color: AppColors.inputFieldBgDynamic(context),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.borderDynamic(context),
        ),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(
          color: AppColors.textPrimaryDynamic(context),
          fontSize: 14.sp,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(
            color: AppColors.textSecondaryDynamic(context),
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }
}