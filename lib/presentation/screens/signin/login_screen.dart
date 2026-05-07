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
import '../../../data/provider/login_provider.dart';
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

    if (_isDisposed || !mounted) return;

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

    final provider = context.read<AuthProvider>();

    final result = await provider.sendOtp(fullPhone);

    if (_isDisposed || !mounted) return;

    if (result["success"]) {

      _navigateToOtp(fullPhone);

    } else {

      CustomSnackBar.showError(
        context,
        message: result["message"],
        duration: const Duration(seconds: 3),
      );
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
    final loginProvider = context.watch<LoginProvider>();

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
                    title: "Continue",
                    onPressed: loginProvider.isLoading ? null : _handleContinue,
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
