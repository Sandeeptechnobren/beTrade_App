import 'package:betrade/core/theme/app_text_style.dart';
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

/// Post-Google sign-in phone capture.
///
/// Reached when `/login-with-google` returned `needs_phone: true` — i.e. a
/// brand-new Google user without an associated phone number, OR an existing
/// Google-linked user that was migrated from an OTP-only account that never
/// recorded a phone.
///
/// Flow on this screen:
///   country picker + phone input → `_continue()` → backend `/profile/attach-phone`
///   triggers WhApi OTP → push `OTPScreen(mode: OtpScreenMode.attachPhone)`.
///
/// The Sanctum token from the Google login is already on the Dio header by the
/// time this screen mounts, so all calls from here on use it.
class AttachPhoneScreen extends StatefulWidget {
  const AttachPhoneScreen({super.key});

  @override
  State<AttachPhoneScreen> createState() => _AttachPhoneScreenState();
}

class _AttachPhoneScreenState extends State<AttachPhoneScreen> {
  late TextEditingController _phoneController;
  CountryModel? _selectedCountry;
  bool _isDisposed = false;
  bool _isLoading = false;

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
        setState(() => _selectedCountry = provider.countries.first);
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
        setState(() => _selectedCountry = result);
      }
    } catch (e) {
      debugPrint("Country picker error: $e");
    }
  }

  bool _isValidPhoneNumber() {
    final phone = _phoneController.text.trim();
    return phone.isNotEmpty && phone.length >= 8;
  }

  Future<void> _continue() async {
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
      final result = await provider.sendAttachPhoneOtp(fullPhone);

      if (_isDisposed || !mounted) return;

      if (result["success"] == true) {
        // Hand off to OTP screen in attach-phone mode. We use pushReplacement
        // so a back-button press from the OTP screen returns the user to the
        // app entry (not back to a stale phone-input view).
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OTPScreen(
              phone: fullPhone,
              mode: OtpScreenMode.attachPhone,
            ),
          ),
        );
      } else {
        CustomSnackBar.showError(
          context,
          message: result["message"]?.toString() ?? "Could not send OTP",
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      debugPrint("Attach-phone error: $e");
      if (_isDisposed || !mounted) return;
      CustomSnackBar.showError(
        context,
        message: "Network error. Please check your connection.",
        duration: const Duration(seconds: 3),
      );
    } finally {
      if (!_isDisposed && mounted) {
        setState(() => _isLoading = false);
      }
    }
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
              "Add your phone number",
              style: AppTextStyle.heading.copyWith(
                color: AppColors.textPrimaryDynamic(context),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "We'll send a one-time code to verify it. Your phone keeps you "
              "signed in if you ever lose access to your Google account.",
              style: TextStyle(
                fontSize: 13.sp,
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                GestureDetector(
                  onTap: _openCountryPicker,
                  child: Container(
                    height: 50.h,
                    padding: EdgeInsets.symmetric(
                        horizontal: 12.w, vertical: 12.h),
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
                    ),
                    child: TextField(
                      controller: _phoneController,
                      cursorColor: AppColors.primary,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      style: TextStyle(
                        color: AppColors.textPrimaryDynamic(context),
                      ),
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
            const Spacer(),
            _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  )
                : Button(
                    title: "Send code",
                    onPressed: _continue,
                  ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
