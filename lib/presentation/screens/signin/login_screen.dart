import 'package:betrade/core/theme/app_text_style.dart';
import 'package:betrade/presentation/screens/main_screen.dart';
import 'package:betrade/presentation/screens/signin/attach_phone_screen.dart';
import 'package:betrade/presentation/screens/signin/otp_screen.dart';
import 'package:betrade/presentation/widget/purple_button.dart';
import 'package:betrade/presentation/widget/leading_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/model/country_model.dart';
import '../../../data/provider/country_provider.dart';
import '../../../data/provider/signin_provider.dart';
import '../../widget/customSnackBar.dart';
import 'country_picker_sheet.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _phoneController;
  CountryModel? _selectedCountry;
  bool _isDisposed = false;
  bool _isLoading = false;
  // Holds the most recent "OTP send failed" message so the UI can show
  // it as a persistent inline chip below the phone input (not just a
  // transient snackbar). Cleared when the user edits the phone number
  // or when a subsequent send succeeds. See `_handleContinue`.
  String? _lastSendError;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _setDefaultCountry();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _phoneController.dispose();
    super.dispose();
  }

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
      debugPrint(" Country load error: $e");
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

  Map<String, dynamic> _safeParseResult(dynamic result) {
    if (result is Map<String, dynamic>) {
      // AuthProvider.sendLoginOtp returns {status, message}.
      // AuthProvider.verifyOtp returns {success, message, data}.
      // Accept either envelope so this helper is reusable across both flows.
      return {
        'success': result['status'] == true || result['success'] == true,
        'message': result['message']?.toString() ?? 'Something went wrong',
      };
    }
    return {
      'success': false,
      'message': 'Invalid response from server',
    };
  }

  void _navigateToOtp(String phone) {
    if (_isDisposed || !mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OTPScreen(phone: phone),
          ),
        );
      }
    });
  }

  Future<void> _handleContinue() async {
    // Synchronous re-entry guard: rapid double-tap can fire this method twice
    // before isLoading propagates through a setState frame. Bail immediately.
    if (_isDisposed || !mounted || _isLoading) return;

    if (!_isValidPhoneNumber()) {
      CustomSnackBar.showError(
        context,
        message: "Enter valid phone number",
        duration: const Duration(seconds: 3),
      );
      return;
    }

    if (_selectedCountry == null) {
      CustomSnackBar.showError(
        context,
        message: "Please select country",
        duration: const Duration(seconds: 3),
      );
      return;
    }

    final fullPhone =
        "${_selectedCountry!.phoneCode}${_phoneController.text.trim()}";

    setState(() => _isLoading = true);
    try {
      final provider = context.read<AuthProvider>();
      final result = await provider.sendLoginOtp(fullPhone);

      if (_isDisposed || !mounted) return;

      final parsed = _safeParseResult(result);
      if (parsed['success'] == true) {
        // Clear any stale error from a previous failed attempt before
        // navigating away.
        if (_lastSendError != null) {
          setState(() => _lastSendError = null);
        }
        _navigateToOtp(fullPhone);
      } else {
        // Both surface the transient toast AND set the persistent inline
        // chip. The toast catches the eye; the chip ensures the failure
        // doesn't disappear after 3 s, which left the user feeling there
        // was no retry path. Button label flips to "Try again" via build().
        CustomSnackBar.showError(
          context,
          message: parsed['message'],
          duration: const Duration(seconds: 3),
        );
        setState(() => _lastSendError = parsed['message']);
      }
    } catch (e) {
      // Network failure / DNS / DioException — surface a user-friendly message
      // rather than leaking the raw exception text.
      debugPrint("Login error: $e");
      if (_isDisposed || !mounted) return;
      const networkMsg = "Network error. Please check your connection.";
      CustomSnackBar.showError(
        context,
        message: networkMsg,
        duration: const Duration(seconds: 3),
      );
      setState(() => _lastSendError = networkMsg);
    } finally {
      if (!_isDisposed && mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Continue-with-Apple entry point for the Login screen.
  ///
  /// Shares the `_isLoading` flag with the OTP flow so the screen can't
  /// fire both in parallel. On success we route to MainScreen the same
  /// way OTPScreen does on a verified login.
  Future<void> _handleAppleSignIn() async {
    if (_isDisposed || !mounted || _isLoading) return;

    setState(() => _isLoading = true);
    try {
      final result = await context.read<AuthProvider>().signInWithApple();

      if (_isDisposed || !mounted) return;

      // User dismissed the Apple sheet — keep the UI silent.
      if (result['cancelled'] == true) return;

      if (result['success'] == true) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
          (route) => false,
        );
      } else {
        CustomSnackBar.showError(
          context,
          message: (result['message'] as String?)?.isNotEmpty == true
              ? result['message']
              : "Sign-in failed. Please try again.",
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      debugPrint("Apple sign-in handler error: $e");
      if (_isDisposed || !mounted) return;
      CustomSnackBar.showError(
        context,
        message: "Something went wrong. Please try again.",
        duration: const Duration(seconds: 3),
      );
    } finally {
      if (!_isDisposed && mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Continue-with-Google on the Login screen — popup-only milestone.
  ///
  /// Opens the Google account chooser; on a successful pick we just confirm
  /// which account was selected (no navigation/backend yet — that's pending
  /// the senior's decision). Shares [_isLoading] with the OTP/Apple flows so
  /// only one can run at a time. A user-cancelled chooser stays silent.
  Future<void> _handleGoogleSignIn() async {
    if (_isDisposed || !mounted || _isLoading) return;

    setState(() => _isLoading = true);
    try {
      final result = await context.read<AuthProvider>().signInWithGoogle();

      if (_isDisposed || !mounted) return;

      // User dismissed the chooser — keep the UI silent.
      if (result['cancelled'] == true) return;

      if (result['success'] == true) {
        if (_isDisposed || !mounted) return;
        if (result['needs_phone'] == true) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AttachPhoneScreen(
                email: result['email'] as String?,
              ),
            ),
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainScreen()),
            (route) => false,
          );
        }
      } else {
        CustomSnackBar.showError(
          context,
          message: (result['message'] as String?)?.isNotEmpty == true
              ? result['message']
              : "Sign-in failed. Please try again.",
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      debugPrint("Google sign-in handler error: $e");
      if (_isDisposed || !mounted) return;
      CustomSnackBar.showError(
        context,
        message: "Something went wrong. Please try again.",
        duration: const Duration(seconds: 3),
      );
    } finally {
      if (!_isDisposed && mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // void _showSnackBar(String message) {
  //   if (_isDisposed || !mounted) return;
  //   final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  //   CustomSnackBar.showError(
  //     context,
  //     message: message,
  //     duration: const Duration(seconds: 3),
  //   );
  // }

  Widget _safeImage(String path,
      {double? height, double? width, Color? color}) {
    if (path.isEmpty) return SizedBox(height: height);

    return Image.asset(
      path,
      height: height,
      width: width,
      color: color,
      errorBuilder: (context, error, stackTrace) {
        debugPrint(" Missing asset: $path");
        return SizedBox(height: height, width: width);
      },
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
        automaticallyImplyLeading: false,
        leadingWidth: 55.w,
        leading: const Padding(
          padding: EdgeInsets.only(left: 12),
          child: LeadingIcon(),
        ),
        titleSpacing: 0,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.h),
            Text(
              "Enter Your Phone Number to Login",
              style: AppTextStyle.heading.copyWith(
                color: AppColors.textPrimaryDynamic(context),
              ),
            ),
            SizedBox(height: 20.h),
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
                          color:
                              isDarkMode ? Colors.grey.shade400 : Colors.grey,
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
                      // Clear the persistent error chip the moment the
                      // user starts editing the number. Without this the
                      // chip would stick around even after the user fixed
                      // the typo that caused the failure.
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
                          color:
                              isDarkMode ? Colors.grey.shade500 : Colors.grey,
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
            // Persistent inline error chip for failed send attempts.
            // Shown alongside the transient toast so the user keeps a
            // visible cue (and a clear retry CTA) after the toast fades.
            // Clears when the user edits the phone number or a send
            // succeeds — see `_handleContinue` + the phone TextField's
            // onChanged.
            if (_lastSendError != null) ...[
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 10.h,
                ),
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
            _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  )
                : Button(
                    // Flip the label to "Try again" after a failed send so
                    // the persistent chip + the button together make the
                    // retry intent obvious.
                    title:
                        _lastSendError != null ? "Try again" : "Continue",
                    onPressed: _handleContinue,
                  ),
            SizedBox(height: 15.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    height: 50.h,
                    margin: EdgeInsets.only(right: 5.w),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: AppColors.borderDynamic(context),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.r),
                        ),
                        backgroundColor:
                            AppColors.buttonSecondaryDynamic(context),
                      ),
                      onPressed: _isLoading ? null : _handleGoogleSignIn,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Continue with",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.textPrimaryDynamic(context),
                            ),
                          ),
                          SizedBox(width: 5.w),
                          _safeImage(
                            "assets/images/google.png",
                            height: 19.h,
                            width: 19.w,
                            color: isDarkMode ? Colors.white : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Apple button always visible. On Android the package
                // can't open the native sheet; the provider catches the
                // unsupported case and surfaces a friendly message.
                SizedBox(width: 10.w),
                Expanded(
                  child: SizedBox(
                    height: 50.h,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: AppColors.borderDynamic(context),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.r),
                        ),
                        backgroundColor:
                            AppColors.buttonSecondaryDynamic(context),
                      ),
                      onPressed: _isLoading ? null : _handleAppleSignIn,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Continue with",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.textPrimaryDynamic(context),
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Icon(
                            Icons.apple,
                            size: 24.h,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
