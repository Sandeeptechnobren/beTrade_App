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

      // Fast path: SplashScreen pre-warms countries (cache + network) so by
      // the time we mount here the provider usually has data. Read it
      // synchronously so the picker renders a flag immediately on first
      // paint instead of a spinner.
      if (provider.countries.isNotEmpty) {
        _selectedCountry =
            provider.selectedCountry ?? provider.countries.first;
      } else {
        // Cold path: cache was missing AND splash's network call hasn't
        // returned yet. Trigger our own fetch and await — same behaviour as
        // before this optimisation, but on a tiny minority of launches.
        await provider.fetchCountries();
        if (_isDisposed || !mounted) return;
        if (provider.countries.isNotEmpty) {
          _selectedCountry =
              provider.selectedCountry ?? provider.countries.first;
        }
      }

      if (mounted && !_isDisposed) {
        setState(() {});
      }
    } catch (e) {
      debugPrint("LoginScreen: country load error: $e");
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
        'success':
            result['status'] == true || result['success'] == true,
        'message':
            result['message']?.toString() ?? 'Something went wrong',
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
        _navigateToOtp(fullPhone);
      } else {
        CustomSnackBar.showError(
          context,
          message: parsed['message'],
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      // Network failure / DNS / DioException — surface a user-friendly message
      // rather than leaking the raw exception text.
      debugPrint("Login error: $e");
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

  // void _showSnackBar(String message) {
  //   if (_isDisposed || !mounted) return;
  //   final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  //   CustomSnackBar.showError(
  //     context,
  //     message: message,
  //     duration: const Duration(seconds: 3),
  //   );
  // }

  /// Country-flag bubble for the phone-input pill.
  ///
  /// States:
  ///   - country not yet resolved: small spinner so the layout doesn't jump
  ///   - flag URL present: network image inside a ClipOval, with both a
  ///     loadingBuilder (small spinner) and an errorBuilder (a Material
  ///     flag glyph) so the slot is never empty
  ///   - flag URL missing: fall back to the iso-code as a 2-letter pill
  Widget _buildFlag() {
    const double diameter = 24;
    final country = _selectedCountry;
    if (country == null) {
      return SizedBox(
        width: diameter.w,
        height: diameter.h,
        child: const Center(
          child: SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    final url = country.flag.trim();
    if (url.isEmpty) {
      // Last-resort fallback: 2-letter country mark on a coloured chip.
      return Container(
        width: diameter.w,
        height: diameter.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: Text(
          country.name.isNotEmpty
              ? country.name.substring(0, country.name.length >= 2 ? 2 : 1).toUpperCase()
              : "??",
          style: TextStyle(
            fontSize: 9.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      );
    }
    return ClipOval(
      child: Image.network(
        url,
        width: diameter.w,
        height: diameter.h,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return SizedBox(
            width: diameter.w,
            height: diameter.h,
            child: const Center(
              child: SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
        errorBuilder: (_, __, ___) => Container(
          width: diameter.w,
          height: diameter.h,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Colors.grey,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.flag, size: 14.sp, color: Colors.white),
        ),
      ),
    );
  }

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
            // ── Phone-number row (matches Figma) ─────────────────────
            // Two visually-separate rounded chips with a small gap:
            //   - LEFT: country-picker chip — flag + chevron
            //   - RIGHT: phone-input chip — TextField with placeholder
            // Both have the same height + light-grey fill + soft rounded
            // corners. The previous version was a single unified pill —
            // Figma actually shows two distinct cards.
            Row(
              children: [
                // Country-picker chip
                InkWell(
                  onTap: _openCountryPicker,
                  borderRadius: BorderRadius.circular(14.r),
                  child: Container(
                    height: 56.h,
                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                    decoration: BoxDecoration(
                      color: AppColors.inputFieldBgDynamic(context),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildFlag(),
                        SizedBox(width: 8.w),
                        Icon(
                          Icons.keyboard_arrow_down,
                          size: 20.sp,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                // Phone-input chip
                Expanded(
                  child: Container(
                    height: 56.h,
                    alignment: Alignment.center, // centers the TextField vertically
                    decoration: BoxDecoration(
                      color: AppColors.inputFieldBgDynamic(context),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    // The canonical Flutter recipe for vertically centering
                    // a TextField inside a fixed-height Container is the
                    // combination below — Container.alignment +
                    // textAlignVertical + isCollapsed:true. Any of the
                    // three alone leaves residual top/bottom space because
                    // InputDecorator reserves room for label/helper/counter
                    // even when none are configured. isCollapsed strips
                    // that reservation; the alignment + textAlignVertical
                    // then anchor the glyph baseline to the chip's centre.
                    child: TextField(
                      controller: _phoneController,
                      cursorColor: AppColors.primary,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(
                        color: AppColors.textPrimaryDynamic(context),
                        fontSize: 16.sp,
                      ),
                      decoration: InputDecoration(
                        isCollapsed: true,
                        counterText: "",
                        hintText: "000 000 0000",
                        // QA #14 — placeholder used to read `Colors.grey`
                        // (`#9E9E9E`) which felt too dark vs the input bg.
                        // Lightened to shade400 (`#BDBDBD`) in light mode,
                        // shade600 in dark mode for the same relative
                        // contrast.
                        hintStyle: TextStyle(
                          fontSize: 16.sp,
                          color: isDarkMode
                              ? Colors.grey.shade600
                              : Colors.grey.shade400,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 18.w,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
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
                    title: "Continue",
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
                      onPressed: () {},
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
                          // Google logo is multi-coloured — do NOT pass
                          // `color:` here or the tint flattens it into a
                          // monochrome blob and the brand becomes
                          // unrecognisable.
                          _safeImage(
                            "assets/images/google.png",
                            height: 19.h,
                            width: 19.w,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Container(
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
                      onPressed: () {},
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
