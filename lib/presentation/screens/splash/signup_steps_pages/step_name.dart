// // import 'package:flutter/material.dart';
// // import 'package:flutter_screenutil/flutter_screenutil.dart';
// //
// // class StepName extends StatefulWidget {
// //   final Function(String firstName, String lastName) onChanged;
// //
// //   const StepName({super.key, required this.onChanged});
// //
// //   @override
// //   State<StepName> createState() => _StepNameState();
// // }
// //
// // class _StepNameState extends State<StepName> {
// //   String firstName = "";
// //   String lastName = "";
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(
// //           "What’s Your Name?",
// //           style: TextStyle(
// //               fontSize: 20.sp,
// //               fontWeight: FontWeight.w600,
// //               fontFamily: 'SFProRounded'),
// //         ),
// //
// //         SizedBox(height: 20.h),
// //
// //         _inputField(
// //           hint: "First Name",
// //           onChanged: (val) {
// //             firstName = val;
// //             widget.onChanged(firstName, lastName);
// //           },
// //         ),
// //
// //         SizedBox(height: 15.h),
// //
// //         _inputField(
// //           hint: "Last Name",
// //           onChanged: (val) {
// //             lastName = val;
// //             widget.onChanged(firstName, lastName);
// //           },
// //         ),
// //       ],
// //     );
// //   }
// //
// //   Widget _inputField({
// //     required String hint,
// //     required Function(String) onChanged,
// //   }) {
// //     return Container(
// //       height: 55.h,
// //       padding: EdgeInsets.symmetric(horizontal: 15.w),
// //       decoration: BoxDecoration(
// //         color: Color(0xFFF1F1F1),
// //         borderRadius: BorderRadius.circular(12.r),
// //       ),
// //       child: TextField(
// //         onChanged: onChanged,
// //         decoration: InputDecoration(
// //           border: InputBorder.none,
// //           hintText: hint,
// //         ),
// //       ),
// //     );
// //   }
// // }
//
// // import 'package:flutter/material.dart';
// // import 'package:flutter_screenutil/flutter_screenutil.dart';
// //
// // class StepName extends StatefulWidget {
// //   final Function(String firstName, String lastName) onChanged;
// //   final Function(bool) onValidationChanged;
// //
// //   const StepName({
// //     super.key,
// //     required this.onChanged,
// //     required this.onValidationChanged,
// //   });
// //
// //   @override
// //   State<StepName> createState() => _StepNameState();
// // }
// //
// // class _StepNameState extends State<StepName> {
// //   String firstName = "";
// //   String lastName = "";
// //
// //   void validate() {
// //     bool isValid = firstName.trim().isNotEmpty && lastName.trim().isNotEmpty;
// //     widget.onValidationChanged(isValid);
// //     widget.onChanged(firstName, lastName);
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text("What’s Your Name?",
// //             style: TextStyle(
// //                 fontSize: 20.sp,
// //                 fontWeight: FontWeight.w600,
// //                 fontFamily: 'SFProRounded')),
// //         SizedBox(height: 20.h),
// //         _inputField(hint: "First Name", onChanged: (val) {
// //           firstName = val;
// //           validate();
// //         }),
// //         SizedBox(height: 15.h),
// //         _inputField(hint: "Last Name", onChanged: (val) {
// //           lastName = val;
// //           validate();
// //         }),
// //       ],
// //     );
// //   }
// //
// //   Widget _inputField({
// //     required String hint,
// //     required Function(String) onChanged,
// //   }) {
// //     return Container(
// //       height: 55.h,
// //       padding: EdgeInsets.symmetric(horizontal: 15.w),
// //       decoration: BoxDecoration(
// //         color: const Color(0xFFF1F1F1),
// //         borderRadius: BorderRadius.circular(12.r),
// //       ),
// //       child: TextField(
// //         onChanged: onChanged,
// //         decoration: InputDecoration(border: InputBorder.none, hintText: hint),
// //       ),
// //     );
// //   }
// // }
// // import 'package:flutter/material.dart';
// // import 'package:flutter_screenutil/flutter_screenutil.dart';
// // import '../../../../core/theme/app_colors.dart';
// //
// // class StepName extends StatefulWidget {
// //   final Function(String firstName, String lastName) onChanged;
// //   final Function(bool) onValidationChanged;
// //
// //   const StepName({
// //     super.key,
// //     required this.onChanged,
// //     required this.onValidationChanged,
// //   });
// //
// //   @override
// //   State<StepName> createState() => _StepNameState();
// // }
// //
// // class _StepNameState extends State<StepName> {
// //   String firstName = "";
// //   String lastName = "";
// //
// //   void validate() {
// //     bool isValid = firstName.trim().isNotEmpty && lastName.trim().isNotEmpty;
// //     widget.onValidationChanged(isValid);
// //     widget.onChanged(firstName, lastName);
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(
// //           "What’s Your Name?",
// //           style: TextStyle(
// //             fontSize: 20.sp,
// //             fontWeight: FontWeight.w600,
// //             fontFamily: 'SFProRounded',
// //             color: AppColors.textPrimaryDynamic(context),
// //           ),
// //         ),
// //         SizedBox(height: 20.h),
// //         _inputField(
// //           hint: "First Name",
// //           onChanged: (val) {
// //             firstName = val;
// //             validate();
// //           },
// //         ),
// //         SizedBox(height: 15.h),
// //         _inputField(
// //           hint: "Last Name",
// //           onChanged: (val) {
// //             lastName = val;
// //             validate();
// //           },
// //         ),
// //       ],
// //     );
// //   }
// //
// //   Widget _inputField({
// //     required String hint,
// //     required Function(String) onChanged,
// //   }) {
// //     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
// //
// //     return Container(
// //       height: 55.h,
// //       padding: EdgeInsets.symmetric(horizontal: 15.w),
// //       decoration: BoxDecoration(
// //         color: AppColors.inputFieldBgDynamic(context),
// //         borderRadius: BorderRadius.circular(12.r),
// //         border: Border.all(
// //           color: AppColors.borderDynamic(context),
// //         ),
// //       ),
// //       child: TextField(
// //         onChanged: onChanged,
// //         style: TextStyle(
// //           color: AppColors.textPrimaryDynamic(context),
// //           fontSize: 14.sp,
// //         ),
// //         decoration: InputDecoration(
// //           border: InputBorder.none,
// //           hintText: hint,
// //           hintStyle: TextStyle(
// //             color: AppColors.textSecondaryDynamic(context),
// //             fontSize: 14.sp,
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
//
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../../../core/theme/app_colors.dart';
//
// class StepName extends StatefulWidget {
//   final Function(String firstName, String lastName, String email) onChanged;
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
//   final TextEditingController _firstNameController = TextEditingController();
//   final TextEditingController _lastNameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   bool _isDisposed = false;
//   String _firstName = "";
//   String _lastName = "";
//   String _email = "";
//
//   static final RegExp _emailRegex =
//       RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
//
//   @override
//   void initState() {
//     super.initState();
//     _firstNameController.addListener(_onFirstNameChanged);
//     _lastNameController.addListener(_onLastNameChanged);
//     _emailController.addListener(_onEmailChanged);
//   }
//
//   @override
//   void dispose() {
//     _isDisposed = true;
//     _firstNameController.removeListener(_onFirstNameChanged);
//     _lastNameController.removeListener(_onLastNameChanged);
//     _emailController.removeListener(_onEmailChanged);
//     _firstNameController.dispose();
//     _lastNameController.dispose();
//     _emailController.dispose();
//     super.dispose();
//   }
//
//   void _onFirstNameChanged() {
//     if (_isDisposed || !mounted) return;
//     _firstName = _firstNameController.text;
//     _validate();
//   }
//
//   void _onLastNameChanged() {
//     if (_isDisposed || !mounted) return;
//     _lastName = _lastNameController.text;
//     _validate();
//   }
//
//   void _onEmailChanged() {
//     if (_isDisposed || !mounted) return;
//     _email = _emailController.text;
//     _validate();
//   }
//
//   void _validate() {
//     if (_isDisposed || !mounted) return;
//
//     final isValid = _firstName.trim().isNotEmpty &&
//         _lastName.trim().isNotEmpty &&
//         _emailRegex.hasMatch(_email.trim());
//
//     try {
//       widget.onValidationChanged(isValid);
//       widget.onChanged(_firstName, _lastName, _email);
//     } catch (e) {
//       debugPrint("❌ Name validation error: $e");
//     }
//   }
//
//   // ✅ FIX #1: Safe theme with fallback
//   bool _isDarkMode(BuildContext context) {
//     try {
//       return Theme.of(context).brightness == Brightness.dark;
//     } catch (e) {
//       return false;
//     }
//   }
//
//   // ✅ FIX #2: System font with fallbacks (NO CRASH)
//   TextStyle _getTitleStyle() {
//     return TextStyle(
//       fontSize: 20.sp,
//       fontWeight: FontWeight.w600,
//       fontFamilyFallback: ['SFProRounded', 'System', 'Helvetica Neue', 'Arial'],
//       color: AppColors.textPrimaryDynamic(context),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_isDisposed) return const SizedBox();
//
//     return SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             "What's Your Name?",
//             style: _getTitleStyle(),
//           ),
//           SizedBox(height: 20.h),
//           _inputField(
//             controller: _firstNameController,
//             hint: "First Name",
//           ),
//           SizedBox(height: 15.h),
//           _inputField(
//             controller: _lastNameController,
//             hint: "Last Name",
//           ),
//           SizedBox(height: 15.h),
//           _inputField(
//             controller: _emailController,
//             hint: "Email",
//             keyboardType: TextInputType.emailAddress,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _inputField({
//     required TextEditingController controller,
//     required String hint,
//     TextInputType? keyboardType,
//   }) {
//     final isDarkMode = _isDarkMode(context);
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
//         controller: controller,
//         keyboardType: keyboardType,
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
  final Function(String firstName, String lastName, String email) onChanged;
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
  final TextEditingController _emailController = TextEditingController();

  // FocusNodes let the OUTER container react to focus, instead of the
  // TextField drawing its own inset border.
  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();

  bool _isDisposed = false;
  String _firstName = "";
  String _lastName = "";
  String _email = "";

  static final RegExp _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

  @override
  void initState() {
    super.initState();
    _firstNameController.addListener(_onFirstNameChanged);
    _lastNameController.addListener(_onLastNameChanged);
    _emailController.addListener(_onEmailChanged);

    // Rebuild on focus change so the container border color updates.
    _firstNameFocus.addListener(_onFocusChange);
    _lastNameFocus.addListener(_onFocusChange);
    _emailFocus.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _isDisposed = true;
    _firstNameController.removeListener(_onFirstNameChanged);
    _lastNameController.removeListener(_onLastNameChanged);
    _emailController.removeListener(_onEmailChanged);
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();

    _firstNameFocus.removeListener(_onFocusChange);
    _lastNameFocus.removeListener(_onFocusChange);
    _emailFocus.removeListener(_onFocusChange);
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_isDisposed || !mounted) return;
    setState(() {}); // repaint container border for the focused field
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

  void _onEmailChanged() {
    if (_isDisposed || !mounted) return;
    _email = _emailController.text;
    _validate();
  }

  void _validate() {
    if (_isDisposed || !mounted) return;

    final isValid = _firstName.trim().isNotEmpty &&
        _lastName.trim().isNotEmpty &&
        _emailRegex.hasMatch(_email.trim());

    try {
      widget.onValidationChanged(isValid);
      widget.onChanged(_firstName, _lastName, _email);
    } catch (e) {
      debugPrint("❌ Name validation error: $e");
    }
  }

  TextStyle _getTitleStyle() {
    return TextStyle(
      fontSize: 20.sp,
      fontWeight: FontWeight.w600,
      fontFamilyFallback: const ['SFProRounded', 'System', 'Helvetica Neue', 'Arial'],
      color: AppColors.textPrimaryDynamic(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isDisposed) return const SizedBox();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "What's Your Name?",
            style: _getTitleStyle(),
          ),
          SizedBox(height: 20.h),
          _inputField(
            controller: _firstNameController,
            focusNode: _firstNameFocus,
            hint: "First Name",
          ),
          SizedBox(height: 15.h),
          _inputField(
            controller: _lastNameController,
            focusNode: _lastNameFocus,
            hint: "Last Name",
          ),
          SizedBox(height: 15.h),
          _inputField(
            controller: _emailController,
            focusNode: _emailFocus,
            hint: "Email",
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    TextInputType? keyboardType,
  }) {
    final isFocused = focusNode.hasFocus;

    return Container(
      height: 55.h,
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      decoration: BoxDecoration(
        color: AppColors.inputFieldBgDynamic(context),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          // Border now wraps the WHOLE field and simply changes color/width
          // on focus, instead of the TextField drawing a second, inset border.
          color: isFocused
              ? Theme.of(context).colorScheme.primary
              : AppColors.borderDynamic(context),
          width: isFocused ? 1.5 : 1,
        ),
      ),
      child: Center(
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          style: TextStyle(
            color: AppColors.textPrimaryDynamic(context),
            fontSize: 14.sp,
          ),
          cursorColor: Theme.of(context).colorScheme.primary,
          decoration: InputDecoration(
            isCollapsed: true, // kills default content padding/box sizing
            filled: false,     // no fill layer from the TextField itself
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.textSecondaryDynamic(context),
              fontSize: 14.sp,
            ),
          ),
        ),
      ),
    );
  }
}