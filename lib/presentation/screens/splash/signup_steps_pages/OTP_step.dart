// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:provider/provider.dart';
// import '../../../../core/theme/app_colors.dart';
// import '../../../../data/provider/signUp_provider.dart';
//
// class StepOtp extends StatefulWidget {
//   final Function(String) onChanged;
//
//   const StepOtp({super.key, required this.onChanged});
//
//   @override
//   State<StepOtp> createState() => _StepOtpState();
// }
//
// class _StepOtpState extends State<StepOtp> {
//   List<TextEditingController> controllers =
//   List.generate(6, (_) => TextEditingController());
//
//   List<FocusNode> focusNodes =
//   List.generate(6, (_) => FocusNode());
//
//   int seconds = 30;
//   Timer? timer;
//
//   @override
//   void initState() {
//     super.initState();
//     startTimer();
//   }
//
//   void startTimer() {
//     seconds = 30;
//     timer?.cancel();
//
//     timer = Timer.periodic(const Duration(seconds: 1), (t) {
//       if (seconds == 0) {
//         t.cancel();
//       } else {
//         setState(() => seconds--);
//       }
//     });
//   }
//
//   void onOtpChange() {
//     String otp = controllers.map((e) => e.text).join();
//
//     widget.onChanged(otp);
//
//     context.read<SignupProvider>().setOtp(otp);
//
//     print(" OTP: $otp");
//   }
//
//   @override
//   void dispose() {
//     timer?.cancel();
//     for (var c in controllers) {
//       c.dispose();
//     }
//     for (var f in focusNodes) {
//       f.dispose();
//     }
//     super.dispose();
//   }
//
//   Widget otpBox(int index) {
//     return SizedBox(
//       width: 50.w,
//       height: 55.h,
//       child: TextField(
//         controller: controllers[index],
//         focusNode: focusNodes[index],
//         keyboardType: TextInputType.number,
//         textAlign: TextAlign.center,
//         textAlignVertical: TextAlignVertical.center,
//         style: TextStyle(
//           fontSize: 20.sp,
//           fontWeight: FontWeight.w600,
//         ),
//         maxLength: 1,
//         decoration: InputDecoration(
//           counterText: "",
//           hintText: "0",
//           hintStyle: TextStyle(
//             fontSize: 20.sp,
//             fontWeight: FontWeight.w500,
//             color: Colors.grey.shade400,
//           ),
//           filled: true,
//           fillColor: Colors.grey.shade200,
//           contentPadding: EdgeInsets.zero,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12.r),
//             borderSide: BorderSide.none,
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12.r),
//             borderSide: BorderSide(
//               color: Colors.transparent,
//             ),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12.r),
//             borderSide: BorderSide(
//               color: AppColors.primary,
//               width: 1.5,
//             ),
//           ),
//         ),
//         onChanged: (value) {
//           if (value.isNotEmpty && index < 5) {
//             focusNodes[index + 1].requestFocus();
//           }
//           if (value.isEmpty && index > 0) {
//             focusNodes[index - 1].requestFocus();
//           }
//           onOtpChange();
//         },
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "Enter OTP Code",
//           style: TextStyle(
//             fontSize: 20.sp,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//
//         SizedBox(height: 20.h),
//
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: List.generate(6, (index) => otpBox(index)),
//         ),
//
//         SizedBox(height: 20.h),
//
//         Row(
//           children: [
//             Text(
//               "Didn't Receive Code? ",
//               style: TextStyle(fontSize: 14.sp),
//             ),
//             GestureDetector(
//               onTap: seconds == 0
//                   ? () {
//                 startTimer();
//                 // TODO: resend OTP API
//               }
//                   : null,
//               child: Text(
//                 seconds == 0 ? "Resend" : "0:$seconds",
//                 style: TextStyle(
//                   color:AppColors.primary,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             )
//           ],
//         )
//       ],
//     );
//   }
// }

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:provider/provider.dart';
// import '../../../../core/theme/app_colors.dart';
// import '../../../../data/provider/signUp_provider.dart';
//
// class StepOtp extends StatefulWidget {
//   final Function(String) onChanged;
//   final Function(bool) onValidationChanged;
//
//   const StepOtp({
//     super.key,
//     required this.onChanged,
//     required this.onValidationChanged,
//   });
//
//   @override
//   State<StepOtp> createState() => _StepOtpState();
// }
//
// class _StepOtpState extends State<StepOtp> {
//   List<TextEditingController> controllers =
//   List.generate(6, (_) => TextEditingController());
//   List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());
//   int seconds = 30;
//   Timer? timer;
//
//   @override
//   void initState() {
//     super.initState();
//     startTimer();
//   }
//
//   void startTimer() {
//     seconds = 30;
//     timer?.cancel();
//     timer = Timer.periodic(const Duration(seconds: 1), (t) {
//       if (seconds == 0) {
//         t.cancel();
//       } else {
//         setState(() => seconds--);
//       }
//     });
//   }
//
//   void onOtpChange() {
//     String otp = controllers.map((e) => e.text).join();
//     widget.onChanged(otp);
//     context.read<SignupProvider>().setOtp(otp);
//     bool isValid = otp.length == 6;
//     widget.onValidationChanged(isValid);
//   }
//
//   @override
//   void dispose() {
//     timer?.cancel();
//     for (var c in controllers) c.dispose();
//     for (var f in focusNodes) f.dispose();
//     super.dispose();
//   }
//
//   Widget otpBox(int index) {
//     return SizedBox(
//       width: 50.w,
//       height: 55.h,
//       child: TextField(
//         controller: controllers[index],
//         focusNode: focusNodes[index],
//         keyboardType: TextInputType.number,
//         textAlign: TextAlign.center,
//         textAlignVertical: TextAlignVertical.center,
//         style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600),
//         maxLength: 1,
//         decoration: InputDecoration(
//           counterText: "",
//           hintText: "0",
//           hintStyle: TextStyle(
//             fontSize: 20.sp,
//             fontWeight: FontWeight.w500,
//             color: Colors.grey.shade400,
//           ),
//           filled: true,
//           fillColor: Colors.grey.shade200,
//           contentPadding: EdgeInsets.zero,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12.r),
//             borderSide: BorderSide.none,
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12.r),
//             borderSide: BorderSide(color: AppColors.primary, width: 1.5),
//           ),
//         ),
//         onChanged: (value) {
//           if (value.isNotEmpty && index < 5) {
//             focusNodes[index + 1].requestFocus();
//           }
//           if (value.isEmpty && index > 0) {
//             focusNodes[index - 1].requestFocus();
//           }
//           onOtpChange();
//         },
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text("Enter OTP Code",
//             style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600)),
//         SizedBox(height: 20.h),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: List.generate(6, (index) => otpBox(index)),
//         ),
//         SizedBox(height: 20.h),
//         Row(
//           children: [
//             Text("Didn't Receive Code? ", style: TextStyle(fontSize: 14.sp)),
//             GestureDetector(
//               onTap: seconds == 0 ? () => startTimer() : null,
//               child: Text(
//                 seconds == 0 ? "Resend" : "0:$seconds",
//                 style: TextStyle(
//                   color: AppColors.primary,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             )
//           ],
//         )
//       ],
//     );
//   }
// }
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:provider/provider.dart';
// import '../../../../core/theme/app_colors.dart';
// import '../../../../data/provider/signUp_provider.dart';
//
// class StepOtp extends StatefulWidget {
//   final Function(String) onChanged;
//   final Function(bool) onValidationChanged;
//
//   const StepOtp({
//     super.key,
//     required this.onChanged,
//     required this.onValidationChanged,
//   });
//
//   @override
//   State<StepOtp> createState() => _StepOtpState();
// }
//
// class _StepOtpState extends State<StepOtp> {
//   List<TextEditingController> controllers =
//   List.generate(6, (_) => TextEditingController());
//   List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());
//   int seconds = 30;
//   Timer? timer;
//
//   @override
//   void initState() {
//     super.initState();
//     startTimer();
//   }
//
//   void startTimer() {
//     seconds = 30;
//     timer?.cancel();
//     timer = Timer.periodic(const Duration(seconds: 1), (t) {
//       if (seconds == 0) {
//         t.cancel();
//       } else {
//         setState(() => seconds--);
//       }
//     });
//   }
//
//   void onOtpChange() {
//     String otp = controllers.map((e) => e.text).join();
//     widget.onChanged(otp);
//     context.read<SignupProvider>().setOtp(otp);
//     bool isValid = otp.length == 6;
//     widget.onValidationChanged(isValid);
//   }
//
//   @override
//   void dispose() {
//     timer?.cancel();
//     for (var c in controllers) c.dispose();
//     for (var f in focusNodes) f.dispose();
//     super.dispose();
//   }
//
//   Widget otpBox(int index) {
//     return SizedBox(
//       width: 50.w,
//       height: 55.h,
//       child: TextField(
//         controller: controllers[index],
//         focusNode: focusNodes[index],
//         keyboardType: TextInputType.number,
//         textAlign: TextAlign.center,
//         textAlignVertical: TextAlignVertical.center,
//         style: TextStyle(
//           fontSize: 20.sp,
//           fontWeight: FontWeight.w600,
//           color: AppColors.textPrimaryDynamic(context),
//         ),
//         maxLength: 1,
//         decoration: InputDecoration(
//           counterText: "",
//           hintText: "0",
//           hintStyle: TextStyle(
//             fontSize: 20.sp,
//             fontWeight: FontWeight.w500,
//             color: AppColors.textSecondaryDynamic(context),
//           ),
//           filled: true,
//           fillColor: AppColors.inputFieldBgDynamic(context),
//           contentPadding: EdgeInsets.zero,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12.r),
//             borderSide: BorderSide(
//               color: AppColors.borderDynamic(context),
//               width: 0,
//             ),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12.r),
//             borderSide: BorderSide(
//               color: AppColors.borderDynamic(context),
//               width: 0,
//             ),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12.r),
//             borderSide: const BorderSide(
//               color: AppColors.primary,
//               width: 1.5,
//             ),
//           ),
//         ),
//         onChanged: (value) {
//           if (value.isNotEmpty && index < 5) {
//             focusNodes[index + 1].requestFocus();
//           }
//           if (value.isEmpty && index > 0) {
//             focusNodes[index - 1].requestFocus();
//           }
//           onOtpChange();
//         },
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "Enter OTP Code",
//           style: TextStyle(
//             fontSize: 20.sp,
//             fontWeight: FontWeight.w600,
//             color: AppColors.textPrimaryDynamic(context),
//           ),
//         ),
//         SizedBox(height: 20.h),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: List.generate(6, (index) => otpBox(index)),
//         ),
//         SizedBox(height: 20.h),
//         Row(
//           children: [
//             Text(
//               "Didn't Receive Code? ",
//               style: TextStyle(
//                 fontSize: 14.sp,
//                 color: AppColors.textSecondaryDynamic(context),
//               ),
//             ),
//             GestureDetector(
//               onTap: seconds == 0 ? () => startTimer() : null,
//               child: Text(
//                 seconds == 0 ? "Resend" : "0:$seconds",
//                 style: TextStyle(
//                   color: AppColors.primary,
//                   fontWeight: FontWeight.w600,
//                   fontSize: 14.sp,
//                 ),
//               ),
//             )
//           ],
//         )
//       ],
//     );
//   }
// }

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:provider/provider.dart';
// import '../../../../core/theme/app_colors.dart';
// import '../../../../data/provider/signUp_provider.dart';
//
// class StepOtp extends StatefulWidget {
//   final Function(String) onChanged;
//   final Function(bool) onValidationChanged;
//
//   const StepOtp({
//     super.key,
//     required this.onChanged,
//     required this.onValidationChanged,
//   });
//
//   @override
//   State<StepOtp> createState() => _StepOtpState();
// }
//
// class _StepOtpState extends State<StepOtp> {
//   late List<TextEditingController> _controllers;
//   late List<FocusNode> _focusNodes;
//   int _seconds = 30;
//   Timer? _timer;
//   bool _isDisposed = false;
//   bool _isProcessing = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _controllers = List.generate(6, (_) => TextEditingController());
//     _focusNodes = List.generate(6, (_) => FocusNode());
//     _startTimer();
//   }
//
//   @override
//   void dispose() {
//     _isDisposed = true;
//     _timer?.cancel();
//     for (var c in _controllers) {
//       c.dispose();
//     }
//     for (var f in _focusNodes) {
//       f.dispose();
//     }
//     super.dispose();
//   }
//
//   // ✅ FIX #1: Safe setState with mounted check
//   void _safeSetState(VoidCallback fn) {
//     if (!_isDisposed && mounted) {
//       setState(fn);
//     }
//   }
//
//   // ✅ FIX #2: Safe timer with disposed check
//   void _startTimer() {
//     if (_isDisposed) return;
//
//     _timer?.cancel();
//     _seconds = 30;
//
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (_isDisposed || !mounted) {
//         timer.cancel();
//         return;
//       }
//
//       if (_seconds == 0) {
//         timer.cancel();
//       } else {
//         _safeSetState(() => _seconds--);
//       }
//     });
//   }
//
//   // ✅ FIX #3: Safe OTP change with provider error handling
//   void _onOtpChange() {
//     if (_isDisposed || !mounted) return;
//
//     final otp = _controllers.map((e) => e.text).join();
//
//     // Notify parent
//     widget.onChanged(otp);
//
//     // Safe provider update
//     try {
//       final provider = context.read<SignupProvider>();
//       provider.setOtp(otp);
//     } catch (e) {
//       debugPrint("❌ Provider error in OTP: $e");
//     }
//
//     final isValid = otp.length == 6;
//     widget.onValidationChanged(isValid);
//   }
//
//   // ✅ FIX #4: Safe focus request with disposed check
//   void _onOtpBoxChanged(String value, int index) {
//     if (_isDisposed || !mounted) return;
//
//     if (value.isNotEmpty && index < 5) {
//       try {
//         _focusNodes[index + 1].requestFocus();
//       } catch (e) {
//         debugPrint("❌ Focus error: $e");
//       }
//     }
//     if (value.isEmpty && index > 0) {
//       try {
//         _focusNodes[index - 1].requestFocus();
//       } catch (e) {
//         debugPrint("❌ Focus error: $e");
//       }
//     }
//     _onOtpChange();
//   }
//
//   // ✅ FIX #5: Safe resend handler
//   void _handleResend() {
//     if (_isDisposed || !mounted) return;
//     if (_seconds == 0 && !_isProcessing) {
//       _isProcessing = true;
//       _startTimer();
//       // Clear all OTP fields
//       for (var c in _controllers) {
//         c.clear();
//       }
//       _focusNodes.first.requestFocus();
//       _onOtpChange();
//       Future.delayed(const Duration(milliseconds: 500), () {
//         if (!_isDisposed && mounted) {
//           _isProcessing = false;
//         }
//       });
//     }
//   }
//
//   Widget _otpBox(int index) {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
//     return SizedBox(
//       width: 50.w,
//       height: 55.h,
//       child: TextField(
//         controller: _controllers[index],
//         focusNode: _focusNodes[index],
//         keyboardType: TextInputType.number,
//         textAlign: TextAlign.center,
//         textAlignVertical: TextAlignVertical.center,
//         style: TextStyle(
//           fontSize: 20.sp,
//           fontWeight: FontWeight.w600,
//           color: AppColors.textPrimaryDynamic(context),
//         ),
//         maxLength: 1,
//         inputFormatters: [
//           FilteringTextInputFormatter.digitsOnly, // ✅ FIX #6: Only digits allowed
//         ],
//         decoration: InputDecoration(
//           counterText: "",
//           hintText: "0",
//           hintStyle: TextStyle(
//             fontSize: 20.sp,
//             fontWeight: FontWeight.w500,
//             color: AppColors.textSecondaryDynamic(context),
//           ),
//           filled: true,
//           fillColor: AppColors.inputFieldBgDynamic(context),
//           contentPadding: EdgeInsets.zero,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12.r),
//             borderSide: BorderSide(
//               color: AppColors.borderDynamic(context),
//               width: 0,
//             ),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12.r),
//             borderSide: BorderSide(
//               color: AppColors.borderDynamic(context),
//               width: 0,
//             ),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12.r),
//             borderSide: const BorderSide(
//               color: AppColors.primary,
//               width: 1.5,
//             ),
//           ),
//         ),
//         onChanged: (value) => _onOtpBoxChanged(value, index),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_isDisposed) return const SizedBox();
//
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "Enter OTP Code",
//           style: TextStyle(
//             fontSize: 20.sp,
//             fontWeight: FontWeight.w600,
//             color: AppColors.textPrimaryDynamic(context),
//           ),
//         ),
//         SizedBox(height: 20.h),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: List.generate(6, (index) => _otpBox(index)),
//         ),
//         SizedBox(height: 20.h),
//         Row(
//           children: [
//             Text(
//               "Didn't Receive Code? ",
//               style: TextStyle(
//                 fontSize: 14.sp,
//                 color: AppColors.textSecondaryDynamic(context),
//               ),
//             ),
//             GestureDetector(
//               onTap: _handleResend,
//               child: Text(
//                 _seconds == 0 ? "Resend" : "0:${_seconds.toString().padLeft(2, '0')}",
//                 style: TextStyle(
//                   color: AppColors.primary,
//                   fontWeight: FontWeight.w600,
//                   fontSize: 14.sp,
//                 ),
//               ),
//             )
//           ],
//         )
//       ],
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/provider/signUp_provider.dart';

class StepOtp extends StatefulWidget {
  final Function(String) onChanged;
  final Function(bool) onValidationChanged;

  const StepOtp({
    super.key,
    required this.onChanged,
    required this.onValidationChanged,
  });

  @override
  State<StepOtp> createState() => _StepOtpState();
}

class _StepOtpState extends State<StepOtp> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  int _seconds = 30;
  Timer? _timer;
  bool _isDisposed = false;
  bool _isProcessing = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(6, (_) => TextEditingController());
    _focusNodes = List.generate(6, (_) => FocusNode());
    _startTimer();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _safeSetState(VoidCallback fn) {
    if (!_isDisposed && mounted) {
      setState(fn);
    }
  }

  void _startTimer() {
    if (_isDisposed) return;

    _timer?.cancel();
    _seconds = 30;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isDisposed || !mounted) {
        timer.cancel();
        return;
      }

      if (_seconds == 0) {
        timer.cancel();
      } else {
        _safeSetState(() => _seconds--);
      }
    });
  }

  void _onOtpChange() {
    if (_isDisposed || !mounted) return;

    final otp = _controllers.map((e) => e.text).join();

    if (_errorMessage.isNotEmpty) {
      _safeSetState(() => _errorMessage = '');
    }

    widget.onChanged(otp);

    try {
      final provider = context.read<SignupProvider>();
      provider.setOtp(otp);
    } catch (e) {
      debugPrint("❌ Provider error in OTP: $e");
    }

    final isValid = otp.length == 6;
    widget.onValidationChanged(isValid);
  }

  void _onOtpBoxChanged(String value, int index) {
    if (_isDisposed || !mounted) return;

    if (value.isNotEmpty && index < 5) {
      try {
        _focusNodes[index + 1].requestFocus();
      } catch (e) {
        debugPrint("❌ Focus error: $e");
      }
    }
    if (value.isEmpty && index > 0) {
      try {
        _focusNodes[index - 1].requestFocus();
      } catch (e) {
        debugPrint("❌ Focus error: $e");
      }
    }
    _onOtpChange();
  }

  Future<void> _handleResend() async {
    if (_isDisposed || !mounted) return;

    if (_seconds == 0 && !_isProcessing) {
      _isProcessing = true;

      try {
        final provider = context.read<SignupProvider>();

        final success = await provider.sendOtp();

        if (mounted && !_isDisposed) {
          if (success) {
            _startTimer();
            for (var c in _controllers) {
              c.clear();
            }
            _focusNodes.first.requestFocus();
            _onOtpChange();
            _safeSetState(() => _errorMessage = '');

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('OTP resent successfully'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to resend OTP. Please try again.'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      } catch (e) {
        debugPrint("❌ Resend error: $e");
        if (mounted && !_isDisposed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } finally {
        if (mounted && !_isDisposed) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (!_isDisposed && mounted) {
              _isProcessing = false;
            }
          });
        }
      }
    }
  }

  void _clearOtpFields() {
    for (var c in _controllers) {
      c.clear();
    }
    _focusNodes.first.requestFocus();
    _onOtpChange();
  }

  Widget _otpBox(int index) {
    return SizedBox(
      width: 50.w,
      height: 55.h,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.center,
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryDynamic(context),
        ),
        maxLength: 1,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: InputDecoration(
          counterText: "",
          hintText: "0",
          hintStyle: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondaryDynamic(context),
          ),
          filled: true,
          fillColor: AppColors.inputFieldBgDynamic(context),
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: _errorMessage.isNotEmpty ? Colors.red : AppColors.borderDynamic(context),
              width: 0,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: _errorMessage.isNotEmpty ? Colors.red : AppColors.borderDynamic(context),
              width: 0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 1.5,
            ),
          ),
        ),
        onChanged: (value) => _onOtpBoxChanged(value, index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isDisposed) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Enter OTP Code",
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryDynamic(context),
          ),
        ),
        SizedBox(height: 20.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) => _otpBox(index)),
        ),
        if (_errorMessage.isNotEmpty) ...[
          SizedBox(height: 12.h),
          Text(
            _errorMessage,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        SizedBox(height: 20.h),
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
              onTap: _isProcessing ? null : _handleResend,
              child: Text(
                _seconds == 0 ? "Resend" : "0:${_seconds.toString().padLeft(2, '0')}",
                style: TextStyle(
                  color: _isProcessing ? Colors.grey : AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                ),
              ),
            )
          ],
        ),
      ],
    );
  }
}