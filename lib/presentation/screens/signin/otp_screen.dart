// import 'dart:async';
// import 'package:betrade/presentation/screens/main_screen.dart';
// import 'package:betrade/presentation/widget/leading_icon.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:provider/provider.dart';
// import '../../../core/theme/app_colors.dart';
// import '../../../core/theme/app_text_style.dart';
// import '../../../data/provider/signIn_provider.dart';
//
// class OTPScreen extends StatefulWidget {
//   final String phone;
//
//   const OTPScreen({super.key, required this.phone});
//
//   @override
//   State<OTPScreen> createState() => _OTPScreenState();
// }
//
// class _OTPScreenState extends State<OTPScreen> {
//   int secondsRemaining = 30;
//   bool canResend = false;
//   late Timer timer;
//   bool isOtpComplete = false;
//   TextEditingController otpController = TextEditingController();
//   final int otpLength = 6;
//   late List<TextEditingController> controllers;
//   late List<FocusNode> focusNodes;
//
//   @override
//   void initState() {
//     super.initState();
//     controllers = List.generate(otpLength, (_) => TextEditingController());
//     focusNodes = List.generate(otpLength, (_) => FocusNode());
//     startTimer();
//   }
//
//   void startTimer() {
//     secondsRemaining = 30;
//     canResend = false;
//     timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (secondsRemaining == 0) {
//         setState(() {
//           canResend = true;
//         });
//         timer.cancel();
//       } else {
//         setState(() {
//           secondsRemaining--;
//         });
//       }
//     });
//   }
//
//   Future<void> _verifyOtp() async {
//     final provider = context.read<AuthProvider>();
//     String otp = getOtp();
//     final result = await provider.verifyOtp(widget.phone, otp);
//     if (result['success']) {
//       _navigateToHome();
//     } else {
//       _showError(result['message']);
//     }
//   }
//
//   void _showError(String message) {
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text(message)));
//   }
//
//   Future<void> _resendOtp() async {
//     startTimer();
//     await context.read<AuthProvider>().sendOtp(widget.phone);
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(const SnackBar(content: Text("OTP resent")));
//   }
//
//   void _navigateToHome() {
//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(builder: (_) => MainScreen(showWelcomePopup: true)),
//       (route) => false,
//     );
//   }
//
//   @override
//   void dispose() {
//     timer.cancel();
//     for (var c in controllers) c.dispose();
//     for (var f in focusNodes) f.dispose();
//     super.dispose();
//   }
//
//   String getOtp() {
//     return controllers.map((e) => e.text).join();
//   }
//
//   void checkOtpComplete() {
//     String otp = controllers.map((e) => e.text).join();
//     setState(() {
//       isOtpComplete = otp.length == otpLength;
//     });
//   }
//
//   Widget otpBox(int index) {
//     return SizedBox(
//       width: 55.w,
//       height: 65.h,
//       child: TextField(
//         controller: controllers[index],
//         focusNode: focusNodes[index],
//         keyboardType: TextInputType.number,
//         textAlign: TextAlign.center,
//         maxLength: 1,
//         style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
//         decoration: InputDecoration(
//           hintText: "0",
//           hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.w400),
//           counterText: "",
//           filled: true,
//           fillColor: Colors.grey.shade100,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10.r),
//             borderSide: BorderSide.none,
//           ),
//         ),
//         onChanged: (value) {
//           if (value.length == 1) {
//             if (index < otpLength - 1) {
//               FocusScope.of(context).requestFocus(focusNodes[index + 1]);
//             } else {
//               focusNodes[index].unfocus(); // last box
//             }
//           } else if (value.isEmpty) {
//             if (index > 0) {
//               FocusScope.of(context).requestFocus(focusNodes[index - 1]);
//             }
//           }
//           checkOtpComplete();
//         },
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: Padding(
//           padding: EdgeInsets.only(left: 12.w),
//           child: LeadingIcon(),
//         ),
//       ),
//       body: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 20.w),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(height: 10.h),
//             Text("Enter OTP Code", style: AppTextStyle.heading),
//             SizedBox(height: 25.h),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: List.generate(otpLength, (index) => otpBox(index)),
//             ),
//             SizedBox(height: 15.h),
//             Row(
//               children: [
//                 Text(
//                   "Didn’t Receive Code? ",
//                   style: TextStyle(color: Colors.grey, fontSize: 12.sp),
//                 ),
//                 canResend
//                     ? GestureDetector(
//                         onTap: () {
//                           startTimer();
//                           print("Resend OTP");
//                         },
//                         child: Text(
//                           "Resend",
//                           style: TextStyle(
//                             color: AppColors.primary,
//                             fontSize: 12.sp,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       )
//                     : Text(
//                         "0:${secondsRemaining.toString().padLeft(2, '0')}",
//                         style: TextStyle(
//                           color: AppColors.primary,
//                           fontSize: 12.sp,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//               ],
//             ),
//             const Spacer(),
//             Consumer<AuthProvider>(
//               builder: (context, provider, child) {
//                 return provider.isLoading
//                     ? const Center(child: CircularProgressIndicator())
//                     : SizedBox(
//                         width: double.infinity,
//                         height: 50.h,
//                         child: ElevatedButton(
//                           onPressed: isOtpComplete ? _verifyOtp : null,
//                           style: ElevatedButton.styleFrom(
//                             elevation: 0,
//                             padding: EdgeInsets.zero,
//                             backgroundColor: isOtpComplete
//                                 ? null
//                                 : AppColors.disableButtonColor,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(25.r),
//                             ),
//                           ),
//                           child: Ink(
//                             decoration: isOtpComplete
//                                 ? BoxDecoration(
//                                     borderRadius: BorderRadius.circular(25.r),
//                                     color: AppColors.primary,
//                                   )
//                                 : null,
//                             child: Center(
//                               child: Text(
//                                 "Confirm",
//                                 style: TextStyle(
//                                   fontSize: 15.sp,
//                                   color: isOtpComplete
//                                       ? Colors.white
//                                       : Colors.grey,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//               },
//             ),
//             SizedBox(height: 20.h),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'dart:async';
import 'package:betrade/presentation/screens/main_screen.dart';
import 'package:betrade/presentation/widget/leading_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_style.dart';
import '../../../data/provider/signIn_provider.dart';

class OTPScreen extends StatefulWidget {
  final String phone;

  const OTPScreen({super.key, required this.phone});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  int secondsRemaining = 30;
  bool canResend = false;
  late Timer timer;
  bool isOtpComplete = false;
  TextEditingController otpController = TextEditingController();
  final int otpLength = 6;
  late List<TextEditingController> controllers;
  late List<FocusNode> focusNodes;

  @override
  void initState() {
    super.initState();
    controllers = List.generate(otpLength, (_) => TextEditingController());
    focusNodes = List.generate(otpLength, (_) => FocusNode());
    startTimer();
  }

  void startTimer() {
    secondsRemaining = 30;
    canResend = false;
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining == 0) {
        setState(() {
          canResend = true;
        });
        timer.cancel();
      } else {
        setState(() {
          secondsRemaining--;
        });
      }
    });
  }

  Future<void> _verifyOtp() async {
    final provider = context.read<AuthProvider>();
    String otp = getOtp();
    final result = await provider.verifyOtp(widget.phone, otp);
    if (result['success']) {
      _navigateToHome();
    } else {
      _showError(result['message']);
    }
  }

  void _showError(String message) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: isDarkMode ? Colors.grey.shade800 : null,
      ),
    );
  }

  Future<void> _resendOtp() async {
    startTimer();
    await context.read<AuthProvider>().sendOtp(widget.phone);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "OTP resent",
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: isDarkMode ? Colors.grey.shade800 : null,
      ),
    );
  }

  void _navigateToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => MainScreen(showWelcomePopup: true)),
          (route) => false,
    );
  }

  @override
  void dispose() {
    timer.cancel();
    for (var c in controllers) c.dispose();
    for (var f in focusNodes) f.dispose();
    super.dispose();
  }

  String getOtp() {
    return controllers.map((e) => e.text).join();
  }

  void checkOtpComplete() {
    String otp = controllers.map((e) => e.text).join();
    setState(() {
      isOtpComplete = otp.length == otpLength;
    });
  }

  Widget otpBox(int index) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: 55.w,
      height: 65.h,
      child: TextField(
        controller: controllers[index],
        focusNode: focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimaryDynamic(context),
        ),
        decoration: InputDecoration(
          hintText: "0",
          hintStyle: TextStyle(
            color: isDarkMode ? Colors.grey.shade600 : Colors.grey,
            fontWeight: FontWeight.w400,
          ),
          counterText: "",
          filled: true,
          fillColor: isDarkMode
              ? const Color(0xFF2C2C2E)  // Dark mode OTP box bg
              : Colors.grey.shade100,    // Light mode OTP box bg
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(
              color: isDarkMode ? Colors.grey.shade700 : Colors.transparent,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 1.5,
            ),
          ),
        ),
        onChanged: (value) {
          if (value.length == 1) {
            if (index < otpLength - 1) {
              FocusScope.of(context).requestFocus(focusNodes[index + 1]);
            } else {
              focusNodes[index].unfocus();
            }
          } else if (value.isEmpty) {
            if (index > 0) {
              FocusScope.of(context).requestFocus(focusNodes[index - 1]);
            }
          }
          checkOtpComplete();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.cardBackgroundDynamic(context),
      appBar: AppBar(
        backgroundColor: AppColors.cardBackgroundDynamic(context),
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: 12.w),
          child: const LeadingIcon(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.h),
            Text(
              "Enter OTP Code",
              style: AppTextStyle.heading.copyWith(
                color: AppColors.textPrimaryDynamic(context),
              ),
            ),
            SizedBox(height: 25.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(otpLength, (index) => otpBox(index)),
            ),
            SizedBox(height: 15.h),
            Row(
              children: [
                Text(
                  "Didn’t Receive Code? ",
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey.shade400 : Colors.grey,
                    fontSize: 12.sp,
                  ),
                ),
                canResend
                    ? GestureDetector(
                  onTap: () {
                    _resendOtp();
                  },
                  child: Text(
                    "Resend",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
                    : Text(
                  "0:${secondsRemaining.toString().padLeft(2, '0')}",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Consumer<AuthProvider>(
              builder: (context, provider, child) {
                return provider.isLoading
                    ? Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                )
                    : SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: isOtpComplete ? _verifyOtp : null,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      backgroundColor: isOtpComplete
                          ? AppColors.primary
                          : AppColors.disableButtonColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "Confirm",
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: isOtpComplete
                              ? Colors.white
                              : (isDarkMode ? Colors.grey.shade600 : Colors.grey),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
