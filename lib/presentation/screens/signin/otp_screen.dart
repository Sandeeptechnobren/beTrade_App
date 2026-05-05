// import 'dart:async';
// import 'package:betrade/presentation/screens/main_screen.dart';
// import 'package:betrade/presentation/widget/leading_icon.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:provider/provider.dart';
// import '../../../core/theme/app_colors.dart';
// import '../../../core/theme/app_text_style.dart';
// import '../../../data/provider/signin_provider.dart';
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
//   Timer? _timer;
//   bool isOtpComplete = false;
//   final int otpLength = 6;
//   late List<TextEditingController> _controllers;
//   late List<FocusNode> _focusNodes;
//   bool _isDisposed = false;
//   bool _isVerifying = false;
//   bool _isResending = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _controllers = List.generate(otpLength, (_) => TextEditingController());
//     _focusNodes = List.generate(otpLength, (_) => FocusNode());
//     _startTimer();
//   }
//   void _startTimer() {
//     if (_isDisposed) return;
//
//     _timer?.cancel();
//     secondsRemaining = 30;
//     canResend = false;
//
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (_isDisposed) {
//         timer.cancel();
//         return;
//       }
//
//       if (secondsRemaining == 0) {
//         if (mounted && !_isDisposed) {
//           setState(() {
//             canResend = true;
//           });
//         }
//         timer.cancel();
//       } else {
//         if (mounted && !_isDisposed) {
//           setState(() {
//             secondsRemaining--;
//           });
//         }
//       }
//     });
//   }
//
//   Map<String, dynamic> _safeParseResult(dynamic result) {
//     if (result is Map<String, dynamic>) {
//       return {
//         'success': result['success'] == true,
//         'message': result['message']?.toString() ?? 'Something went wrong',
//       };
//     }
//     return {
//       'success': false,
//       'message': 'Invalid response from server',
//     };
//   }
//   void _showMessage(String message, {bool isError = true}) {
//     if (_isDisposed || !mounted) return;
//
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           message,
//           style: TextStyle(
//             color: isDarkMode ? Colors.white : Colors.black,
//           ),
//         ),
//         backgroundColor: isDarkMode ? Colors.grey.shade800 : null,
//       ),
//     );
//   }
//
//   void _navigateToHome() {
//     if (_isDisposed || !mounted) return;
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted && !_isDisposed) {
//         Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(builder: (_) => const MainScreen(showWelcomePopup: true)),
//               (route) => false,
//         );
//       }
//     });
//   }
//
//   Future<void> _verifyOtp() async {
//     if (_isDisposed || !mounted || _isVerifying) return;
//
//     final otp = _getOtp();
//     if (otp.length != otpLength) {
//       _showMessage("Please enter complete OTP");
//       return;
//     }
//
//     setState(() => _isVerifying = true);
//
//     try {
//       final provider = context.read<AuthProvider>();
//       final result = await provider.verifyOtp(widget.phone, otp);
//
//       if (_isDisposed || !mounted) return;
//
//       final parsed = _safeParseResult(result);
//
//       if (parsed['success'] == true) {
//         _navigateToHome();
//       } else {
//         _showMessage(parsed['message']);
//         _clearOtpFields();
//       }
//     } catch (e) {
//       if (_isDisposed || !mounted) return;
//       _showMessage("Verification failed. Please try again.");
//       debugPrint("❌ Verify OTP error: $e");
//     } finally {
//       if (!_isDisposed && mounted) {
//         setState(() => _isVerifying = false);
//       }
//     }
//   }
//
//   Future<void> _resendOtp() async {
//     if (_isDisposed || !mounted || _isResending) return;
//
//     setState(() => _isResending = true);
//
//     try {
//       final provider = context.read<AuthProvider>();
//       await provider.sendOtp(widget.phone);
//
//       if (_isDisposed || !mounted) return;
//       _clearOtpFields();
//       _startTimer();
//       _showMessage("OTP resent successfully", isError: false);
//     } catch (e) {
//       if (_isDisposed || !mounted) return;
//       _showMessage("Failed to resend OTP. Please try again.");
//       debugPrint("❌ Resend OTP error: $e");
//     } finally {
//       if (!_isDisposed && mounted) {
//         setState(() => _isResending = false);
//       }
//     }
//   }
//
//   void _clearOtpFields() {
//     for (var controller in _controllers) {
//       controller.clear();
//     }
//     _focusNodes.first.requestFocus();
//     setState(() {
//       isOtpComplete = false;
//     });
//   }
//
//   String _getOtp() {
//     return _controllers.map((e) => e.text).join();
//   }
//
//   void _checkOtpComplete() {
//     if (_isDisposed) return;
//     final otp = _getOtp();
//     setState(() {
//       isOtpComplete = otp.length == otpLength;
//     });
//   }
//
//   void _onOtpChanged(String value, int index) {
//     if (_isDisposed) return;
//
//     if (value.length == 1) {
//       if (index < otpLength - 1) {
//         _focusNodes[index + 1].requestFocus();
//       } else {
//         _focusNodes[index].unfocus();
//       }
//     } else if (value.isEmpty) {
//       if (index > 0) {
//         _focusNodes[index - 1].requestFocus();
//       }
//     }
//     _checkOtpComplete();
//   }
//
//   @override
//   void dispose() {
//     _isDisposed = true;
//     _timer?.cancel();
//     for (var controller in _controllers) {
//       controller.dispose();
//     }
//     for (var focusNode in _focusNodes) {
//       focusNode.dispose();
//     }
//     super.dispose();
//   }
//
//   Widget _otpBox(int index) {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
//
//     return SizedBox(
//       width: 55.w,
//       height: 55.h,
//       child: TextField(
//         controller: _controllers[index],
//         focusNode: _focusNodes[index],
//         keyboardType: TextInputType.number,
//         textAlign: TextAlign.center,
//         maxLength: 1,
//         style: TextStyle(
//           fontSize: 18.sp,
//           fontWeight: FontWeight.bold,
//           color: AppColors.textPrimaryDynamic(context),
//         ),
//         decoration: InputDecoration(
//           hintText: "0",
//           hintStyle: TextStyle(
//             color: isDarkMode ? Colors.grey.shade600 : Colors.grey,
//             fontWeight: FontWeight.w400,
//           ),
//           counterText: "",
//           filled: true,
//           fillColor: isDarkMode
//               ? const Color(0xFF2C2C2E)
//               : Colors.grey.shade100,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10.r),
//             borderSide: BorderSide.none,
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10.r),
//             borderSide: BorderSide(
//               color: isDarkMode ? Colors.grey.shade700 : Colors.transparent,
//             ),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10.r),
//             borderSide: const BorderSide(
//               color: AppColors.primary,
//               width: 1.5,
//             ),
//           ),
//         ),
//         onChanged: (value) => _onOtpChanged(value, index),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
//     final isButtonEnabled = isOtpComplete && !_isVerifying && !_isDisposed;
//
//     return Scaffold(
//       backgroundColor: AppColors.cardBackgroundDynamic(context),
//       appBar: AppBar(
//         backgroundColor: AppColors.cardBackgroundDynamic(context),
//         elevation: 0,
//         leading: Padding(
//           padding: EdgeInsets.only(left: 12.w),
//           child: const LeadingIcon(),
//         ),
//       ),
//       body: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 20.w),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(height: 10.h),
//             Text(
//               "Enter OTP Code",
//               style: AppTextStyle.heading.copyWith(
//                 color: AppColors.textPrimaryDynamic(context),
//               ),
//             ),
//             SizedBox(height: 20.h),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: List.generate(otpLength, (index) => _otpBox(index)),
//             ),
//             SizedBox(height: 12.h),
//             Row(
//               children: [
//                 Text(
//                   "Didn't Receive Code? ",
//                   style: TextStyle(
//                     color: isDarkMode ? Colors.grey.shade400 : Colors.grey,
//                     fontSize: 12.sp,
//                   ),
//                 ),
//                 canResend && !_isResending
//                     ? GestureDetector(
//                   onTap: _resendOtp,
//                   child: Text(
//                     "Resend",
//                     style: TextStyle(
//                       color: AppColors.primary,
//                       fontSize: 12.sp,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 )
//                     : Text(
//                   "0:${secondsRemaining.toString().padLeft(2, '0')}",
//                   style: TextStyle(
//                     color: AppColors.primary,
//                     fontSize: 12.sp,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//             const Spacer(),
//
//             // Continue button
//             _isVerifying
//                 ? Center(
//               child: CircularProgressIndicator(
//                 color: AppColors.primary,
//               ),
//             )
//                 : SizedBox(
//               width: double.infinity,
//               height: 50.h,
//               child: ElevatedButton(
//                 onPressed: isButtonEnabled ? _verifyOtp : null,
//                 style: ElevatedButton.styleFrom(
//                   elevation: 0,
//                   padding: EdgeInsets.zero,
//                   backgroundColor: isButtonEnabled
//                       ? AppColors.primary
//                       : AppColors.disableButtonColor,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(25.r),
//                   ),
//                 ),
//                 child: Center(
//                   child: Text(
//                     "Confirm",
//                     style: TextStyle(
//                       fontSize: 15.sp,
//                       color: isButtonEnabled
//                           ? Colors.white
//                           : (isDarkMode ? Colors.grey.shade600 : Colors.grey),
//                     ),
//                   ),
//                 ),
//               ),
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
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_style.dart';
import '../../../data/provider/signin_provider.dart';
import '../../../data/services/local_storage.dart';

