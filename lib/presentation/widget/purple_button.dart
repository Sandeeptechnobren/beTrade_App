// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// class Button extends StatefulWidget {
//   final String title;
//   final VoidCallback? onPressed;
//   const Button({super.key, required this.title, required this.onPressed});
//
//   @override
//   State<Button> createState() => _ButtonState();
// }
//
// class _ButtonState extends State<Button> {
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: double.infinity,
//       height: 50.h,
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           elevation: 0,
//           padding: EdgeInsets.zero,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(25.r),
//           ),
//         ),
//         onPressed: widget.onPressed,
//         child: Ink(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(25.r),
//             color: widget.onPressed == null
//                 ? Colors.grey
//                 : Color(0xFF7B2FF7),
//           ),
//           child: Center(
//             child: Text(
//               widget.title,
//               style: TextStyle(fontSize: 14.sp,color: Colors.white,fontWeight: FontWeight.bold),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
class Button extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;
  final bool isPrimary;
  const Button({
    super.key,
    required this.title,
    required this.onPressed,
    this.isPrimary = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.r),
          ),
        ),
        onPressed: onPressed,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25.r),
            color: isPrimary
                ? const Color(0xFF7B2FF7)
                : Colors.grey.shade200,
            border: isPrimary
                ? null
                : Border.all(color: Colors.grey.shade400),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: isPrimary ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}