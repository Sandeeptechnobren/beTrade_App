import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';

//
// class Button extends StatelessWidget {
//   final String title;
//   final VoidCallback? onPressed;
//   final bool isPrimary;
//
//   const Button({
//     super.key,
//     required this.title,
//     required this.onPressed,
//     this.isPrimary = true,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: double.infinity,
//       height: 50.h,
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           elevation: 0,
//           padding: EdgeInsets.zero,
//           backgroundColor: Colors.transparent,
//           shadowColor: Colors.transparent,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(25.r),
//           ),
//         ),
//         onPressed: onPressed,
//         child: Ink(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(25.r),
//             color: isPrimary ? const Color(0xFF7B2FF7) : Colors.grey.shade200,
//             border: isPrimary ? null : Border.all(color: Colors.grey.shade400),
//           ),
//           child: Center(
//             child: Text(
//               title,
//               style: TextStyle(
//                 fontSize: 14.sp,
//                 fontWeight: FontWeight.bold,
//                 color: isPrimary ? Colors.white : Colors.black,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
class Button extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isLoading;

  const Button({
    super.key,
    required this.title,
    required this.onPressed,
    this.isPrimary = true,
    this.isLoading = false,
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
        onPressed: isLoading ? null : onPressed,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25.r),
            color: isPrimary
                ? ((onPressed == null || isLoading)
                    ? AppColors.primary.withOpacity(0.45)
                    : AppColors.primary)
                : AppColors.grey200Dynamic(context),
            border: isPrimary
                ? null
                : Border.all(color: AppColors.borderDynamic(context)),
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: isPrimary
                          ? Colors.white
                          : AppColors.textPrimaryDynamic(context),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
