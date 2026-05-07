import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../data/provider/signup_provider.dart';
import '../../../widget/customSnackBar.dart';

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

    // Error remove immediately when user starts editing
    if (_errorMessage.isNotEmpty) {
      _safeSetState(() {
        _errorMessage = '';
      });
    }

    // Forward focus when value entered
    if (value.isNotEmpty) {
      _controllers[index].text = value.substring(value.length - 1);
      _controllers[index].selection = TextSelection.fromPosition(
        const TextPosition(offset: 1),
      );

      if (index < 5) {
        FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
      } else {
        FocusScope.of(context).unfocus();
      }
    }

    if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
      _controllers[index - 1].selection = TextSelection.fromPosition(
        TextPosition(offset: _controllers[index - 1].text.length),
      );
    }
    _onOtpChange();
  }

  // void _onOtpBoxChanged(String value, int index) {
  //   if (_isDisposed || !mounted) return;
  //
  //   if (value.isNotEmpty && index < 5) {
  //     try {
  //       _focusNodes[index + 1].requestFocus();
  //     } catch (e) {
  //       debugPrint("❌ Focus error: $e");
  //     }
  //   }
  //   if (value.isEmpty && index > 0) {
  //     try {
  //       _focusNodes[index - 1].requestFocus();
  //     } catch (e) {
  //       debugPrint("❌ Focus error: $e");
  //     }
  //   }
  //   _onOtpChange();
  // }

  Future<void> _handleResend() async {
    if (_isDisposed || !mounted) return;

    if (_seconds == 0 && !_isProcessing) {
      _isProcessing = true;

      try {
        final provider = context.read<SignupProvider>();

        final result = await provider.sendOtp();

        if (mounted && !_isDisposed) {
          if (result["success"]) {
            _startTimer();
            for (var c in _controllers) {
              c.clear();
            }
            _focusNodes.first.requestFocus();
            _onOtpChange();
            _safeSetState(() => _errorMessage = '');

            CustomSnackBar.showSuccess(
              context,
              message: "OTP resent successfully",
              duration: const Duration(seconds: 3),
            );
          } else {
            CustomSnackBar.showError(
              context,
              message: "Failed to resend OTP. Please try again.",
              duration: const Duration(seconds: 3),
            );
          }
        }
      } catch (e) {
        debugPrint("❌ Resend error: $e");
        if (mounted && !_isDisposed) {
          CustomSnackBar.showError(
            context,
            message: 'Error: ${e.toString()}',
            duration: const Duration(seconds: 3),
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: 50.w,
      height: 65.h,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimaryDynamic(context),
        ),
        decoration: InputDecoration(
          hintText: "0",
          hintStyle: TextStyle(
            color: isDarkMode
                ? Colors.grey.shade600
                : Colors.grey,
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
              color: _errorMessage.isNotEmpty
                  ? Colors.red
                  : (isDarkMode
                  ? Colors.grey.shade700
                  : Colors.transparent),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 1.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1.5,
            ),
          ),
        ),
        onChanged: (value) => _onOtpBoxChanged(value, index),
      ),
    );
  }
  //
  // Widget _otpBox(int index) {
  //   return SizedBox(
  //     width: 55.w,
  //     height: 65.h,
  //     child: TextField(
  //       controller: _controllers[index],
  //       focusNode: _focusNodes[index],
  //       keyboardType: TextInputType.number,
  //       textAlign: TextAlign.center,
  //       textAlignVertical: TextAlignVertical.center,
  //       style: TextStyle(
  //         fontSize: 20.sp,
  //         fontWeight: FontWeight.w600,
  //         color: AppColors.textPrimaryDynamic(context),
  //       ),
  //       maxLength: 1,
  //       inputFormatters: [
  //         FilteringTextInputFormatter.digitsOnly,
  //       ],
  //       decoration: InputDecoration(
  //         counterText: "",
  //         hintText: "0",
  //         hintStyle: TextStyle(
  //           fontSize: 20.sp,
  //           fontWeight: FontWeight.w500,
  //           color: AppColors.textSecondaryDynamic(context),
  //         ),
  //         filled: true,
  //         fillColor: AppColors.inputFieldBgDynamic(context),
  //         contentPadding: EdgeInsets.zero,
  //         border: OutlineInputBorder(
  //           borderRadius: BorderRadius.circular(12.r),
  //           borderSide: BorderSide(
  //             color: _errorMessage.isNotEmpty ? Colors.red : AppColors.borderDynamic(context),
  //             width: 0,
  //           ),
  //         ),
  //         enabledBorder: OutlineInputBorder(
  //           borderRadius: BorderRadius.circular(12.r),
  //           borderSide: BorderSide(
  //             color: _errorMessage.isNotEmpty ? Colors.red : AppColors.borderDynamic(context),
  //             width: 0,
  //           ),
  //         ),
  //         focusedBorder: OutlineInputBorder(
  //           borderRadius: BorderRadius.circular(12.r),
  //           borderSide: const BorderSide(
  //             color: AppColors.primary,
  //             width: 1.5,
  //           ),
  //         ),
  //       ),
  //       onChanged: (value) => _onOtpBoxChanged(value, index),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    if (_isDisposed) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Enter OTP Code",
          style: AppTextStyle.heading.copyWith(
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
        SizedBox(height:10.h),
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