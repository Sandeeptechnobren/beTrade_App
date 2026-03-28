import 'package:betrade/presentation/screens/signin/otp_screen.dart';
import 'package:betrade/presentation/widget/purple_button.dart';
import 'package:betrade/presentation/widget/leading_icon.dart';
import 'package:betrade/provider/auth_provider.dart';
import 'package:betrade/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../data/model/country_model.dart';
import 'country_picker_sheet.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  Future<void> openCountryPicker(BuildContext context) async {
    final selectedCountry = await showModalBottomSheet<CountryModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CountryPickerSheet(),
    );
    if (selectedCountry != null) {
      onCountrySelected(selectedCountry);
    }
  }
  CountryModel selectedCountry = CountryModel(
    id: 0,
    name: "India",
    phoneCode: "+91",
    flag: "🇮🇳",
    currency: '',
  );
  void onCountrySelected(CountryModel country) {
    setState(() {
      selectedCountry = country;
    });
  }
  TextEditingController phoneController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: LeadingIcon(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.h),
            Text(
              "Enter Your Phone Number to Login",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 25.h),
            Row(
              children: [
                GestureDetector(
                  onTap: () => openCountryPicker(context),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 14.h,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Text(
                          selectedCountry.flag,
                          style: TextStyle(fontSize: 16.sp),
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          selectedCountry.phoneCode,
                          style: TextStyle(fontSize: 14.sp),
                        ),
                        SizedBox(width: 5.w),
                        Icon(
                          Icons.keyboard_arrow_down,
                          size: 18.sp,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: TextField(
                    controller: phoneController,
                    cursorColor: AppColors.primary,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    decoration: InputDecoration(
                      counterText: "",
                      hintText: "000 000 0000",
                      hintStyle: TextStyle(color: Colors.grey),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 15.w,
                        vertical: 14.h,
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
              ],
            ),
            const Spacer(),
            Consumer<AuthProvider>(
              builder: (context, provider, child) {
                return provider.isLoading
                    ? Center(child: CircularProgressIndicator())
                    : Button(
                        title: "Continue",
                        onPressed: () async {
                          if (phoneController.text.isEmpty ||
                              phoneController.text.length < 10) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Enter valid phone number"),
                              ),
                            );
                            return;
                          }
                          String fullPhone = "${selectedCountry.phoneCode}${phoneController.text.trim()}";
                          final result = await context
                              .read<AuthProvider>()
                              .sendOtp(fullPhone);
                          if (result['success']) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => OTPScreen(phone: fullPhone),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(result['message'])),
                            );
                          }
                        },
                      );
              },
            ),
            SizedBox(height: 15.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: 50.h,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                    ),
                    onPressed: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Continue with",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.black,
                          ),
                        ),
                        Image.asset(
                          "assets/images/google.png",
                          height: 30,
                          width: 30,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 50.h,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                    ),
                    onPressed: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Continue with",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.black,
                          ),
                        ),
                        Image.asset(
                          "assets/images/apple.png",
                          height: 30,
                          width: 30,
                        ),
                      ],
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
