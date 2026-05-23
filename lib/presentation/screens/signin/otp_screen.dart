import 'dart:async';
import 'package:betrade/presentation/screens/main_screen.dart';
import 'package:betrade/presentation/widget/leading_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:pinput/pinput.dart'; // ✅ ADD THIS
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_style.dart';
import '../../../data/provider/signin_provider.dart';
import '../../../data/services/local_storage.dart';
import '../../widget/customSnackBar.dart';

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

  // ✅ Single controller for Pinput
  late TextEditingController _otpController;
  late FocusNode _focusNode;

  bool _isDisposed = false;
  bool _isVerifying = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
    _focusNode = FocusNode();
    _startTimer();

    // Listen to OTP changes
    _otpController.addListener(_checkOtpComplete);
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

    if (isError) {
      CustomSnackBar.showError(
        context,
        message: message,
        duration: const Duration(seconds: 3),
      );
    } else {
      CustomSnackBar.showSuccess(
        context,
        message: message,
        duration: const Duration(seconds: 3),
      );
    }
  }

  void _navigateToHome(int docUploadStatus) {
    if (_isDisposed || !mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isDisposed) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => MainScreen(
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

    final otp = _otpController.text.trim();
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
        // AuthProvider.verifyOtp wraps the service result inside `data`,
        // so doc_upload_status lives at result['data']['doc_upload_status'],
        // not at the top level. The service itself already wrote the value
        // to LocalStorage; we re-read it from the wrapped result for the
        // navigation argument only.
        final inner = result['data'];
        final rawStatus =
            inner is Map ? inner['doc_upload_status'] : null;
        int docUploadStatus = 0;
        if (rawStatus is int) {
          docUploadStatus = rawStatus;
        } else if (rawStatus is String) {
          docUploadStatus = int.tryParse(rawStatus) ?? 0;
        } else if (rawStatus is bool) {
          docUploadStatus = rawStatus ? 1 : 0;
        }
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
      await provider.sendLoginOtp(widget.phone);

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
    _otpController.clear();
    _focusNode.requestFocus();
    setState(() {
      isOtpComplete = false;
    });
  }

  void _checkOtpComplete() {
    if (_isDisposed) return;
    final otp = _otpController.text.trim();
    if (mounted) {
      setState(() {
        isOtpComplete = otp.length == otpLength;
      });
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _timer?.cancel();
    _otpController.removeListener(_checkOtpComplete);
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isButtonEnabled = isOtpComplete && !_isVerifying && !_isDisposed;

    // ✅ Pinput themes - matching your UI
    final defaultPinTheme = PinTheme(
      width: 50.w,
      height: 65.h,
      textStyle: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryDynamic(context),
      ),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2C2C2E) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: isDarkMode ? Colors.grey.shade700 : Colors.transparent,
        ),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        border: Border.all(
          color: AppColors.primary,
          width: 1.5,
        ),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        border: Border.all(
          color: isDarkMode ? Colors.grey.shade700 : Colors.transparent,
        ),
      ),
    );

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

            // ✅ PINPUT WIDGET - UI same as before
            Pinput(
              controller: _otpController,
              focusNode: _focusNode,
              length: otpLength,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: focusedPinTheme,
              submittedPinTheme: submittedPinTheme,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              hapticFeedbackType: HapticFeedbackType.lightImpact,
              closeKeyboardWhenCompleted: true,
              onCompleted: (pin) {
                // Auto verify jab 6 digit complete ho
                if (pin.length == otpLength && !_isVerifying) {
                  _verifyOtp();
                }
              },
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