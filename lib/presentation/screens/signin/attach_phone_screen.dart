import 'dart:async';
import 'package:betrade/presentation/screens/main_screen.dart';
import 'package:betrade/presentation/widget/purple_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_style.dart';
import '../../../data/model/country_model.dart';
import '../../../data/provider/country_provider.dart';
import '../../../data/provider/signin_provider.dart';
import '../../widget/customSnackBar.dart';
import 'country_picker_sheet.dart';

/// Screen shown after a NEW user completes "Continue with Google" but has no
/// phone on file. A single [StatefulWidget] drives a two-step flow via the
/// internal [_step] flag (1 = phone entry, 2 = OTP entry):
///   1. Collect + submit a phone number   → AuthProvider.attachPhone
///   2. Verify the 6-digit OTP             → AuthProvider.verifyAttachPhone
/// On a verified OTP the user lands on [MainScreen] with the back stack wiped.
class AttachPhoneScreen extends StatefulWidget {
  final String? email;
  const AttachPhoneScreen({super.key, this.email});

  @override
  State<AttachPhoneScreen> createState() => _AttachPhoneScreenState();
}

class _AttachPhoneScreenState extends State<AttachPhoneScreen> {
  // 1 = phone entry, 2 = OTP entry.
  int _step = 1;

  // --- Step 1 (phone) state ---
  late TextEditingController _phoneController;
  CountryModel? _selectedCountry;
  bool _isSubmittingPhone = false;
  // Persistent inline error chip for a failed attach attempt (mirrors the
  // login_screen pattern). Cleared when the user edits the number or a send
  // succeeds. Surfaced alongside a transient snackbar.
  String? _lastSendError;

  // --- Step 2 (OTP) state ---
  final int otpLength = 6;
  late List<TextEditingController> _otpControllers;
  late List<FocusNode> _otpFocusNodes;
  bool _isVerifying = false;
  bool _isResending = false;
  int _secondsRemaining = 30;
  bool _canResend = false;
  Timer? _timer;

  // The full phone (country code + number) confirmed in step 1; reused by the
  // OTP verify + resend calls so the user can't desync the two steps.
  String _fullPhone = "";

  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _otpControllers = List.generate(otpLength, (_) => TextEditingController());
    _otpFocusNodes = List.generate(otpLength, (_) => FocusNode());
    _setDefaultCountry();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _timer?.cancel();
    _phoneController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Shared helpers
  // ---------------------------------------------------------------------------

  Map<String, dynamic> _safeParseResult(dynamic result) {
    if (result is Map<String, dynamic>) {
      // Contract: attachPhone / verifyAttachPhone return {success, message}.
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

  // ---------------------------------------------------------------------------
  // Step 1 — phone entry
  // ---------------------------------------------------------------------------

  Future<void> _setDefaultCountry() async {
    if (_isDisposed) return;
    try {
      final provider = Provider.of<CountryProvider>(context, listen: false);
      await provider.fetchCountries();

      if (_isDisposed || !mounted) return;

      if (provider.countries.isNotEmpty) {
        setState(() {
          _selectedCountry = provider.countries.first;
        });
      }
    } catch (e) {
      debugPrint("Country load error: $e");
    }
  }

  Future<void> _openCountryPicker() async {
    if (_isDisposed || !mounted) return;
    try {
      final result = await showModalBottomSheet<CountryModel>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return ChangeNotifierProvider.value(
            value: Provider.of<CountryProvider>(context, listen: false),
            child: const CountryPickerSheet(),
          );
        },
      );

      if (_isDisposed || !mounted) return;

      if (result != null) {
        setState(() {
          _selectedCountry = result;
        });
      }
    } catch (e) {
      debugPrint("Country picker error: $e");
    }
  }

  bool _isValidPhoneNumber() {
    final phone = _phoneController.text.trim();
    return phone.isNotEmpty && phone.length >= 8;
  }

