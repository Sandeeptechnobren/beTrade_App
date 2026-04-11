// // // import 'package:betrade/core/theme/app_text_style.dart';
// // // import 'package:betrade/presentation/screens/signin/otp_screen.dart';
// // // import 'package:betrade/presentation/widget/purple_button.dart';
// // // import 'package:betrade/presentation/widget/leading_icon.dart';
// // // import 'package:betrade/provider/auth_provider.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:flutter_screenutil/flutter_screenutil.dart';
// // // import 'package:provider/provider.dart';
// // // import '../../../core/theme/app_colors.dart';
// // // import '../../../data/model/country_model.dart';
// // // import 'country_picker_sheet.dart';
// // //
// // // class LoginScreen extends StatefulWidget {
// // //   const LoginScreen({super.key});
// // //   @override
// // //   State<LoginScreen> createState() => _LoginScreenState();
// // // }
// // // class _LoginScreenState extends State<LoginScreen> {
// // //   Future<void> openCountryPicker(BuildContext context) async {
// // //     final selectedCountry = await showModalBottomSheet<CountryModel>(
// // //       context: context,
// // //       isScrollControlled: true,
// // //       backgroundColor: Colors.transparent,
// // //       builder: (_) => const CountryPickerSheet(),
// // //     );
// // //     if (selectedCountry != null) {
// // //       onCountrySelected(selectedCountry);
// // //     }
// // //   }
// // //   CountryModel selectedCountry = CountryModel(
// // //     id: 0,
// // //     name: "India",
// // //     phoneCode: "+91",
// // //     flag: "🇮🇳",
// // //     currency: '',
// // //   );
// // //   void onCountrySelected(CountryModel country) {
// // //     setState(() {
// // //       selectedCountry = country;
// // //     });
// // //   }
// // //   TextEditingController phoneController = TextEditingController();
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       backgroundColor: Colors.white,
// // //       appBar: AppBar(
// // //         backgroundColor: Colors.white,
// // //         elevation: 0,
// // //         automaticallyImplyLeading: false,
// // //         leading: Padding(
// // //           padding: const EdgeInsets.only(left: 12),
// // //           child: LeadingIcon(),
// // //         ),
// // //       ),
// // //       body: Padding(
// // //         padding: EdgeInsets.symmetric(horizontal: 20.w),
// // //         child: Column(
// // //           crossAxisAlignment: CrossAxisAlignment.start,
// // //           children: [
// // //             SizedBox(height: 10.h),
// // //             Text(
// // //               "Enter Your Phone Number to Login",
// // //               style:AppTextStyle.heading
// // //             ),
// // //             SizedBox(height: 20.h),
// // //             Row(
// // //               children: [
// // //                 GestureDetector(
// // //                   onTap: () => openCountryPicker(context),
// // //                   child: Container(
// // //                     padding: EdgeInsets.symmetric(horizontal: 10.w),
// // //                     height: 50.h,
// // //                     decoration: BoxDecoration(
// // //                       borderRadius: BorderRadius.circular(12.r),
// // //                       color:AppColors.inputFieldBg,
// // //                     ),
// // //                     child: Row(
// // //                       children: [
// // //                         Text(
// // //                           selectedCountry.flag,
// // //                           style: TextStyle(fontSize: 16.sp),
// // //                         ),
// // //                         SizedBox(width: 5.w),
// // //                         Icon(
// // //                           Icons.keyboard_arrow_down,
// // //                           size: 18.sp,
// // //                           color: Colors.grey,
// // //                         ),
// // //                       ],
// // //                     ),
// // //                   ),
// // //                 ),
// // //                 SizedBox(width: 10.w),
// // //                 Expanded(
// // //                   child:
// // //                   SizedBox(height: 50.h,
// // //                     child: TextField(
// // //                       controller: phoneController,
// // //                       cursorColor: AppColors.primary,
// // //                       keyboardType: TextInputType.phone,
// // //                       maxLength: 10,
// // //                       decoration: InputDecoration(
// // //                         filled: true,
// // //                         fillColor: AppColors.inputFieldBg,
// // //                         counterText: "",
// // //                         hintText: "000 000 0000",
// // //                         hintStyle: TextStyle(color: Colors.grey),
// // //                         contentPadding: EdgeInsets.symmetric(
// // //                           horizontal: 15.w,
// // //                           vertical: 14.h,
// // //                         ),
// // //                         border: OutlineInputBorder(
// // //                           borderRadius: BorderRadius.circular(12.r),
// // //                           borderSide: BorderSide(color: Colors.grey.shade300),
// // //                         ),
// // //                         enabledBorder: OutlineInputBorder(
// // //                           borderRadius: BorderRadius.circular(12.r),
// // //                           borderSide: BorderSide(color: Colors.grey.shade300),
// // //                         ),
// // //                         focusedBorder: OutlineInputBorder(
// // //                           borderRadius: BorderRadius.circular(12.r),
// // //                           borderSide: const BorderSide(color: AppColors.primary),
// // //                         ),
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //             const Spacer(),
// // //             Consumer<AuthProvider>(
// // //               builder: (context, provider, child) {
// // //                 return provider.isLoading
// // //                     ? Center(child: CircularProgressIndicator())
// // //                     : Button(
// // //                         title: "Continue",
// // //                         onPressed: () async {
// // //                           if (phoneController.text.isEmpty ||
// // //                               phoneController.text.length < 10) {
// // //                             ScaffoldMessenger.of(context).showSnackBar(
// // //                               SnackBar(
// // //                                 content: Text("Enter valid phone number"),
// // //                               ),
// // //                             );
// // //                             return;
// // //                           }
// // //                           String fullPhone = "${selectedCountry.phoneCode}${phoneController.text.trim()}";
// // //                           final result = await context
// // //                               .read<AuthProvider>()
// // //                               .sendOtp(fullPhone);
// // //                           if (result['success']) {
// // //                             Navigator.push(
// // //                               context,
// // //                               MaterialPageRoute(
// // //                                 builder: (_) => OTPScreen(phone: fullPhone),
// // //                               ),
// // //                             );
// // //                           } else {
// // //                             ScaffoldMessenger.of(context).showSnackBar(
// // //                               SnackBar(content: Text(result['message'])),
// // //                             );
// // //                           }
// // //                         },
// // //                       );
// // //               },
// // //             ),
// // //             SizedBox(height: 15.h),
// // //             Row(
// // //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //               children: [
// // //                 SizedBox(
// // //                   height: 50.h,
// // //                   child: OutlinedButton(
// // //                     style: OutlinedButton.styleFrom(
// // //                       side: BorderSide(color: Colors.grey.shade300),
// // //                       shape: RoundedRectangleBorder(
// // //                         borderRadius: BorderRadius.circular(25.r),
// // //                       ),
// // //                     ),
// // //                     onPressed: () {},
// // //                     child: Row(
// // //                       mainAxisAlignment: MainAxisAlignment.center,
// // //                       children: [
// // //                         Text(
// // //                           "Continue with",
// // //                           style: TextStyle(
// // //                             fontSize: 14.sp,
// // //                             color: Colors.black,
// // //                           ),
// // //                         ),
// // //                         Image.asset(
// // //                           "assets/images/google.png",
// // //                           height: 30,
// // //                           width: 30,
// // //                         ),
// // //                       ],
// // //                     ),
// // //                   ),
// // //                 ),
// // //                 SizedBox(
// // //                   height: 50.h,
// // //                   child: OutlinedButton(
// // //                     style: OutlinedButton.styleFrom(
// // //                       side: BorderSide(color: Colors.grey.shade300),
// // //                       shape: RoundedRectangleBorder(
// // //                         borderRadius: BorderRadius.circular(25.r),
// // //                       ),
// // //                     ),
// // //                     onPressed: () {},
// // //                     child: Row(
// // //                       mainAxisAlignment: MainAxisAlignment.center,
// // //                       children: [
// // //                         Text(
// // //                           "Continue with",
// // //                           style: TextStyle(
// // //                             fontSize: 14.sp,
// // //                             color: Colors.black,
// // //                           ),
// // //                         ),
// // //                         Image.asset(
// // //                           "assets/images/apple.png",
// // //                           height: 30,
// // //                           width: 30,
// // //                         ),
// // //                       ],
// // //                     ),
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //             SizedBox(height: 20.h),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// //
// // import 'package:betrade/core/theme/app_text_style.dart';
// // import 'package:betrade/presentation/screens/signin/otp_screen.dart';
// // import 'package:betrade/presentation/widget/purple_button.dart';
// // import 'package:betrade/presentation/widget/leading_icon.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_screenutil/flutter_screenutil.dart';
// // import 'package:provider/provider.dart';
// // import '../../../core/theme/app_colors.dart';
// // import '../../../data/model/country_model.dart';
// // import '../../../data/provider/signIn_provider.dart';
// // import 'country_picker_sheet.dart';
// //
// // class LoginScreen extends StatefulWidget {
// //   const LoginScreen({super.key});
// //   @override
// //   State<LoginScreen> createState() => _LoginScreenState();
// // }
// // class _LoginScreenState extends State<LoginScreen> {
// //   Future<void> openCountryPicker(BuildContext context) async {
// //     final selectedCountry = await showModalBottomSheet<CountryModel>(
// //       context: context,
// //       isScrollControlled: true,
// //       backgroundColor: Colors.transparent,
// //       builder: (_) => const CountryPickerSheet(),
// //     );
// //     if (selectedCountry != null) {
// //       onCountrySelected(selectedCountry);
// //     }
// //   }
// //   CountryModel selectedCountry = CountryModel(
// //     id: 0,
// //     name: "India",
// //     phoneCode: "+91",
// //     flag: "🇮🇳",
// //     currency: '',
// //   );
// //   void onCountrySelected(CountryModel country) {
// //     setState(() {
// //       selectedCountry = country;
// //     });
// //   }
// //   TextEditingController phoneController = TextEditingController();
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.white,
// //       appBar: AppBar(
// //         backgroundColor: Colors.white,
// //         elevation: 0,
// //         automaticallyImplyLeading: false,
// //         leading: Padding(
// //           padding: const EdgeInsets.only(left: 12),
// //           child: LeadingIcon(),
// //         ),
// //       ),
// //       body: Padding(
// //         padding: EdgeInsets.symmetric(horizontal: 20.w),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             SizedBox(height: 10.h),
// //             Text(
// //                 "Enter Your Phone Number to Login",
// //                 style:AppTextStyle.heading
// //             ),
// //             SizedBox(height: 20.h),
// //             Row(
// //               children: [
// //                 GestureDetector(
// //                   onTap: () => openCountryPicker(context),
// //                   child: Container(
// //                     padding: EdgeInsets.symmetric(horizontal: 10.w),
// //                     height: 50.h,
// //                     decoration: BoxDecoration(
// //                       borderRadius: BorderRadius.circular(12.r),
// //                       color:AppColors.inputFieldBg,
// //                     ),
// //                     child: Row(
// //                       children: [
// //                         Text(
// //                           selectedCountry.flag,
// //                           style: TextStyle(fontSize: 16.sp),
// //                         ),
// //                         SizedBox(width: 5.w),
// //                         Icon(
// //                           Icons.keyboard_arrow_down,
// //                           size: 18.sp,
// //                           color: Colors.grey,
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //                 SizedBox(width: 10.w),
// //                 Expanded(
// //                   child:
// //                   SizedBox(height: 50.h,
// //                     child: TextField(
// //                       controller: phoneController,
// //                       cursorColor: AppColors.primary,
// //                       keyboardType: TextInputType.phone,
// //                       maxLength: 10,
// //                       decoration: InputDecoration(
// //                         filled: true,
// //                         fillColor: AppColors.inputFieldBg,
// //                         counterText: "",
// //                         hintText: "000 000 0000",
// //                         hintStyle: TextStyle(color: Colors.grey),
// //                         contentPadding: EdgeInsets.symmetric(
// //                           horizontal: 15.w,
// //                           vertical: 14.h,
// //                         ),
// //                         border: OutlineInputBorder(
// //                           borderRadius: BorderRadius.circular(12.r),
// //                           borderSide: BorderSide(color: Colors.grey.shade300),
// //                         ),
// //                         enabledBorder: OutlineInputBorder(
// //                           borderRadius: BorderRadius.circular(12.r),
// //                           borderSide: BorderSide(color: Colors.grey.shade300),
// //                         ),
// //                         focusedBorder: OutlineInputBorder(
// //                           borderRadius: BorderRadius.circular(12.r),
// //                           borderSide: const BorderSide(color: AppColors.primary),
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //             const Spacer(),
// //             Consumer<AuthProvider>(
// //               builder: (context, provider, child) {
// //                 return provider.isLoading
// //                     ? Center(child: CircularProgressIndicator())
// //                     : Button(
// //                   title: "Continue",
// //                   onPressed: () async {
// //                     if (phoneController.text.isEmpty ||
// //                         phoneController.text.length < 10) {
// //                       ScaffoldMessenger.of(context).showSnackBar(
// //                         SnackBar(
// //                           content: Text("Enter valid phone number"),
// //                         ),
// //                       );
// //                       return;
// //                     }
// //                     String fullPhone = "${selectedCountry.phoneCode}${phoneController.text.trim()}";
// //                     final result = await context
// //                         .read<AuthProvider>()
// //                         .sendOtp(fullPhone);
// //                     if (result['success']) {
// //                       Navigator.push(
// //                         context,
// //                         MaterialPageRoute(
// //                           builder: (_) => OTPScreen(phone: fullPhone),
// //                         ),
// //                       );
// //                     } else {
// //                       ScaffoldMessenger.of(context).showSnackBar(
// //                         SnackBar(content: Text(result['message'])),
// //                       );
// //                     }
// //                   },
// //                 );
// //               },
// //             ),
// //             SizedBox(height: 15.h),
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 SizedBox(
// //                   height: 50.h,
// //                   child: OutlinedButton(
// //                     style: OutlinedButton.styleFrom(
// //                       side: BorderSide(color: Colors.grey.shade300),
// //                       shape: RoundedRectangleBorder(
// //                         borderRadius: BorderRadius.circular(25.r),
// //                       ),
// //                     ),
// //                     onPressed: () {},
// //                     child: Row(
// //                       mainAxisAlignment: MainAxisAlignment.center,
// //                       children: [
// //                         Text(
// //                           "Continue with",
// //                           style: TextStyle(
// //                             fontSize: 14.sp,
// //                             color: Colors.black,
// //                           ),
// //                         ),
// //                         Image.asset(
// //                           "assets/images/google.png",
// //                           height: 30,
// //                           width: 30,
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //                 SizedBox(
// //                   height: 50.h,
// //                   child: OutlinedButton(
// //                     style: OutlinedButton.styleFrom(
// //                       side: BorderSide(color: Colors.grey.shade300),
// //                       shape: RoundedRectangleBorder(
// //                         borderRadius: BorderRadius.circular(25.r),
// //                       ),
// //                     ),
// //                     onPressed: () {},
// //                     child: Row(
// //                       mainAxisAlignment: MainAxisAlignment.center,
// //                       children: [
// //                         Text(
// //                           "Continue with",
// //                           style: TextStyle(
// //                             fontSize: 14.sp,
// //                             color: Colors.black,
// //                           ),
// //                         ),
// //                         Image.asset(
// //                           "assets/images/apple.png",
// //                           height: 30,
// //                           width: 30,
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //             SizedBox(height: 20.h),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
//
// //
// // import 'package:betrade/core/theme/app_text_style.dart';
// // import 'package:betrade/presentation/screens/signin/otp_screen.dart';
// // import 'package:betrade/presentation/widget/purple_button.dart';
// // import 'package:betrade/presentation/widget/leading_icon.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_screenutil/flutter_screenutil.dart';
// // import 'package:provider/provider.dart';
// // import '../../../core/theme/app_colors.dart';
// // import '../../../data/model/country_model.dart';
// // import '../../../data/provider/country_provider.dart';
// // import '../../../data/provider/signIn_provider.dart';
// // import 'country_picker_sheet.dart';
// //
// // class LoginScreen extends StatefulWidget {
// //   const LoginScreen({super.key});
// //
// //   @override
// //   State<LoginScreen> createState() => _LoginScreenState();
// // }
// //
// // class _LoginScreenState extends State<LoginScreen> {
// //   TextEditingController phoneController = TextEditingController();
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     Future.microtask(() {
// //       final provider = context.read<CountryProvider>();
// //       if (!provider.isLoading && provider.countries.isEmpty) {
// //         provider.fetchCountries();
// //       }
// //     });
// //   }
// //
// //   Future<void> openCountryPicker(BuildContext context) async {
// //     final selectedCountry = await showModalBottomSheet<CountryModel>(
// //       context: context,
// //       isScrollControlled: true,
// //       backgroundColor: Colors.transparent,
// //       builder: (_) => const CountryPickerSheet(),
// //     );
// //     if (selectedCountry != null && mounted) {
// //       context.read<CountryProvider>().selectCountry(selectedCountry);
// //     }
// //   }
// //
// //   @override
// //   void dispose() {
// //     phoneController.dispose();
// //     super.dispose();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.white,
// //       appBar: AppBar(
// //         backgroundColor: Colors.white,
// //         elevation: 0,
// //         automaticallyImplyLeading: false,
// //         leading: Padding(
// //           padding: const EdgeInsets.only(left: 12),
// //           child: LeadingIcon(),
// //         ),
// //       ),
// //       body: Padding(
// //         padding: EdgeInsets.symmetric(horizontal: 20.w),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             SizedBox(height: 10.h),
// //             Text(
// //               "Enter Your Phone Number to Login",
// //               style: AppTextStyle.heading,
// //             ),
// //             SizedBox(height: 20.h),
// //             Consumer<CountryProvider>(
// //               builder: (context, countryProvider, child) {
// //                 // Loading state
// //                 if (countryProvider.isLoading) {
// //                   return Row(
// //                     children: [
// //                       Container(
// //                         padding: EdgeInsets.symmetric(horizontal: 10.w),
// //                         height: 50.h,
// //                         width: 80.w,
// //                         decoration: BoxDecoration(
// //                           color: AppColors.inputFieldBg,
// //                           borderRadius: BorderRadius.circular(12.r),
// //                         ),
// //                         child: const Center(
// //                           child: SizedBox(
// //                             height: 20,
// //                             width: 20,
// //                             child: CircularProgressIndicator(strokeWidth: 2),
// //                           ),
// //                         ),
// //                       ),
// //                       SizedBox(width: 10.w),
// //                       Expanded(
// //                         child: Container(
// //                           height: 50.h,
// //                           decoration: BoxDecoration(
// //                             color: AppColors.inputFieldBg,
// //                             borderRadius: BorderRadius.circular(12.r),
// //                           ),
// //                           child: const Center(
// //                             child: SizedBox(
// //                               height: 20,
// //                               width: 20,
// //                               child: CircularProgressIndicator(strokeWidth: 2),
// //                             ),
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   );
// //                 }
// //
// //                 final selectedCountry = countryProvider.selectedCountry;
// //
// //                 if (selectedCountry == null) {
// //                   return const SizedBox.shrink();
// //                 }
// //
// //                 return Row(
// //                   children: [
// //                     GestureDetector(
// //                       onTap: () => openCountryPicker(context),
// //                       child: Container(
// //                         padding: EdgeInsets.symmetric(horizontal: 10.w),
// //                         height: 50.h,
// //                         decoration: BoxDecoration(
// //                           borderRadius: BorderRadius.circular(12.r),
// //                           color: AppColors.inputFieldBg,
// //                         ),
// //                         child: Row(
// //                           children: [
// //                             CircleAvatar(
// //                               radius: 16.r,
// //                               backgroundColor: Colors.grey.shade200,
// //                               child: Text(
// //                                 selectedCountry.flag,
// //                                 style: TextStyle(fontSize: 18.sp),
// //                               ),
// //                             ),
// //                             SizedBox(width: 8.w),
// //                             Icon(
// //                               Icons.keyboard_arrow_down,
// //                               size: 18.sp,
// //                               color: Colors.grey,
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                     ),
// //                     SizedBox(width: 10.w),
// //                     Expanded(
// //                       child: SizedBox(
// //                         height: 50.h,
// //                         child: TextField(
// //                           controller: phoneController,
// //                           cursorColor: AppColors.primary,
// //                           keyboardType: TextInputType.phone,
// //                           maxLength: 15,
// //                           decoration: InputDecoration(
// //                             filled: true,
// //                             fillColor: AppColors.inputFieldBg,
// //                             counterText: "",
// //                             hintText: "000 000 0000",
// //                             hintStyle: TextStyle(color: Colors.grey),
// //                             contentPadding: EdgeInsets.symmetric(
// //                               horizontal: 15.w,
// //                               vertical: 14.h,
// //                             ),
// //                             border: OutlineInputBorder(
// //                               borderRadius: BorderRadius.circular(12.r),
// //                               borderSide: BorderSide(color: Colors.grey.shade300),
// //                             ),
// //                             enabledBorder: OutlineInputBorder(
// //                               borderRadius: BorderRadius.circular(12.r),
// //                               borderSide: BorderSide(color: Colors.grey.shade300),
// //                             ),
// //                             focusedBorder: OutlineInputBorder(
// //                               borderRadius: BorderRadius.circular(12.r),
// //                               borderSide: const BorderSide(color: AppColors.primary),
// //                             ),
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 );
// //               },
// //             ),
// //             const Spacer(),
// //             Consumer<AuthProvider>(
// //               builder: (context, authProvider, child) {
// //                 return authProvider.isLoading
// //                     ? const Center(child: CircularProgressIndicator())
// //                     : Consumer<CountryProvider>(
// //                   builder: (context, countryProvider, child) {
// //                     final currentCountry = countryProvider.selectedCountry;
// //
// //                     if (currentCountry == null) {
// //                       return const SizedBox.shrink();
// //                     }
// //
// //                     return Button(
// //                       title: "Continue",
// //                       onPressed: () async {
// //                         String phone = phoneController.text.trim().replaceAll(" ", "");
// //
// //                         if (phone.isEmpty) {
// //                           if (mounted) {
// //                             ScaffoldMessenger.of(context).showSnackBar(
// //                               const SnackBar(
// //                                 content: Text("Enter phone number"),
// //                               ),
// //                             );
// //                           }
// //                           return;
// //                         }
// //
// //                         if (phone.length < 5) {
// //                           if (mounted) {
// //                             ScaffoldMessenger.of(context).showSnackBar(
// //                               const SnackBar(
// //                                 content: Text("Enter valid phone number"),
// //                               ),
// //                             );
// //                           }
// //                           return;
// //                         }
// //
// //                         String fullPhone = "${currentCountry.phoneCode}$phone";
// //
// //                         final result = await context
// //                             .read<AuthProvider>()
// //                             .sendOtp(fullPhone);
// //
// //                         // Important: Check mounted before any navigation or UI update
// //                         if (!mounted) return;
// //
// //                         if (result['success']) {
// //                           // Navigate to OTPScreen
// //                           Navigator.push(
// //                             context,
// //                             MaterialPageRoute(
// //                               builder: (context) => OTPScreen(phone: fullPhone),
// //                             ),
// //                           );
// //                         } else {
// //                           ScaffoldMessenger.of(context).showSnackBar(
// //                             SnackBar(content: Text(result['message'] ?? "Failed to send OTP")),
// //                           );
// //                         }
// //                       },
// //                     );
// //                   },
// //                 );
// //               },
// //             ),
// //             SizedBox(height: 15.h),
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 Expanded(
// //                   child: SizedBox(
// //                     height: 50.h,
// //                     child: OutlinedButton(
// //                       style: OutlinedButton.styleFrom(
// //                         side: BorderSide(color: Colors.grey.shade300),
// //                         shape: RoundedRectangleBorder(
// //                           borderRadius: BorderRadius.circular(25.r),
// //                         ),
// //                       ),
// //                       onPressed: () {},
// //                       child: Row(
// //                         mainAxisAlignment: MainAxisAlignment.center,
// //                         children: [
// //                           Text(
// //                             "Continue with",
// //                             style: TextStyle(
// //                               fontSize: 14.sp,
// //                               color: Colors.black,
// //                             ),
// //                           ),
// //                           Image.asset(
// //                             "assets/images/google.png",
// //                             height: 30,
// //                             width: 30,
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //                 SizedBox(width: 10.w),
// //                 Expanded(
// //                   child: SizedBox(
// //                     height: 50.h,
// //                     child: OutlinedButton(
// //                       style: OutlinedButton.styleFrom(
// //                         side: BorderSide(color: Colors.grey.shade300),
// //                         shape: RoundedRectangleBorder(
// //                           borderRadius: BorderRadius.circular(25.r),
// //                         ),
// //                       ),
// //                       onPressed: () {},
// //                       child: Row(
// //                         mainAxisAlignment: MainAxisAlignment.center,
// //                         children: [
// //                           Text(
// //                             "Continue with",
// //                             style: TextStyle(
// //                               fontSize: 14.sp,
// //                               color: Colors.black,
// //                             ),
// //                           ),
// //                           Image.asset(
// //                             "assets/images/apple.png",
// //                             height: 30,
// //                             width: 30,
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //             SizedBox(height: 20.h),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
//
// // import 'package:betrade/models/country_model.dart';
// import 'package:betrade/core/theme/app_text_style.dart';
// import 'package:betrade/presentation/screens/signin/otp_screen.dart';
// import 'package:betrade/presentation/widget/purple_button.dart';
// import 'package:betrade/presentation/widget/leading_icon.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:http/http.dart';
// import 'package:provider/provider.dart';
// import '../../../core/theme/app_colors.dart';
// import '../../../data/model/country_model.dart';
// import '../../../data/provider/country_provider.dart';
// import '../../../data/provider/signIn_provider.dart';
// import 'country_picker_sheet.dart';
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   @override
//   void initState() {
//     super.initState();
//     setDefaultCountry();
//   }
//
//   Future<void> setDefaultCountry() async {
//     final provider = Provider.of<CountryProvider>(context, listen: false);
//     await provider.fetchCountries();
//
//     if (provider.countries.isNotEmpty) {
//       setState(() {
//         selectedCountry = provider.countries.first;
//       });
//     }
//   }
//
//   Future<void> openCountryPicker(BuildContext context) async {
//     final selectedCountry = await showModalBottomSheet<CountryModel>(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         return ChangeNotifierProvider.value(
//           value: Provider.of<CountryProvider>(context, listen: false),
//           child: const CountryPickerSheet(),
//         );
//       },
//     );
//
//     if (selectedCountry != null) {
//       onCountrySelected(selectedCountry);
//     }
//   }
//
//   CountryModel? selectedCountry;
//
//   void onCountrySelected(CountryModel country) {
//     setState(() {
//       selectedCountry = country;
//     });
//   }
//
//   TextEditingController phoneController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         automaticallyImplyLeading: false,
//         leading: Padding(
//           padding: const EdgeInsets.only(left: 12),
//           child: LeadingIcon(),
//         ),
//       ),
//       body: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 20.w),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(height: 10.h),
//             Text(
//               "Enter Your Phone Number to Login",
//              style: AppTextStyle.heading,
//             ),
//             SizedBox(height: 20.h),
//             Row(
//               children: [
//                 GestureDetector(
//                   onTap: () => openCountryPicker(context),
//                   child: Container(
//                     padding:
//                         EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
//                     decoration: BoxDecoration(
//                       color: AppColors.inputFieldBg,
//                       borderRadius: BorderRadius.circular(12.r),
//                     ),
//                     child: Row(
//                       children: [
//                         Text(selectedCountry?.flag ?? "",
//                             style: TextStyle(fontSize: 16.sp)),
//                         SizedBox(width: 5.w),
//                         // Text(
//                         //   selectedCountry?.phoneCode ?? "+__",
//                         //   style: TextStyle(fontSize: 14.sp),
//                         // ),
//                         SizedBox(width: 5.w),
//                         Icon(Icons.keyboard_arrow_down,
//                             size: 18.sp, color: Colors.grey),
//                       ],
//                     ),
//                   ),
//                 ),
//
//                 SizedBox(width: 10.w),
//
//                 /// PHONE FIELD
//                 Expanded(
//                   child: Container(
//                     height: 50.h,
//                     child: TextField(
//                       controller: phoneController,
//                       cursorColor: AppColors.primary,
//                       keyboardType: TextInputType.phone,
//                       maxLength: 10,
//                       decoration: InputDecoration(
//                         filled: true,
//                         fillColor:AppColors.inputFieldBg,
//                         counterText: "",
//                         hintText: "000 000 0000",
//                         hintStyle: TextStyle(color: Colors.grey),
//                         contentPadding: EdgeInsets.symmetric(
//                             horizontal: 15.w, vertical: 14.h),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12.r),
//                           borderSide: BorderSide(color: Colors.grey.shade300),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12.r),
//                           borderSide: BorderSide(color: Colors.grey.shade300),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12.r),
//                           borderSide: const BorderSide(color: AppColors.primary),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//
//             const Spacer(),
//
//             /// CONTINUE BUTTON
//             Consumer<AuthProvider>(
//               builder: (context, provider, child) {
//                 return provider.isLoading
//                     ? Center(child: CircularProgressIndicator())
//                     : Button(
//                         title: "Continue",
//                         onPressed: () async {
//                           if (phoneController.text.isEmpty ||
//                               phoneController.text.length < 10) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                   content: Text("Enter valid phone number")),
//                             );
//                             return;
//                           }
//
//                           if (selectedCountry == null) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(content: Text("Please select country")),
//                             );
//                             return;
//                           }
//
//                           String fullPhone =
//                               "${selectedCountry!.phoneCode}${phoneController.text.trim()}";
//
//                           final result = await context
//                               .read<AuthProvider>()
//                               .sendOtp(fullPhone);
//
//                           if (result['success']) {
//                             /// ✅ Success → go to OTP
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) => OTPScreen(phone: fullPhone),
//                               ),
//                             );
//                           } else {
//                             /// ❌ Show backend message
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(content: Text(result['message'])),
//                             );
//                           }
//                         },
//                       );
//               },
//             ),
//
//             SizedBox(height: 15.h),
//
//             /// SOCIAL BUTTONS
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 /// Google Button
//                 SizedBox(
//                   height: 50.h,
//                   child: OutlinedButton(
//                       style: OutlinedButton.styleFrom(
//                         side: BorderSide(color: Colors.grey.shade300),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(25.r),
//                         ),
//                       ),
//                       onPressed: () {},
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             "Continue with",
//                             style:
//                                 TextStyle(fontSize: 14.sp, color: Colors.black),
//                           ),
//                           Image.asset(
//                             "assets/images/google.png",
//                             height: 30,
//                             width: 30,
//                           )
//                         ],
//                       )),
//                 ),
//
//                 /// Apple Button
//                 SizedBox(
//                   height: 50.h,
//                   child: OutlinedButton(
//                       style: OutlinedButton.styleFrom(
//                         side: BorderSide(color: Colors.grey.shade300),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(25.r),
//                         ),
//                       ),
//                       onPressed: () {},
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             "Continue with",
//                             style:
//                                 TextStyle(fontSize: 14.sp, color: Colors.black),
//                           ),
//                           Image.asset(
//                             "assets/images/apple.png",
//                             height: 30,
//                             width: 30,
//                           )
//                         ],
//                       )),
//                 ),
//               ],
//             ),
//
//             SizedBox(height: 20.h),
//           ],
//         ),
//       ),
//     );
//   }
// }

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
import '../../../data/provider/signIn_provider.dart';
import 'country_picker_sheet.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
    setDefaultCountry();
  }

  Future<void> setDefaultCountry() async {
    final provider = Provider.of<CountryProvider>(context, listen: false);
    await provider.fetchCountries();

    if (provider.countries.isNotEmpty) {
      setState(() {
        selectedCountry = provider.countries.first;
      });
    }
  }

  Future<void> openCountryPicker(BuildContext context) async {
    final selectedCountry = await showModalBottomSheet<CountryModel>(
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

    if (selectedCountry != null) {
      onCountrySelected(selectedCountry);
    }
  }

  CountryModel? selectedCountry;

  void onCountrySelected(CountryModel country) {
    setState(() {
      selectedCountry = country;
    });
  }

  TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.cardBackgroundDynamic(context),
      // appBar: AppBar(
      //   backgroundColor: AppColors.cardBackgroundDynamic(context),
      //   elevation: 0,
      //   automaticallyImplyLeading: false,
      //   leading: const Padding(
      //     padding: EdgeInsets.only(left: 12),
      //     child: LeadingIcon(),
      //   ),
      // ),
      appBar: AppBar(
        backgroundColor: AppColors.cardBackgroundDynamic(context),
        elevation: 0,
        automaticallyImplyLeading: false,
        leadingWidth: 55.w,
        leading: const Padding(
          padding: EdgeInsets.only(left:12),
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
                /// COUNTRY PICKER BUTTON
                GestureDetector(
                  onTap: () => openCountryPicker(context),
                  child: Container(
                    height: 50.h,
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                    decoration: BoxDecoration(
                      color: AppColors.inputFieldBgDynamic(context),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: AppColors.borderDynamic(context),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          selectedCountry?.flag ?? "🇮🇳",
                          style: TextStyle(fontSize: 16.sp),
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

                /// PHONE FIELD
                Expanded(
                  child: Container(
                    height: 50.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: TextField(
                      controller: phoneController,
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

            const Spacer(),

            /// CONTINUE BUTTON
            Consumer<AuthProvider>(
              builder: (context, provider, child) {
                return provider.isLoading
                    ? Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                )
                    : Button(
                  title: "Continue",
                  onPressed: () async {
                    if (phoneController.text.isEmpty ||
                        phoneController.text.length < 10) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Enter valid phone number",
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          backgroundColor: isDarkMode
                              ? Colors.grey.shade800
                              : null,
                        ),
                      );
                      return;
                    }

                    if (selectedCountry == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Please select country",
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          backgroundColor: isDarkMode
                              ? Colors.grey.shade800
                              : null,
                        ),
                      );
                      return;
                    }

                    String fullPhone =
                        "${selectedCountry!.phoneCode}${phoneController.text.trim()}";

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
                        SnackBar(
                          content: Text(
                            result['message'],
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          backgroundColor: isDarkMode
                              ? Colors.grey.shade800
                              : null,
                        ),
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
                /// Google Button
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
                        backgroundColor: AppColors.buttonSecondaryDynamic(context),
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
                          Image.asset(
                            "assets/images/google.png",
                            height:19.h,
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
                        backgroundColor: AppColors.buttonSecondaryDynamic(context),
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
                          SizedBox(width:2.w),
                          Icon(
                            Icons.apple,
                            size:24.h,
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
