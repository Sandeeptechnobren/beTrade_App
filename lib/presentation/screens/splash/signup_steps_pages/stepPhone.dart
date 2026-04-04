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

  const StepPhone({super.key, required this.onChanged});

  @override
  State<StepPhone> createState() => _StepPhoneState();
}

class _StepPhoneState extends State<StepPhone> {
  final _formKey = GlobalKey<FormState>();
  String? phoneError;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = context.read<CountryProvider>();
      if (!provider.isLoading && provider.countries.isEmpty) {
        provider.fetchCountries();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final country = context.select<CountryProvider, CountryModel?>(
      (p) => p.selectedCountry,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("What’s Your Phone Number?", style: AppTextStyle.heading),
        SizedBox(height: 20.h),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                showCountryPicker(context);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                height: 50.h,
                decoration: BoxDecoration(
                  color: AppColors.inputFieldBg,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Text(country?.flag ?? "🇮🇳"),
                    SizedBox(width: 5.w),
                    const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                  ],
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Form(
                key: _formKey,
                child: Container(
                  height: 50.h,
                  decoration: BoxDecoration(
                    color: AppColors.inputFieldBg,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: TextFormField(
                    keyboardType: TextInputType.phone,
                    style: TextStyle(color: Colors.black),
                    onChanged: (value) {
                      final code = country?.phoneCode ?? "+91";
                      final cleanValue = value.replaceAll(" ", "");
                      final fullPhone = "$code$cleanValue";
                      widget.onChanged(fullPhone);
                      context.read<SignupProvider>().setPhone(fullPhone);
                      setState(() {
                        if (cleanValue.isEmpty) {
                          phoneError = "Phone number required";
                        } else {
                          phoneError = Validators.validatePhone(
                            cleanValue,
                            countryCode: country?.phoneCode,
                          );
                        }
                      });
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.inputFieldBg,
                      hintText: phoneError ?? "000 000 0000",
                      hintStyle: TextStyle(
                        color: phoneError != null ? Colors.red : Colors.grey,
                        fontSize: 16.sp,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