  /// Submit the phone number. On success advance to the OTP step and start the
  /// 30 s resend cooldown; on failure surface a snackbar + persistent chip and
  /// stay on step 1 so the user can correct the number.
  Future<void> _handleContinue() async {
    // Synchronous re-entry guard: a rapid double-tap can fire this twice
    // before the loading flag propagates through a setState frame.
    if (_isDisposed || !mounted || _isSubmittingPhone) return;

    if (!_isValidPhoneNumber()) {
      _showMessage("Enter valid phone number");
      return;
    }

    if (_selectedCountry == null) {
      _showMessage("Please select country");
      return;
    }

    final fullPhone =
        "${_selectedCountry!.phoneCode}${_phoneController.text.trim()}";

    setState(() => _isSubmittingPhone = true);
    try {
      final provider = context.read<AuthProvider>();
      final result = await provider.attachPhone(fullPhone);

      if (_isDisposed || !mounted) return;

      final parsed = _safeParseResult(result);
      if (parsed['success'] == true) {
        _fullPhone = fullPhone;
        setState(() {
          _lastSendError = null;
          _step = 2;
        });
        _startTimer();
      } else {
        // Transient toast + persistent inline chip: the toast catches the eye,
        // the chip keeps a visible retry cue after it fades.
        _showMessage(parsed['message']);
        setState(() => _lastSendError = parsed['message']);
      }
    } catch (e) {
      debugPrint("Attach phone error: $e");
      if (_isDisposed || !mounted) return;
      const networkMsg = "Network error. Please check your connection.";
      _showMessage(networkMsg);
      setState(() => _lastSendError = networkMsg);
    } finally {
      if (!_isDisposed && mounted) {
        setState(() => _isSubmittingPhone = false);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Step 2 — OTP entry
  // ---------------------------------------------------------------------------

  void _startTimer() {
    if (_isDisposed) return;

    _timer?.cancel();
    _secondsRemaining = 30;
    _canResend = false;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isDisposed) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining == 0) {
        if (mounted && !_isDisposed) {
          setState(() => _canResend = true);
        }
        timer.cancel();
      } else {
        if (mounted && !_isDisposed) {
          setState(() => _secondsRemaining--);
        }
      }
    });
  }

  String _getOtp() => _otpControllers.map((e) => e.text).join();

  void _clearOtpFields() {
    for (final c in _otpControllers) {
      c.clear();
    }
    _otpFocusNodes.first.requestFocus();
  }

  void _onOtpChanged(String value, int index) {
    if (_isDisposed || !mounted) return;

    // PASTE: a full code lands in one cell when pasted from SMS. Distribute the
    // digits across all cells starting from index 0.
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      final paste =
          digits.length > otpLength ? digits.substring(0, otpLength) : digits;

      for (int i = 0; i < otpLength; i++) {
        _otpControllers[i].text = i < paste.length ? paste[i] : '';
      }

      if (paste.length >= otpLength) {
        FocusScope.of(context).unfocus();
      } else {
        FocusScope.of(context).requestFocus(_otpFocusNodes[paste.length]);
      }
      return;
    }

    // SINGLE-CHAR TYPING: advance / retreat focus per cell.
    if (value.isNotEmpty) {
      if (index < otpLength - 1) {
        FocusScope.of(context).requestFocus(_otpFocusNodes[index + 1]);
      } else {
        FocusScope.of(context).unfocus();
      }
    }
    if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_otpFocusNodes[index - 1]);
      _otpControllers[index - 1].selection = TextSelection.fromPosition(
        TextPosition(offset: _otpControllers[index - 1].text.length),
      );
    }
  }

  /// Verify the entered OTP. The button is tappable whenever a verify is not
  /// already in flight — we deliberately do NOT gate on an "isComplete" flag
  /// (a controller/state race left that stale, producing the "unresponsive
  /// button" bug). Length is validated here instead, with feedback on tap.
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
      final result = await provider.verifyAttachPhone(_fullPhone, otp);

      if (_isDisposed || !mounted) return;

      final parsed = _safeParseResult(result);
      if (parsed['success'] == true) {
        if (!mounted || _isDisposed) return;
        // New Google user just attached their phone → land on MainScreen with
        // the welcome/KYC popup enabled (same as the normal signup success
        // path). Without showWelcomePopup:true the "verify your details" popup
        // never appears (it's gated on showWelcomePopup && doc_upload_status==0),
        // so the user never reaches KYC. doc_upload_status is read from
        // LocalStorage inside MainScreen (saved by loginWithGoogle).
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const MainScreen(showWelcomePopup: true),
          ),
          (route) => false,
        );
      } else {
        // KEEP the entered digits — a one-digit typo is easy to fix without
        // re-entering all 6 cells.
        _showMessage(parsed['message']);
      }
    } catch (e) {
      debugPrint("Verify attach phone error: $e");
      if (_isDisposed || !mounted) return;
      _showMessage("Verification failed. Please try again.");
    } finally {
      if (!_isDisposed && mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  /// Resend the OTP. Inspects the returned {success}: only on success do we
  /// restart the cooldown + clear cells + show green. On failure we surface the
  /// error and KEEP resend tappable so the user can retry immediately.
  Future<void> _resendOtp() async {
    if (_isDisposed || !mounted || _isResending) return;

    setState(() => _isResending = true);
    try {
      final provider = context.read<AuthProvider>();
      final result = await provider.attachPhone(_fullPhone);

      if (_isDisposed || !mounted) return;

      final parsed = _safeParseResult(result);
      if (parsed['success'] == true) {
        _clearOtpFields();
        _startTimer();
        _showMessage("OTP resent successfully", isError: false);
      } else {
        _showMessage(parsed['message']);
      }
    } catch (e) {
      debugPrint("Resend attach OTP error: $e");
      if (_isDisposed || !mounted) return;
      _showMessage("Failed to resend OTP. Please try again.");
    } finally {
      if (!_isDisposed && mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  /// Return from the OTP step to the phone step so a wrong number can be fixed.
  void _backToPhoneStep() {
    if (_isDisposed || !mounted) return;
    _timer?.cancel();
    _clearOtpFields();
    setState(() {
      _step = 1;
      _canResend = false;
    });
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBackgroundDynamic(context),
      appBar: AppBar(
        backgroundColor: AppColors.cardBackgroundDynamic(context),
        elevation: 0,
        automaticallyImplyLeading: false,
        leadingWidth: 55.w,
        leading: Padding(
          padding: EdgeInsets.only(left: 12.w),
          child: _buildBackButton(),
        ),
        titleSpacing: 0,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: _step == 1 ? _buildPhoneStep() : _buildOtpStep(),
      ),
    );
  }

  Widget _buildBackButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(50.r),
      // From the OTP step the back arrow returns to phone entry; from phone
      // entry it pops the screen entirely.
      onTap: _step == 2 ? _backToPhoneStep : () => Navigator.maybePop(context),
      child: Container(
        height: 30.h,
        width: 30.w,
        decoration: BoxDecoration(
          color: AppColors.iconBgDynamic(context),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.arrow_back_ios_new,
          size: 18.sp,
          color: AppColors.textPrimaryDynamic(context),
        ),
      ),
    );
  }

  Widget _buildPhoneStep() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10.h),
        Text(
          "Add your phone number",
          style: AppTextStyle.heading.copyWith(
            color: AppColors.textPrimaryDynamic(context),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          "We'll send a verification code to secure your account",
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondaryDynamic(context),
          ),
        ),
        if (widget.email != null && widget.email!.isNotEmpty) ...[
          SizedBox(height: 6.h),
          Text(
            "Signed in as ${widget.email}",
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondaryDynamic(context),
            ),
          ),
        ],
        SizedBox(height: 24.h),
        Row(
          children: [
            GestureDetector(
              onTap: _openCountryPicker,
              child: Container(
                height: 50.h,
                padding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.inputFieldBgDynamic(context),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.borderDynamic(context),
                  ),
                ),
                child: Row(
                  children: [
                    _selectedCountry == null
                        ? SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : ClipOval(
                            child: Image.network(
                              _selectedCountry!.flag,
                              width: 23.4.w,
                              height: 23.4.h,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.flag,
                                size: 16.sp,
                              ),
                            ),
                          ),
                    SizedBox(width: 5.w),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 18.sp,
                      color: isDarkMode ? Colors.grey.shade400 : Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Container(
                height: 50.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  border: _lastSendError != null
                      ? Border.all(
                          color: AppColors.errorFgDynamic(context),
                          width: 1,
                        )
                      : null,
                ),
                child: TextField(
                  controller: _phoneController,
                  cursorColor: AppColors.primary,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  style: TextStyle(
                    color: AppColors.textPrimaryDynamic(context),
                  ),
                  // Clear the persistent error chip the moment the user starts
                  // editing the number, so it doesn't linger after a fix.
                  onChanged: (_) {
                    if (_lastSendError != null) {
                      setState(() => _lastSendError = null);
                    }
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.inputFieldBgDynamic(context),
                    counterText: "",
                    hintText: "000 000 0000",
                    hintStyle: TextStyle(
                      color: isDarkMode ? Colors.grey.shade500 : Colors.grey,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 15.w,
                      vertical: 14.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: AppColors.borderDynamic(context),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: AppColors.borderDynamic(context),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_lastSendError != null) ...[
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColors.errorBgDynamic(context),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: AppColors.errorBorderDynamic(context),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 18.sp,
                  color: AppColors.errorFgDynamic(context),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    _lastSendError!,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.errorFgDynamic(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const Spacer(),
        _isSubmittingPhone
            ? Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              )
            : Button(
                title: _lastSendError != null ? "Try again" : "Continue",
                onPressed: _handleContinue,
              ),
        SizedBox(height: 20.h),
      ],
    );
  }

  Widget _buildOtpStep() {
    // The button is tappable whenever a verify isn't already in flight. We
    // intentionally drop any "isComplete" gate here — a controller/state race
    // could leave it stale even when all 6 cells visibly have digits, the
    // "button not responsive" bug. `_verifyOtp` validates length and shows
    // "Please enter complete OTP" when fewer than 6 digits are present.
    final canTapVerify = !_isVerifying && !_isDisposed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10.h),
        Text(
          "Enter OTP Code",
          style: AppTextStyle.heading.copyWith(
            color: AppColors.textPrimaryDynamic(context),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          "Enter the 6-digit code sent to $_fullPhone",
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondaryDynamic(context),
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
              onTap: (_canResend && !_isResending) ? _resendOtp : null,
              child: Text(
                _canResend
                    ? "Resend"
                    : "0:${_secondsRemaining.toString().padLeft(2, '0')}",
                style: TextStyle(
                  color: _isResending ? Colors.grey : AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),
        // Lets a user who typed the wrong number jump straight back to step 1.
        GestureDetector(
          onTap: _backToPhoneStep,
          child: Text(
            "Change number",
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
            ),
          ),
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
                  onPressed: canTapVerify ? _verifyOtp : null,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "Verify",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
        SizedBox(height: 20.h),
      ],
    );
  }

  Widget _otpBox(int index) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: 50.w,
      height: 65.h,
      child: TextField(
        textInputAction: TextInputAction.next,
        autofocus: index == 0,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(otpLength),
        ],
        controller: _otpControllers[index],
        focusNode: _otpFocusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
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
          fillColor:
              isDarkMode ? const Color(0xFF2C2C2E) : Colors.grey.shade100,
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
}