class OTPScreen extends StatefulWidget {
  final String phone;

  const OTPScreen({super.key, required this.phone});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  int secondsRemaining = 30;
  bool canResend = false;
  Timer? _timer;
  bool isOtpComplete = false;
  final int otpLength = 6;
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  bool _isDisposed = false;
  bool _isVerifying = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(otpLength, (_) => TextEditingController());
    _focusNodes = List.generate(otpLength, (_) => FocusNode());
    _startTimer();
  }

  void _startTimer() {
    if (_isDisposed) return;

    _timer?.cancel();
    secondsRemaining = 30;
    canResend = false;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isDisposed) {
        timer.cancel();
        return;
      }

      if (secondsRemaining == 0) {
        if (mounted && !_isDisposed) {
          setState(() {
            canResend = true;
          });
        }
        timer.cancel();
      } else {
        if (mounted && !_isDisposed) {
          setState(() {
            secondsRemaining--;
          });
        }
      }
    });
  }

  Map<String, dynamic> _safeParseResult(dynamic result) {
    if (result is Map<String, dynamic>) {
      return {
        'success': result['success'] == true,
        'message': result['message']?.toString() ?? 'Something went wrong',
      };
    }
    return {
      'success': false,
      'message': 'Invalid response from server',
    };
  }

  void _showMessage(String message, {bool isError = true}) {
    if (_isDisposed || !mounted) return;

    final isDarkMode = Theme
        .of(context)
        .brightness == Brightness.dark;
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

  void _navigateToHome(int docUploadStatus) {
    if (_isDisposed || !mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isDisposed) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) =>
                MainScreen(
                  showWelcomePopup: true,
                  docUploadStatus: docUploadStatus,
                ),
          ),
              (route) => false,
        );
      }
    });
  }

  Future<void> _verifyOtp() async {
    if (_isDisposed || !mounted || _isVerifying) return;

    final otp = _getOtp();
    if (otp.length != otpLength) {
      _showMessage("Please enter complete OTP");
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final provider = context.read<AuthProvider>();
      final result = await provider.verifyOtp(widget.phone, otp);

      if (_isDisposed || !mounted) return;

      final parsed = _safeParseResult(result);

      if (parsed['success'] == true) {
        final rawStatus = result['doc_upload_status'];
        final docUploadStatus = rawStatus is int ? rawStatus : 0;
        await LocalStorage.setDocUploadStatus(docUploadStatus);
        _navigateToHome(docUploadStatus);
      } else {
        _showMessage(parsed['message']);
        _clearOtpFields();
      }
    } catch (e) {
      if (_isDisposed || !mounted) return;
      _showMessage("Verification failed. Please try again.");
      debugPrint("❌ Verify OTP error: $e");
    } finally {
      if (!_isDisposed && mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  Future<void> _resendOtp() async {
    if (_isDisposed || !mounted || _isResending) return;

    setState(() => _isResending = true);

    try {
      final provider = context.read<AuthProvider>();
      await provider.sendOtp(widget.phone);

      if (_isDisposed || !mounted) return;

      _clearOtpFields();
      _startTimer();
      _showMessage("OTP resent successfully", isError: false);
    } catch (e) {
      if (_isDisposed || !mounted) return;
      _showMessage("Failed to resend OTP. Please try again.");
      debugPrint("❌ Resend OTP error: $e");
    } finally {
      if (!_isDisposed && mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  void _clearOtpFields() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes.first.requestFocus();
    setState(() {
      isOtpComplete = false;
    });
  }

  String _getOtp() {
    return _controllers.map((e) => e.text).join();
  }

  void _checkOtpComplete() {
    if (_isDisposed) return;
    final otp = _getOtp();
    setState(() {
      isOtpComplete = otp.length == otpLength;
    });
  }

  // void _onOtpChanged(String value, int index) {
  //   if (_isDisposed || !mounted) return;
  //   if (value.isNotEmpty) {
  //     _controllers[index].text = value.substring(value.length - 1);
  //     _controllers[index].selection = TextSelection.fromPosition(
  //       const TextPosition(offset: 1),
  //     );
  //
  //     if (index < otpLength - 1) {
  //       FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
  //     } else {
  //       FocusScope.of(context).unfocus();
  //     }
  //   }
  //   if (value.isEmpty && index > 0) {
  //     FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
  //     _controllers[index - 1].selection =
  //         TextSelection.fromPosition(
  //           TextPosition(
  //             offset: _controllers[index - 1].text.length,
  //           ),
  //         );
  //   }
  //
  //   _checkOtpComplete();
  // }


  void _onOtpChanged(String value, int index) {
    if (_isDisposed || !mounted) return;

    /// 🔹 CASE 1: Paste पूरा OTP (e.g. 123456)
    if (value.length > 1) {
      for (int i = 0; i < otpLength; i++) {
        if (i < value.length) {
          _controllers[i].text = value[i];
        } else {
          _controllers[i].clear();
        }
      }

      FocusScope.of(context).unfocus(); // keyboard close
      _checkOtpComplete();
      return;
    }

    /// 🔹 CASE 2: Normal typing (single digit)
    if (value.isNotEmpty) {
      _controllers[index].text = value;

      if (index < otpLength - 1) {
        FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
      } else {
        FocusScope.of(context).unfocus();
      }
    }

    /// 🔹 CASE 3: Backspace
    if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);

      _controllers[index - 1].selection = TextSelection.fromPosition(
        TextPosition(offset: _controllers[index - 1].text.length),
      );
    }

    _checkOtpComplete();
  }

//
// void _onOtpChanged(String value, int index) {
//   if (_isDisposed) return;
//
//   if (value.length == 1) {
//     if (index < otpLength - 1) {
//       _focusNodes[index + 1].requestFocus();
//     } else {
//       _focusNodes[index].unfocus();
//     }
//   } else if (value.isEmpty) {
//     if (index > 0) {
//       _focusNodes[index - 1].requestFocus();
//     }
//   }
//   _checkOtpComplete();
// }

  @override
  void dispose() {
    _isDisposed = true;
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  Widget _otpBox(int index) {
    final isDarkMode = Theme
        .of(context)
        .brightness == Brightness.dark;
    return SizedBox(
      width: 49.w,
      height: 65.h,
      child: TextField(
        textInputAction: TextInputAction.next,
        autofocus: index == 0,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(otpLength),
        ],
        controller: _controllers[index],
        focusNode: _focusNodes[index],
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
              ? const Color(0xFF2C2C2E)
              : Colors.grey.shade100,
          contentPadding: EdgeInsets.zero,
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
        onChanged: (value) => _onOtpChanged(value, index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme
        .of(context)
        .brightness == Brightness.dark;
    final isButtonEnabled = isOtpComplete && !_isVerifying && !_isDisposed;

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
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(otpLength, (index) => _otpBox(index)),
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Text(
                  "Didn't Receive Code? ",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondaryDynamic(context),
                  ),
                ),
                GestureDetector(
                  onTap: (canResend && !_isResending) ? _resendOtp : null,
                  child: Text(
                    canResend
                        ? "Resend"
                        : "0:${secondsRemaining.toString().padLeft(2, '0')}",
                    style: TextStyle(
                      color: _isResending ? Colors.grey : AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            _isVerifying
                ? Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
                : SizedBox(
              width: double.infinity,
              height: 55.h,
              child: ElevatedButton(
                onPressed: isButtonEnabled ? _verifyOtp : null,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  backgroundColor: isButtonEnabled
                      ? AppColors.primary
                      : AppColors.disableButtonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                ),
                child: Center(
                  child: Text(
                    "Confirm",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: isButtonEnabled
                          ? Colors.white
                          : (isDarkMode
                          ? Colors.grey.shade600
                          : Colors.grey),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}


