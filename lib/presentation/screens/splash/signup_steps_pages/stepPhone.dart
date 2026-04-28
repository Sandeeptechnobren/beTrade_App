import 'package:betrade/core/theme/app_colors.dart';
import 'package:betrade/core/theme/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/validators/phone_number_validator.dart';
import '../../../../data/model/country_model.dart';
import '../../../../data/provider/country_provider.dart';
import '../../../../data/provider/signUp_provider.dart';
import '../../../widget/country_picker.dart';

class StepPhone extends StatefulWidget {
  final Function(String) onChanged;
  final Function(bool) onValidationChanged;

  const StepPhone({
    super.key,
    required this.onChanged,
    required this.onValidationChanged,
  });

  @override
  State<StepPhone> createState() => _StepPhoneState();
}

class _StepPhoneState extends State<StepPhone> {
  final _formKey = GlobalKey<FormState>();
  String? _phoneError;
  String _phoneNumber = "";
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _loadCountries() {
    if (_isDisposed) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isDisposed || !mounted) return;

      try {
        final provider = context.read<CountryProvider>();
        if (!provider.isLoading && !provider.isFetched) {
          provider.fetchCountries();
        }
      } catch (e) {
        debugPrint("Country provider error: $e");
      }
    });
  }

  void _safeSetState(VoidCallback fn) {
    if (!_isDisposed && mounted) {
      setState(fn);
    }
  }

  void validateAndNotify(String value) {
    if (_isDisposed || !mounted) return;

    try {
      final countryProvider = context.read<CountryProvider>();
      final signupProvider = context.read<SignupProvider>();
      final country = countryProvider.selectedCountry;
      final code = country?.phoneCode ?? "";
      final cleanValue = value.replaceAll(" ", "");
      final fullPhone = "$code$cleanValue";
      widget.onChanged(fullPhone);
      signupProvider.setPhone(fullPhone);

      String? error;
      if (cleanValue.isEmpty) {
        error = "Phone number required";
      } else {
        error = Validators.validatePhone(
          cleanValue,
          countryCode: country?.phoneCode,
        );
      }

      _safeSetState(() {
        _phoneError = error;
        _phoneNumber = value;
      });

      final isValid = error == null && cleanValue.isNotEmpty;
      widget.onValidationChanged(isValid);
    } catch (e) {
      debugPrint("Validation error: $e");
      _safeSetState(() {
        _phoneError = "Validation error";
      });
      widget.onValidationChanged(false);
    }
  }

  void _showCountryPicker() async {
    if (_isDisposed || !mounted) return;

    try {
      await showCountryPicker(context);
      if (!_isDisposed && mounted && _phoneNumber.isNotEmpty) {
        validateAndNotify(_phoneNumber);
      }
    } catch (e) {
      debugPrint("Country picker error: $e");
    }
  }

  String _getHintText() {
    if (_phoneError != null) return _phoneError!;
    return "000 000 0000";
  }

  Color _getHintColor() {
    if (_phoneError != null) return Colors.red;
    return AppColors.textSecondaryDynamic(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_isDisposed) return const SizedBox();

    CountryModel? country;
    try {
      country = context.select<CountryProvider, CountryModel?>(
        (p) => p.selectedCountry,
      );
    } catch (e) {
      debugPrint("Provider select error: $e");
      country = null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "What's Your Phone Number?",
          style: AppTextStyle.heading.copyWith(
            color: AppColors.textPrimaryDynamic(context),
          ),
        ),
        SizedBox(height: 20.h),
        Row(
          children: [
            // Country Picker Button
            GestureDetector(
              onTap: _showCountryPicker,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                height: 50.h,
                decoration: BoxDecoration(
                  color: AppColors.inputFieldBgDynamic(context),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.borderDynamic(context),
                  ),
                ),
                child: Row(
                  children: [
                    country != null
                        ? ClipOval(
                            child: Image.network(
                              country.flag,
                              width: 23.4.w,
                              height: 23.4.h,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.flag,
                                size: 16.sp,
                              ),
                            ),
                          )
                        : SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                    SizedBox(width: 5.w),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 18.sp,
                      color: AppColors.textSecondaryDynamic(context),
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
                child: TextFormField(
                  keyboardType: TextInputType.phone,
                  style: TextStyle(
                    color: AppColors.textPrimaryDynamic(context),
                  ),
                  onChanged: (value) {
                    if (!_isDisposed && mounted) {
                      validateAndNotify(value);
                    }
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.inputFieldBgDynamic(context),
                    counterText: "",
                    hintText: _getHintText(),
                    hintStyle: TextStyle(
                      color: _getHintColor(),
                      fontSize: 16.sp,
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
                        width: 1.5,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(
                        color: Colors.red,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_phoneError != null) ...[
          SizedBox(height: 8.h),
          Text(
            _phoneError ?? "",
            style: TextStyle(
              color: Colors.red,
              fontSize: 12.sp,
            ),
          ),
        ],
      ],
    );
  }
}
