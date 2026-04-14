// import 'dart:convert';
// import 'dart:io';
// import 'package:betrade/core/theme/app_colors.dart';
// import 'package:betrade/presentation/screens/verification/step_heder.dart';
// import 'package:betrade/presentation/widget/purple_button.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import '../../../core/config/api_endpoint..dart';
// import '../../../data/model/country_model.dart';
// import '../../../data/services/local_storage.dart';
// import '../camera/camera_screen.dart';
// import '../camera/selfie_camera.dart';
// import '../main_screen.dart';
// import 'country_services_step_one.dart';
//
// class VerificationFlow extends StatefulWidget {
//   @override
//   State<VerificationFlow> createState() => _VerificationFlowState();
// }
//
// class _VerificationFlowState extends State<VerificationFlow> {
//   int currentStep = 0;
//   File? selfieImage;
//   bool isSelfieUploaded = false;
//   File? frontImage;
//   File? backImage;
//   bool isLoading = true;
//   bool isFrontUploaded = false;
//   bool isBackUploaded = false;
//
//   final ImagePicker picker = ImagePicker();
//   List<CountryModel> countries = [];
//   CountryModel? selectedCountry;
//   List<DropdownItem> languages = [];
//   DropdownItem? language;
//   String? selectedCurrency;
//
//   @override
//   void initState() {
//     super.initState();
//
//     Future.microtask(() {
//       loadAllData();
//     });
//   }
//
//   Future<void> loadAllData() async {
//     try {
//       if (!mounted) return;
//       setState(() => isLoading = true);
//
//       final countryRes = await CountryService.fetchCountries();
//
//       if (!mounted) return;
//
//       countries = countryRes;
//
//       if (countries.isNotEmpty) {
//         selectedCountry = countries.first;
//         selectedCurrency = selectedCountry?.currency;
//       }
//
//       final token = LocalStorage.getToken();
//
//       final response = await http.get(
//         Uri.parse(ApiEndpoints.languages),
//         headers: {
//           "Accept": "application/json",
//           "Authorization": "Bearer $token",
//         },
//       );
//
//       if (!mounted) return;
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final List list = data['data'];
//
//         languages = list
//             .map((e) => DropdownItem(id: e['id'], name: e['name']))
//             .toList();
//
//         if (languages.isNotEmpty) {
//           language = languages.first;
//         }
//       }
//
//       if (!mounted) return;
//
//       setState(() => isLoading = false);
//     } catch (e) {
//       if (!mounted) return;
//       setState(() => isLoading = false);
//     }
//   }
//
//   bool isStep2Valid() {
//     return frontImage != null && backImage != null;
//   }
//
//   Future<void> submitKyc() async {
//     try {
//       if (frontImage == null || backImage == null || selfieImage == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Please upload all images")),
//         );
//         return;
//       }
//
//       final token = LocalStorage.getToken();
//
//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse(ApiEndpoints.kycSubmit),
//       );
//
//       request.headers.addAll({
//         "Authorization": "Bearer $token",
//         "Accept": "application/json",
//       });
//
//       request.files.add(await http.MultipartFile.fromPath(
//         'id_front',
//         frontImage!.path,
//       ));
//
//       request.files.add(await http.MultipartFile.fromPath(
//         'id_back',
//         backImage!.path,
//       ));
//
//       request.files.add(await http.MultipartFile.fromPath(
//         'selfie',
//         selfieImage!.path,
//       ));
//
//       var response = await request.send();
//
//       var responseData = await response.stream.bytesToString();
//
//       print("KYC RESPONSE: $responseData");
//
//       if (response.statusCode == 200) {
//         print(" KYC SUCCESS");
//       } else {
//         print(" KYC FAILED");
//       }
//     } catch (e) {
//       print("KYC ERROR: $e");
//     }
//   }
//
//   Future<void> submitStep1() async {
//     try {
//       final token = LocalStorage.getToken();
//       final url = Uri.parse(ApiEndpoints.preferences);
//       final response = await http.post(
//         url,
//         headers: {
//           "Accept": "application/json",
//           "Authorization": "Bearer $token",
//           "Content-Type": "application/json",
//         },
//         body: jsonEncode({
//           "country_id": selectedCountry?.id,
//           "preferred_language_id": language?.id,
//         }),
//       );
//
//       print("STEP1 RESPONSE: ${response.body}");
//     } catch (e) {
//       print("API Error: $e");
//     }
//   }
//
//   bool isStepValid() {
//     return selectedCountry != null && language != null;
//   }
//
//   void nextStep() async {
//     if (currentStep == 0) {
//       await submitStep1();
//     }
//
//     if (currentStep < 2) {
//       setState(() {
//         currentStep++;
//       });
//     }
//   }
//
//   Widget buildStepContent() {
//     switch (currentStep) {
//       case 0:
//         return step1();
//       case 1:
//         return step2();
//       case 2:
//         return step3();
//       default:
//         return step1();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       child: SafeArea(
//         child: Column(
//           children: [
//             Container(
//               margin: EdgeInsets.symmetric(vertical: 10),
//               height: 5,
//               width: 50,
//               decoration: BoxDecoration(
//                 color: Colors.grey,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//             StepHeader(currentStep: currentStep),
//             Expanded(
//               child: isLoading
//                   ? Center(child: CircularProgressIndicator())
//                   : buildStepContent(),
//             ),
//             if (currentStep != 2)
//               Padding(
//                 padding: EdgeInsets.all(16),
//                 child: SizedBox(
//                   height: 55,
//                   width: double.infinity,
//                   child: Button(
//                     title: "Next",
//                     onPressed: () {
//                       if (currentStep == 0 && isStepValid()) {
//                         nextStep();
//                       } else if (currentStep == 1 && isStep2Valid()) {
//                         nextStep();
//                       }
//                     },
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget step1() {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Divider(),
//           SizedBox(height: 20),
//           buildCountryDropdown(),
//           buildCurrencyDropdown(),
//           buildLanguageDropdown(),
//         ],
//       ),
//     );
//   }
//
//   Widget buildCountryDropdown() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text("Country"),
//         SizedBox(height: 8),
//         Container(
//           padding: EdgeInsets.symmetric(horizontal: 12),
//           decoration: BoxDecoration(
//             color: Colors.grey.shade200,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: DropdownButton<CountryModel>(
//               value:
//                   countries.contains(selectedCountry) ? selectedCountry : null,
//               isExpanded: true,
//               underline: SizedBox(),
//               items: countries.map((e) {
//                 return DropdownMenuItem(
//                   value: e,
//                   child: Row(
//                     children: [Text(e.flag), SizedBox(width: 8), Text(e.name)],
//                   ),
//                 );
//               }).toList(),
//               onChanged: (val) {
//                 if (val == null) return;
//
//                 setState(() {
//                   selectedCountry = val;
//                   selectedCurrency = val.currency;
//                 });
//               }),
//         ),
//         SizedBox(height: 16),
//       ],
//     );
//   }
//
//   Widget buildCurrencyDropdown() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text("Currency"),
//         SizedBox(height: 8),
//         Container(
//           padding: EdgeInsets.symmetric(horizontal: 12),
//           decoration: BoxDecoration(
//             color: Colors.grey.shade200,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: DropdownButton<String>(
//             value: selectedCurrency,
//             isExpanded: true,
//             underline: SizedBox(),
//             items: selectedCurrency != null
//                 ? [
//                     DropdownMenuItem(
//                       value: selectedCurrency,
//                       child: Text(selectedCurrency!),
//                     ),
//                   ]
//                 : [],
//             onChanged: null,
//           ),
//         ),
//         SizedBox(height: 16),
//       ],
//     );
//   }
//
//   Widget buildLanguageDropdown() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text("Language"),
//         SizedBox(height: 8),
//         Container(
//           padding: EdgeInsets.symmetric(horizontal: 12),
//           decoration: BoxDecoration(
//             color: Colors.grey.shade200,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: languages.isEmpty
//               ? Padding(
//                   padding: EdgeInsets.all(12),
//                   child: Text("No Language Found"),
//                 )
//               : DropdownButton<DropdownItem>(
//                   value: language,
//                   isExpanded: true,
//                   underline: SizedBox(),
//                   items: languages.map((e) {
//                     return DropdownMenuItem(
//                       value: e,
//                       child: Text(e.name),
//                     );
//                   }).toList(),
//                   onChanged: (val) {
//                     if (val == null) return;
//                     setState(() {
//                       language = val;
//                     });
//                   }),
//         ),
//         SizedBox(height: 16),
//       ],
//     );
//   }
//
//   Widget step2() {
//     return Padding(
//       padding: EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(height: 20),
//           // FRONT
//           buildUploadBox("ID Card (Front)", frontImage, () => openCamera(true)),
//
//           // BACK
//           buildUploadBox("ID Card (Back)", backImage, () => openCamera(false)),
//         ],
//       ),
//     );
//   }
//
//   Widget step3() {
//     return Padding(
//       padding: EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Divider(),
//           SizedBox(height: 20),
//           buildSelfieBox(),
//           Spacer(),
//           SizedBox(
//             width: double.infinity,
//             height: 55,
//             child: ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: isSelfieUploaded
//                     ? AppColors.primary
//                     : Colors.purple.shade200,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//               ),
//               onPressed: isSelfieUploaded
//                   ? () async {
//                       if (frontImage == null || backImage == null) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(content: Text("Upload ID images first")),
//                         );
//                         return;
//                       }
//
//                       await submitKyc();
//                       if (!mounted) return;
//
//                       Navigator.pushAndRemoveUntil(
//                         context,
//                         MaterialPageRoute(builder: (_) => MainScreen()),
//                         (route) => false,
//                       );
//                     }
//                   : null,
//               child: Text(
//                 "Verify my account",
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget buildUploadBox(String title, File? image, VoidCallback onTap) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(title),
//         SizedBox(height: 8),
//         GestureDetector(
//           onTap: onTap,
//           child: Container(
//             height: 120,
//             width: double.infinity,
//             decoration: BoxDecoration(
//               color: Colors.grey.shade200,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: image != null
//                 ? ClipRRect(
//                     borderRadius: BorderRadius.circular(12),
//                     child: Image.file(image, fit: BoxFit.cover),
//                   )
//                 : Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
//           ),
//         ),
//         SizedBox(height: 16),
//       ],
//     );
//   }
//
//   Future<void> openCamera(bool isFront) async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => CameraScreen(isFront: isFront)),
//     );
//
//     if (!mounted) return;
//
//     if (result != null) {
//       setState(() {
//         if (isFront) {
//           frontImage = File(result);
//           isFrontUploaded = true;
//         } else {
//           backImage = File(result);
//           isBackUploaded = true;
//         }
//       });
//     }
//   }
//
//   Widget buildSelfieBox() {
//     return GestureDetector(
//       onTap: openSelfieCamera,
//       child: Container(
//         height: 140,
//         width: double.infinity,
//         decoration: BoxDecoration(
//           color: Colors.grey.shade200,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: selfieImage != null
//             ? ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: Image.file(selfieImage!, fit: BoxFit.cover),
//               )
//             : Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
//       ),
//     );
//   }
//
//   Future<void> openSelfieCamera() async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => SelfieCameraScreen()),
//     );
//
//     if (!mounted) return;
//
//     if (result != null) {
//       setState(() {
//         selfieImage = File(result);
//         isSelfieUploaded = true;
//       });
//     }
//   }
// }
//
// class DropdownItem {
//   final int id;
//   final String name;
//
//   DropdownItem({required this.id, required this.name});
// }

// import 'dart:convert';
// import 'dart:io';
// import 'package:betrade/core/theme/app_colors.dart';
// import 'package:betrade/presentation/screens/verification/step_heder.dart';
// import 'package:betrade/presentation/widget/purple_button.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import '../../../core/config/api_endpoint..dart';
// import '../../../data/model/country_model.dart';
// import '../../../data/services/local_storage.dart';
// import '../camera/camera_screen.dart';
// import '../camera/selfie_camera.dart';
// import '../main_screen.dart';
// import 'country_services_step_one.dart';
//
// class VerificationFlow extends StatefulWidget {
//   @override
//   State<VerificationFlow> createState() => _VerificationFlowState();
// }
//
// class _VerificationFlowState extends State<VerificationFlow> {
//   int currentStep = 0;
//   File? selfieImage;
//   bool isSelfieUploaded = false;
//   File? frontImage;
//   File? backImage;
//   bool isLoading = true;
//   bool isFrontUploaded = false;
//   bool isBackUploaded = false;
//
//   final ImagePicker picker = ImagePicker();
//   List<CountryModel> countries = [];
//   CountryModel? selectedCountry;
//   List<DropdownItem> languages = [];
//   DropdownItem? language;
//   String? selectedCurrency;
//
//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(() {
//       loadAllData();
//     });
//   }
//
//   Future<void> loadAllData() async {
//     try {
//       if (!mounted) return;
//       setState(() => isLoading = true);
//
//       final countryRes = await CountryService.fetchCountries();
//
//       if (!mounted) return;
//
//       countries = countryRes;
//
//       if (countries.isNotEmpty) {
//         selectedCountry = countries.first;
//         selectedCurrency = selectedCountry?.currency;
//       }
//
//       final token = LocalStorage.getToken();
//
//       final response = await http.get(
//         Uri.parse(ApiEndpoints.languages),
//         headers: {
//           "Accept": "application/json",
//           "Authorization": "Bearer $token",
//         },
//       );
//
//       if (!mounted) return;
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final List list = data['data'];
//
//         languages = list
//             .map((e) => DropdownItem(id: e['id'], name: e['name']))
//             .toList();
//
//         if (languages.isNotEmpty) {
//           language = languages.first;
//         }
//       }
//
//       if (!mounted) return;
//
//       setState(() => isLoading = false);
//     } catch (e) {
//       if (!mounted) return;
//       setState(() => isLoading = false);
//     }
//   }
//
//   bool isStep2Valid() {
//     return frontImage != null && backImage != null;
//   }
//
//   Future<void> submitKyc() async {
//     try {
//       if (frontImage == null || backImage == null || selfieImage == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Please upload all images"),
//             backgroundColor: AppColors.snackbarErrorDynamic(context),
//           ),
//         );
//         return;
//       }
//
//       final token = LocalStorage.getToken();
//
//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse(ApiEndpoints.kycSubmit),
//       );
//
//       request.headers.addAll({
//         "Authorization": "Bearer $token",
//         "Accept": "application/json",
//       });
//
//       request.files.add(await http.MultipartFile.fromPath(
//         'id_front',
//         frontImage!.path,
//       ));
//
//       request.files.add(await http.MultipartFile.fromPath(
//         'id_back',
//         backImage!.path,
//       ));
//
//       request.files.add(await http.MultipartFile.fromPath(
//         'selfie',
//         selfieImage!.path,
//       ));
//
//       var response = await request.send();
//       var responseData = await response.stream.bytesToString();
//
//       print("KYC RESPONSE: $responseData");
//
//       if (response.statusCode == 200) {
//         print(" KYC SUCCESS");
//       } else {
//         print(" KYC FAILED");
//       }
//     } catch (e) {
//       print("KYC ERROR: $e");
//     }
//   }
//
//   Future<void> submitStep1() async {
//     try {
//       final token = LocalStorage.getToken();
//       final url = Uri.parse(ApiEndpoints.preferences);
//       final response = await http.post(
//         url,
//         headers: {
//           "Accept": "application/json",
//           "Authorization": "Bearer $token",
//           "Content-Type": "application/json",
//         },
//         body: jsonEncode({
//           "country_id": selectedCountry?.id,
//           "preferred_language_id": language?.id,
//         }),
//       );
//
//       print("STEP1 RESPONSE: ${response.body}");
//     } catch (e) {
//       print("API Error: $e");
//     }
//   }
//
//   bool isStepValid() {
//     return selectedCountry != null && language != null;
//   }
//
//   void nextStep() async {
//     if (currentStep == 0) {
//       await submitStep1();
//     }
//
//     if (currentStep < 2) {
//       setState(() {
//         currentStep++;
//       });
//     }
//   }
//
//   Widget buildStepContent() {
//     switch (currentStep) {
//       case 0:
//         return step1();
//       case 1:
//         return step2();
//       case 2:
//         return step3();
//       default:
//         return step1();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
//
//     return Material(
//       color: AppColors.cardBackgroundDynamic(context),
//       child: SafeArea(
//         child: Column(
//           children: [
//             Container(
//               margin: EdgeInsets.symmetric(vertical: 10.h),
//               height: 5.h,
//               width: 50.w,
//               decoration: BoxDecoration(
//                 color: AppColors.borderDynamic(context),
//                 borderRadius: BorderRadius.circular(10.r),
//               ),
//             ),
//             StepHeader(currentStep: currentStep),
//             Expanded(
//               child: isLoading
//                   ? Center(
//                 child: CircularProgressIndicator(
//                   color: AppColors.primary,
//                 ),
//               )
//                   : buildStepContent(),
//             ),
//             if (currentStep != 2)
//               Padding(
//                 padding: EdgeInsets.all(16.w),
//                 child: SizedBox(
//                   height: 55.h,
//                   width: double.infinity,
//                   child: Button(
//                     title: "Next",
//                     onPressed: () {
//                       if (currentStep == 0 && isStepValid()) {
//                         nextStep();
//                       } else if (currentStep == 1 && isStep2Valid()) {
//                         nextStep();
//                       }
//                     },
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget step1() {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 16.w),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Divider(color: AppColors.borderDynamic(context)),
//           SizedBox(height: 20.h),
//           buildCountryDropdown(),
//           buildCurrencyDropdown(),
//           buildLanguageDropdown(),
//         ],
//       ),
//     );
//   }
//
//   Widget buildCountryDropdown() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "Country",
//           style: TextStyle(
//             color: AppColors.textPrimaryDynamic(context),
//           ),
//         ),
//         SizedBox(height: 8.h),
//         Container(
//           padding: EdgeInsets.symmetric(horizontal: 12.w),
//           decoration: BoxDecoration(
//             color: AppColors.inputFieldBgDynamic(context),
//             borderRadius: BorderRadius.circular(12.r),
//             border: Border.all(
//               color: AppColors.borderDynamic(context),
//             ),
//           ),
//           child: DropdownButton<CountryModel>(
//             value: countries.contains(selectedCountry) ? selectedCountry : null,
//             isExpanded: true,
//             underline: const SizedBox(),
//             dropdownColor: AppColors.cardBackgroundDynamic(context),
//             style: TextStyle(
//               color: AppColors.textPrimaryDynamic(context),
//             ),
//             iconEnabledColor: AppColors.textPrimaryDynamic(context),
//             items: countries.map((e) {
//               return DropdownMenuItem(
//                 value: e,
//                 child: Row(
//                   children: [
//                     Text(e.flag, style: TextStyle(fontSize: 16.sp)),
//                     SizedBox(width: 8.w),
//                     Text(
//                       e.name,
//                       style: TextStyle(
//                         color: AppColors.textPrimaryDynamic(context),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }).toList(),
//             onChanged: (val) {
//               if (val == null) return;
//               setState(() {
//                 selectedCountry = val;
//                 selectedCurrency = val.currency;
//               });
//             },
//           ),
//         ),
//         SizedBox(height: 16.h),
//       ],
//     );
//   }
//
//   Widget buildCurrencyDropdown() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "Currency",
//           style: TextStyle(
//             color: AppColors.textPrimaryDynamic(context),
//           ),
//         ),
//         SizedBox(height: 8.h),
//         Container(
//           padding: EdgeInsets.symmetric(horizontal: 12.w),
//           decoration: BoxDecoration(
//             color: AppColors.inputFieldBgDynamic(context),
//             borderRadius: BorderRadius.circular(12.r),
//             border: Border.all(
//               color: AppColors.borderDynamic(context),
//             ),
//           ),
//           child: DropdownButton<String>(
//             value: selectedCurrency,
//             isExpanded: true,
//             underline: const SizedBox(),
//             dropdownColor: AppColors.cardBackgroundDynamic(context),
//             style: TextStyle(
//               color: AppColors.textPrimaryDynamic(context),
//             ),
//             items: selectedCurrency != null
//                 ? [
//               DropdownMenuItem(
//                 value: selectedCurrency,
//                 child: Text(
//                   selectedCurrency!,
//                   style: TextStyle(
//                     color: AppColors.textPrimaryDynamic(context),
//                   ),
//                 ),
//               ),
//             ]
//                 : [],
//             onChanged: null,
//           ),
//         ),
//         SizedBox(height: 16.h),
//       ],
//     );
//   }
//
//   Widget buildLanguageDropdown() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "Language",
//           style: TextStyle(
//             color: AppColors.textPrimaryDynamic(context),
//           ),
//         ),
//         SizedBox(height: 8.h),
//         Container(
//           padding: EdgeInsets.symmetric(horizontal: 12.w),
//           decoration: BoxDecoration(
//             color: AppColors.inputFieldBgDynamic(context),
//             borderRadius: BorderRadius.circular(12.r),
//             border: Border.all(
//               color: AppColors.borderDynamic(context),
//             ),
//           ),
//           child: languages.isEmpty
//               ? Padding(
//             padding: EdgeInsets.all(12.w),
//             child: Text(
//               "No Language Found",
//               style: TextStyle(
//                 color: AppColors.textSecondaryDynamic(context),
//               ),
//             ),
//           )
//               : DropdownButton<DropdownItem>(
//             value: language,
//             isExpanded: true,
//             underline: const SizedBox(),
//             dropdownColor: AppColors.cardBackgroundDynamic(context),
//             style: TextStyle(
//               color: AppColors.textPrimaryDynamic(context),
//             ),
//             iconEnabledColor: AppColors.textPrimaryDynamic(context),
//             items: languages.map((e) {
//               return DropdownMenuItem(
//                 value: e,
//                 child: Text(
//                   e.name,
//                   style: TextStyle(
//                     color: AppColors.textPrimaryDynamic(context),
//                   ),
//                 ),
//               );
//             }).toList(),
//             onChanged: (val) {
//               if (val == null) return;
//               setState(() {
//                 language = val;
//               });
//             },
//           ),
//         ),
//         SizedBox(height: 16.h),
//       ],
//     );
//   }
//
//   Widget step2() {
//     return Padding(
//       padding: EdgeInsets.all(16.w),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(height: 20.h),
//           buildUploadBox("ID Card (Front)", frontImage, () => openCamera(true)),
//           buildUploadBox("ID Card (Back)", backImage, () => openCamera(false)),
//         ],
//       ),
//     );
//   }
//
//   Widget step3() {
//     return Padding(
//       padding: EdgeInsets.all(16.w),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Divider(color: AppColors.borderDynamic(context)),
//           SizedBox(height: 20.h),
//           buildSelfieBox(),
//           const Spacer(),
//           SizedBox(
//             width: double.infinity,
//             height: 55.h,
//             child: ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: isSelfieUploaded
//                     ? AppColors.primary
//                     : AppColors.disableButtonColor,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30.r),
//                 ),
//               ),
//               onPressed: isSelfieUploaded
//                   ? () async {
//                 if (frontImage == null || backImage == null) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text("Upload ID images first"),
//                       backgroundColor: AppColors.snackbarErrorDynamic(context),
//                     ),
//                   );
//                   return;
//                 }
//
//                 await submitKyc();
//                 if (!mounted) return;
//
//                 Navigator.pushAndRemoveUntil(
//                   context,
//                   MaterialPageRoute(builder: (_) => MainScreen()),
//                       (route) => false,
//                 );
//               }
//                   : null,
//               child: Text(
//                 "Verify my account",
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget buildUploadBox(String title, File? image, VoidCallback onTap) {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: TextStyle(
//             color: AppColors.textPrimaryDynamic(context),
//           ),
//         ),
//         SizedBox(height: 8.h),
//         GestureDetector(
//           onTap: onTap,
//           child: Container(
//             height: 120.h,
//             width: double.infinity,
//             decoration: BoxDecoration(
//               color: AppColors.inputFieldBgDynamic(context),
//               borderRadius: BorderRadius.circular(12.r),
//               border: Border.all(
//                 color: AppColors.borderDynamic(context),
//               ),
//             ),
//             child: image != null
//                 ? ClipRRect(
//               borderRadius: BorderRadius.circular(12.r),
//               child: Image.file(image, fit: BoxFit.cover),
//             )
//                 : Icon(
//               Icons.add_a_photo,
//               size: 40.sp,
//               color: AppColors.textSecondaryDynamic(context),
//             ),
//           ),
//         ),
//         SizedBox(height: 16.h),
//       ],
//     );
//   }
//
//   Future<void> openCamera(bool isFront) async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => CameraScreen(isFront: isFront)),
//     );
//
//     if (!mounted) return;
//
//     if (result != null) {
//       setState(() {
//         if (isFront) {
//           frontImage = File(result);
//           isFrontUploaded = true;
//         } else {
//           backImage = File(result);
//           isBackUploaded = true;
//         }
//       });
//     }
//   }
//
//   Widget buildSelfieBox() {
//     return GestureDetector(
//       onTap: openSelfieCamera,
//       child: Container(
//         height: 140.h,
//         width: double.infinity,
//         decoration: BoxDecoration(
//           color: AppColors.inputFieldBgDynamic(context),
//           borderRadius: BorderRadius.circular(12.r),
//           border: Border.all(
//             color: AppColors.borderDynamic(context),
//           ),
//         ),
//         child: selfieImage != null
//             ? ClipRRect(
//           borderRadius: BorderRadius.circular(12.r),
//           child: Image.file(selfieImage!, fit: BoxFit.cover),
//         )
//             : Icon(
//           Icons.add_a_photo,
//           size: 40.sp,
//           color: AppColors.textSecondaryDynamic(context),
//         ),
//       ),
//     );
//   }
//
//   Future<void> openSelfieCamera() async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => SelfieCameraScreen()),
//     );
//
//     if (!mounted) return;
//
//     if (result != null) {
//       setState(() {
//         selfieImage = File(result);
//         isSelfieUploaded = true;
//       });
//     }
//   }
// }
//
// class DropdownItem {
//   final int id;
//   final String name;
//
//   DropdownItem({required this.id, required this.name});
// }
// import 'dart:convert';
// import 'dart:io';
// import 'package:betrade/core/theme/app_colors.dart';
// import 'package:betrade/presentation/screens/verification/step_heder.dart';
// import 'package:betrade/presentation/widget/purple_button.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import '../../../core/config/api_endpoint..dart';
// import '../../../data/model/country_model.dart';
// import '../../../data/services/local_storage.dart';
// import '../camera/camera_screen.dart';
// import '../camera/selfie_camera.dart';
// import '../main_screen.dart';
// import 'country_services_step_one.dart';
//
// class VerificationFlow extends StatefulWidget {
//   @override
//   State<VerificationFlow> createState() => _VerificationFlowState();
// }
//
// class _VerificationFlowState extends State<VerificationFlow> {
//   int currentStep = 0;
//   File? selfieImage;
//   bool isSelfieUploaded = false;
//   File? frontImage;
//   File? backImage;
//   bool isLoading = true;
//   bool isFrontUploaded = false;
//   bool isBackUploaded = false;
//   bool isSubmittingKyc = false; // ✅ New loading state for KYC submit
//
//   final ImagePicker picker = ImagePicker();
//   List<CountryModel> countries = [];
//   CountryModel? selectedCountry;
//   List<DropdownItem> languages = [];
//   DropdownItem? language;
//   String? selectedCurrency;
//
//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(() {
//       loadAllData();
//     });
//   }
//
//   Future<void> loadAllData() async {
//     try {
//       if (!mounted) return;
//       setState(() => isLoading = true);
//
//       final countryRes = await CountryService.fetchCountries();
//
//       if (!mounted) return;
//
//       countries = countryRes;
//
//       if (countries.isNotEmpty) {
//         selectedCountry = countries.first;
//         selectedCurrency = selectedCountry?.currency;
//       }
//
//       final token = LocalStorage.getToken();
//
//       final response = await http.get(
//         Uri.parse(ApiEndpoints.languages),
//         headers: {
//           "Accept": "application/json",
//           "Authorization": "Bearer $token",
//         },
//       );
//
//       if (!mounted) return;
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final List list = data['data'];
//
//         languages = list
//             .map((e) => DropdownItem(id: e['id'], name: e['name']))
//             .toList();
//
//         if (languages.isNotEmpty) {
//           language = languages.first;
//         }
//       }
//
//       if (!mounted) return;
//
//       setState(() => isLoading = false);
//     } catch (e) {
//       if (!mounted) return;
//       setState(() => isLoading = false);
//     }
//   }
//
//   bool isStep2Valid() {
//     return frontImage != null && backImage != null;
//   }
//
//   Future<void> submitKyc() async {
//     if (isSubmittingKyc) return; // ✅ Prevent multiple submissions
//
//     try {
//       if (frontImage == null || backImage == null || selfieImage == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Please upload all images"),
//             backgroundColor: AppColors.snackbarErrorDynamic(context),
//           ),
//         );
//         return;
//       }
//
//       setState(() {
//         isSubmittingKyc = true; // ✅ Show loader
//       });
//
//       final token = LocalStorage.getToken();
//
//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse(ApiEndpoints.kycSubmit),
//       );
//
//       request.headers.addAll({
//         "Authorization": "Bearer $token",
//         "Accept": "application/json",
//       });
//
//       request.files.add(await http.MultipartFile.fromPath(
//         'id_front',
//         frontImage!.path,
//       ));
//
//       request.files.add(await http.MultipartFile.fromPath(
//         'id_back',
//         backImage!.path,
//       ));
//
//       request.files.add(await http.MultipartFile.fromPath(
//         'selfie',
//         selfieImage!.path,
//       ));
//
//       var response = await request.send();
//       var responseData = await response.stream.bytesToString();
//
//       print("KYC RESPONSE: $responseData");
//
//       if (!mounted) return;
//
//       if (response.statusCode == 200) {
//         print("✅ KYC SUCCESS");
//
//         // ✅ Show success message
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("KYC submitted successfully!"),
//             backgroundColor: AppColors.snackbarSuccessDynamic(context),
//           ),
//         );
//
//         // ✅ Navigate to home
//         Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(builder: (_) => MainScreen()),
//               (route) => false,
//         );
//       } else {
//         print("❌ KYC FAILED");
//
//         // ✅ Show error message
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("KYC submission failed. Please try again."),
//             backgroundColor: AppColors.snackbarErrorDynamic(context),
//           ),
//         );
//       }
//     } catch (e) {
//       print("KYC ERROR: $e");
//       if (!mounted) return;
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("An error occurred. Please try again."),
//           backgroundColor: AppColors.snackbarErrorDynamic(context),
//         ),
//       );
//     } finally {
//       if (mounted) {
//         setState(() {
//           isSubmittingKyc = false; // ✅ Hide loader
//         });
//       }
//     }
//   }
//
//   Future<void> submitStep1() async {
//     try {
//       final token = LocalStorage.getToken();
//       final url = Uri.parse(ApiEndpoints.preferences);
//       final response = await http.post(
//         url,
//         headers: {
//           "Accept": "application/json",
//           "Authorization": "Bearer $token",
//           "Content-Type": "application/json",
//         },
//         body: jsonEncode({
//           "country_id": selectedCountry?.id,
//           "preferred_language_id": language?.id,
//         }),
//       );
//
//       print("STEP1 RESPONSE: ${response.body}");
//     } catch (e) {
//       print("API Error: $e");
//     }
//   }
//
//   bool isStepValid() {
//     return selectedCountry != null && language != null;
//   }
//
//   void nextStep() async {
//     if (currentStep == 0) {
//       await submitStep1();
//     }
//
//     if (currentStep < 2) {
//       setState(() {
//         currentStep++;
//       });
//     }
//   }
//
//   Widget buildStepContent() {
//     switch (currentStep) {
//       case 0:
//         return step1();
//       case 1:
//         return step2();
//       case 2:
//         return step3();
//       default:
//         return step1();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
//
//     return Material(
//       color: AppColors.cardBackgroundDynamic(context),
//       child: SafeArea(
//         child: Column(
//           children: [
//             Container(
//               margin: EdgeInsets.symmetric(vertical: 10.h),
//               height: 5.h,
//               width: 50.w,
//               decoration: BoxDecoration(
//                 color: AppColors.borderDynamic(context),
//                 borderRadius: BorderRadius.circular(10.r),
//               ),
//             ),
//             StepHeader(currentStep: currentStep),
//             Expanded(
//               child: isLoading
//                   ? Center(
//                 child: CircularProgressIndicator(
//                   color: AppColors.primary,
//                 ),
//               )
//                   : buildStepContent(),
//             ),
//             if (currentStep != 2)
//               Padding(
//                 padding: EdgeInsets.all(16.w),
//                 child: SizedBox(
//                   height: 55.h,
//                   width: double.infinity,
//                   child: Button(
//                     title: "Next",
//                     onPressed: () {
//                       if (currentStep == 0 && isStepValid()) {
//                         nextStep();
//                       } else if (currentStep == 1 && isStep2Valid()) {
//                         nextStep();
//                       }
//                     },
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget step1() {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 16.w),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Divider(color: AppColors.borderDynamic(context)),
//           SizedBox(height: 20.h),
//           buildCountryDropdown(),
//           buildCurrencyDropdown(),
//           buildLanguageDropdown(),
//         ],
//       ),
//     );
//   }
//
//   Widget buildCountryDropdown() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "Country",
//           style: TextStyle(
//             color: AppColors.textPrimaryDynamic(context),
//           ),
//         ),
//         SizedBox(height: 8.h),
//         Container(
//           padding: EdgeInsets.symmetric(horizontal: 12.w),
//           decoration: BoxDecoration(
//             color: AppColors.inputFieldBgDynamic(context),
//             borderRadius: BorderRadius.circular(12.r),
//             border: Border.all(
//               color: AppColors.borderDynamic(context),
//             ),
//           ),
//           child: DropdownButton<CountryModel>(
//             value: countries.contains(selectedCountry) ? selectedCountry : null,
//             isExpanded: true,
//             underline: const SizedBox(),
//             dropdownColor: AppColors.cardBackgroundDynamic(context),
//             style: TextStyle(
//               color: AppColors.textPrimaryDynamic(context),
//             ),
//             iconEnabledColor: AppColors.textPrimaryDynamic(context),
//             items: countries.map((e) {
//               return DropdownMenuItem(
//                 value: e,
//                 child: Row(
//                   children: [
//                     Text(e.flag, style: TextStyle(fontSize: 16.sp)),
//                     SizedBox(width: 8.w),
//                     Text(
//                       e.name,
//                       style: TextStyle(
//                         color: AppColors.textPrimaryDynamic(context),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }).toList(),
//             onChanged: (val) {
//               if (val == null) return;
//               setState(() {
//                 selectedCountry = val;
//                 selectedCurrency = val.currency;
//               });
//             },
//           ),
//         ),
//         SizedBox(height: 16.h),
//       ],
//     );
//   }
//
//   Widget buildCurrencyDropdown() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "Currency",
//           style: TextStyle(
//             color: AppColors.textPrimaryDynamic(context),
//           ),
//         ),
//         SizedBox(height: 8.h),
//         Container(
//           padding: EdgeInsets.symmetric(horizontal: 12.w),
//           decoration: BoxDecoration(
//             color: AppColors.inputFieldBgDynamic(context),
//             borderRadius: BorderRadius.circular(12.r),
//             border: Border.all(
//               color: AppColors.borderDynamic(context),
//             ),
//           ),
//           child: DropdownButton<String>(
//             value: selectedCurrency,
//             isExpanded: true,
//             underline: const SizedBox(),
//             dropdownColor: AppColors.cardBackgroundDynamic(context),
//             style: TextStyle(
//               color: AppColors.textPrimaryDynamic(context),
//             ),
//             items: selectedCurrency != null
//                 ? [
//               DropdownMenuItem(
//                 value: selectedCurrency,
//                 child: Text(
//                   selectedCurrency!,
//                   style: TextStyle(
//                     color: AppColors.textPrimaryDynamic(context),
//                   ),
//                 ),
//               ),
//             ]
//                 : [],
//             onChanged: null,
//           ),
//         ),
//         SizedBox(height: 16.h),
//       ],
//     );
//   }
//
//   Widget buildLanguageDropdown() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "Language",
//           style: TextStyle(
//             color: AppColors.textPrimaryDynamic(context),
//           ),
//         ),
//         SizedBox(height: 8.h),
//         Container(
//           padding: EdgeInsets.symmetric(horizontal: 12.w),
//           decoration: BoxDecoration(
//             color: AppColors.inputFieldBgDynamic(context),
//             borderRadius: BorderRadius.circular(12.r),
//             border: Border.all(
//               color: AppColors.borderDynamic(context),
//             ),
//           ),
//           child: languages.isEmpty
//               ? Padding(
//             padding: EdgeInsets.all(12.w),
//             child: Text(
//               "No Language Found",
//               style: TextStyle(
//                 color: AppColors.textSecondaryDynamic(context),
//               ),
//             ),
//           )
//               : DropdownButton<DropdownItem>(
//             value: language,
//             isExpanded: true,
//             underline: const SizedBox(),
//             dropdownColor: AppColors.cardBackgroundDynamic(context),
//             style: TextStyle(
//               color: AppColors.textPrimaryDynamic(context),
//             ),
//             iconEnabledColor: AppColors.textPrimaryDynamic(context),
//             items: languages.map((e) {
//               return DropdownMenuItem(
//                 value: e,
//                 child: Text(
//                   e.name,
//                   style: TextStyle(
//                     color: AppColors.textPrimaryDynamic(context),
//                   ),
//                 ),
//               );
//             }).toList(),
//             onChanged: (val) {
//               if (val == null) return;
//               setState(() {
//                 language = val;
//               });
//             },
//           ),
//         ),
//         SizedBox(height: 16.h),
//       ],
//     );
//   }
//
//   Widget step2() {
//     return Padding(
//       padding: EdgeInsets.all(16.w),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(height: 20.h),
//           buildUploadBox("ID Card (Front)", frontImage, () => openCamera(true)),
//           buildUploadBox("ID Card (Back)", backImage, () => openCamera(false)),
//         ],
//       ),
//     );
//   }
//
//   Widget step3() {
//     return Padding(
//       padding: EdgeInsets.all(16.w),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Divider(color: AppColors.borderDynamic(context)),
//           SizedBox(height: 20.h),
//           buildSelfieBox(),
//           const Spacer(),
//           SizedBox(
//             width: double.infinity,
//             height: 55.h,
//             child: ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: isSelfieUploaded && !isSubmittingKyc
//                     ? AppColors.primary
//                     : AppColors.disableButtonColor,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30.r),
//                 ),
//               ),
//               onPressed: (isSelfieUploaded && !isSubmittingKyc)
//                   ? () async {
//                 if (frontImage == null || backImage == null) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text("Upload ID images first"),
//                       backgroundColor: AppColors.snackbarErrorDynamic(context),
//                     ),
//                   );
//                   return;
//                 }
//
//                 await submitKyc();
//               }
//                   : null,
//               child: isSubmittingKyc
//                   ? SizedBox(
//                 height: 24.h,
//                 width: 24.h,
//                 child: const CircularProgressIndicator(
//                   strokeWidth: 2.5,
//                   color: Colors.white,
//                 ),
//               )
//                   : Text(
//                 "Verify my account",
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget buildUploadBox(String title, File? image, VoidCallback onTap) {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: TextStyle(
//             color: AppColors.textPrimaryDynamic(context),
//           ),
//         ),
//         SizedBox(height: 8.h),
//         GestureDetector(
//           onTap: onTap,
//           child: Container(
//             height: 120.h,
//             width: double.infinity,
//             decoration: BoxDecoration(
//               color: AppColors.inputFieldBgDynamic(context),
//               borderRadius: BorderRadius.circular(12.r),
//               border: Border.all(
//                 color: AppColors.borderDynamic(context),
//               ),
//             ),
//             child: image != null
//                 ? ClipRRect(
//               borderRadius: BorderRadius.circular(12.r),
//               child: Image.file(image, fit: BoxFit.cover),
//             )
//                 : Icon(
//               Icons.add_a_photo,
//               size: 40.sp,
//               color: AppColors.textSecondaryDynamic(context),
//             ),
//           ),
//         ),
//         SizedBox(height: 16.h),
//       ],
//     );
//   }
//
//   Future<void> openCamera(bool isFront) async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => CameraScreen(isFront: isFront)),
//     );
//
//     if (!mounted) return;
//
//     if (result != null) {
//       setState(() {
//         if (isFront) {
//           frontImage = File(result);
//           isFrontUploaded = true;
//         } else {
//           backImage = File(result);
//           isBackUploaded = true;
//         }
//       });
//     }
//   }
//
//   Widget buildSelfieBox() {
//     return GestureDetector(
//       onTap: openSelfieCamera,
//       child: Container(
//         height: 140.h,
//         width: double.infinity,
//         decoration: BoxDecoration(
//           color: AppColors.inputFieldBgDynamic(context),
//           borderRadius: BorderRadius.circular(12.r),
//           border: Border.all(
//             color: AppColors.borderDynamic(context),
//           ),
//         ),
//         child: selfieImage != null
//             ? ClipRRect(
//           borderRadius: BorderRadius.circular(12.r),
//           child: Image.file(selfieImage!, fit: BoxFit.cover),
//         )
//             : Icon(
//           Icons.add_a_photo,
//           size: 40.sp,
//           color: AppColors.textSecondaryDynamic(context),
//         ),
//       ),
//     );
//   }
//
//   Future<void> openSelfieCamera() async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => SelfieCameraScreen()),
//     );
//
//     if (!mounted) return;
//
//     if (result != null) {
//       setState(() {
//         selfieImage = File(result);
//         isSelfieUploaded = true;
//       });
//     }
//   }
// }
//
// class DropdownItem {
//   final int id;
//   final String name;
//
//   DropdownItem({required this.id, required this.name});
// }



import 'dart:convert';
import 'dart:io';
import 'package:betrade/core/theme/app_colors.dart';
import 'package:betrade/core/theme/app_text_style.dart';
import 'package:betrade/presentation/screens/verification/step_heder.dart';
import 'package:betrade/presentation/widget/purple_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/config/api_endpoint..dart';
import '../../../data/model/country_model.dart';
import '../../../data/services/local_storage.dart';
import '../camera/camera_screen.dart';
import '../camera/selfie_camera.dart';
import '../main_screen.dart';
import 'country_services_step_one.dart';

class VerificationFlow extends StatefulWidget {
  @override
  State<VerificationFlow> createState() => _VerificationFlowState();
}

class _VerificationFlowState extends State<VerificationFlow> {
  int currentStep = 0;
  File? selfieImage;
  bool isSelfieUploaded = false;
  File? frontImage;
  File? backImage;
  bool isLoading = true;
  bool isFrontUploaded = false;
  bool isBackUploaded = false;
  bool isSubmittingKyc = false;
  bool _isDisposed = false;
  bool _isNavigating = false;

  final ImagePicker picker = ImagePicker();
  List<CountryModel> countries = [];
  CountryModel? selectedCountry;
  List<DropdownItem> languages = [];
  DropdownItem? language;
  String? selectedCurrency;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!_isDisposed && mounted) {
        loadAllData();
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _safeSetState(VoidCallback fn) {
    if (!_isDisposed && mounted) {
      setState(fn);
    }
  }

  dynamic _safeJsonDecode(String body) {
    try {
      return jsonDecode(body);
    } catch (e) {
      debugPrint("❌ JSON decode error: $e");
      return null;
    }
  }

  // ✅ FIX #1: Safe data extraction
  dynamic _safeGetData(dynamic data, String key) {
    try {
      if (data != null && data is Map<String, dynamic>) {
        return data[key];
      }
      return null;
    } catch (e) {
      debugPrint("❌ Data extraction error: $e");
      return null;
    }
  }

  Future<void> loadAllData() async {
    if (_isDisposed) return;

    try {
      _safeSetState(() => isLoading = true);

      final countryRes = await CountryService.fetchCountries();
      if (!_isDisposed && mounted) {
        countries = countryRes ?? [];
        if (countries.isNotEmpty) {
          selectedCountry = countries.first;
          selectedCurrency = selectedCountry?.currency;
        }
      }

      final token = LocalStorage.getToken();
      if (token == null) {
        _safeSetState(() => isLoading = false);
        return;
      }

      final response = await http.get(
        Uri.parse(ApiEndpoints.languages),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      ).timeout(const Duration(seconds: 30));

      if (!_isDisposed && mounted && response.statusCode == 200) {
        final data = _safeJsonDecode(response.body);
        final dataList = _safeGetData(data, 'data');

        if (dataList is List) {
          languages = dataList
              .where((e) => e != null && e is Map)
              .map((e) => DropdownItem(
            id: (e['id'] ?? 0) as int,
            name: (e['name'] ?? '') as String,
          ))
              .toList();
          if (languages.isNotEmpty) {
            language = languages.first;
          }
        }
      }

      if (!_isDisposed && mounted) {
        _safeSetState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("❌ Load data error: $e");
      if (!_isDisposed && mounted) {
        _safeSetState(() => isLoading = false);
        _showError("Failed to load data");
      }
    }
  }

  void _showError(String message) {
    if (_isDisposed || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showSuccess(String message) {
    if (_isDisposed || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  bool isStep2Valid() {
    return frontImage != null && backImage != null;
  }

  Future<http.MultipartFile?> _safeMultipartFile(String field, File file) async {
    try {
      if (!await file.exists()) {
        debugPrint("❌ File does not exist: ${file.path}");
        return null;
      }
      return await http.MultipartFile.fromPath(field, file.path);
    } catch (e) {
      debugPrint("❌ MultipartFile error: $e");
      return null;
    }
  }
  void _safeNavigateToHome() {
    if (_isDisposed || !mounted || _isNavigating) return;
    _isNavigating = true;
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!_isDisposed && mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
              (route) => false,
        );
      }
    });
  }

  Future<void> submitKyc() async {
    if (isSubmittingKyc || _isDisposed) return;

    if (frontImage == null || backImage == null || selfieImage == null) {
      _showError("Please upload all images");
      return;
    }

    _safeSetState(() => isSubmittingKyc = true);

    try {
      final token = LocalStorage.getToken();
      if (token == null) {
        _showError("Authentication failed");
        return;
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiEndpoints.kycSubmit),
      );

      request.headers.addAll({
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      });

      final frontFile = await _safeMultipartFile('id_front', frontImage!);
      final backFile = await _safeMultipartFile('id_back', backImage!);
      final selfieFile = await _safeMultipartFile('selfie', selfieImage!);

      if (frontFile == null || backFile == null || selfieFile == null) {
        _showError("Failed to prepare files. Please try again.");
        return;
      }

      request.files.add(frontFile);
      request.files.add(backFile);
      request.files.add(selfieFile);

      final response = await request.send();
      var responseData = await response.stream.bytesToString();

      debugPrint("KYC RESPONSE: $responseData");

      if (!_isDisposed && mounted) {
        if (response.statusCode == 200) {
          _showSuccess("KYC submitted successfully!");
          _safeNavigateToHome();
        } else {
          _showError("KYC submission failed. Please try again.");
        }
      }
    } catch (e) {
      debugPrint("KYC ERROR: $e");
      if (!_isDisposed && mounted) {
        _showError("An error occurred. Please try again.");
      }
    } finally {
      if (!_isDisposed && mounted) {
        _safeSetState(() => isSubmittingKyc = false);
      }
    }
  }

  Future<void> submitStep1() async {
    if (_isDisposed) return;

    try {
      final token = LocalStorage.getToken();
      if (token == null) return;

      final url = Uri.parse(ApiEndpoints.preferences);
      await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "country_id": selectedCountry?.id,
          "preferred_language_id": language?.id,
        }),
      ).timeout(const Duration(seconds: 30));
    } catch (e) {
      debugPrint("API Error: $e");
    }
  }

  bool isStepValid() {
    return selectedCountry != null && language != null;
  }

  void nextStep() async {
    if (_isDisposed) return;

    if (currentStep == 0) {
      await submitStep1();
    }
    if (currentStep < 2 && mounted) {
      _safeSetState(() => currentStep++);
    }
  }

  Widget _safeImage(File? file, {double? height, double? width}) {
    if (file == null) {
      return Icon(
        Icons.add_a_photo,
        size: 40.sp,
        color: AppColors.textSecondaryDynamic(context),
      );
    }

    return Image.file(
      file,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        debugPrint("❌ Image decode error: $error");
        return Icon(
          Icons.broken_image,
          size: 40.sp,
          color: AppColors.textSecondaryDynamic(context),
        );
      },
    );
  }

  Future<bool> _requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      if (status.isGranted) return true;
      if (status.isPermanentlyDenied) {
        if (mounted) {
          _showPermissionDeniedDialog();
        }
        return false;
      }
      return false;
    } catch (e) {
      debugPrint("❌ Permission error: $e");
      return false;
    }
  }

  void _showPermissionDeniedDialog() {
    if (_isDisposed || !mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Camera Permission Required"),
        content: const Text("Please enable camera access in Settings to take photos."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }

  Future<void> openCamera(bool isFront) async {
    if (_isDisposed || !mounted) return;

    final hasPermission = await _requestCameraPermission();
    if (!hasPermission) return;

    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CameraScreen(isFront: isFront)),
      );

      if (!_isDisposed && mounted && result != null) {
        _safeSetState(() {
          if (isFront) {
            frontImage = File(result);
            isFrontUploaded = true;
          } else {
            backImage = File(result);
            isBackUploaded = true;
          }
        });
      }
    } catch (e) {
      debugPrint("❌ Camera error: $e");
      _showError("Failed to capture image");
    }
  }

  Future<void> openSelfieCamera() async {
    if (_isDisposed || !mounted) return;

    final hasPermission = await _requestCameraPermission();
    if (!hasPermission) return;

    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SelfieCameraScreen()),
      );

      if (!_isDisposed && mounted && result != null) {
        _safeSetState(() {
          selfieImage = File(result);
          isSelfieUploaded = true;
        });
      }
    } catch (e) {
      debugPrint("❌ Selfie camera error: $e");
      _showError("Failed to capture selfie");
    }
  }

  Widget buildStepContent() {
    switch (currentStep) {
      case 0: return step1();
      case 1: return step2();
      case 2: return step3();
      default: return step1();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isDisposed) return const SizedBox();

    return Material(
      color: AppColors.cardBackgroundDynamic(context),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 10.h),
              height: 5.h,
              width: 50.w,
              decoration: BoxDecoration(
                color: AppColors.borderDynamic(context),
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            StepHeader(currentStep: currentStep),
            Expanded(
              child: isLoading
                  ? Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              )
                  : buildStepContent(),
            ),
            if (currentStep != 2)
              Padding(
                padding: EdgeInsets.all(16.w),
                child: SizedBox(
                  height: 55.h,
                  width: double.infinity,
                  child: Button(
                    title: "Next",
                    onPressed: () {
                      if (currentStep == 0 && isStepValid()) {
                        nextStep();
                      } else if (currentStep == 1 && isStep2Valid()) {
                        nextStep();
                      }
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget step1() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: AppColors.borderDynamic(context)),
          SizedBox(height: 20.h),
          buildCountryDropdown(),
          buildCurrencyDropdown(),
          buildLanguageDropdown(),
        ],
      ),
    );
  }

  Widget buildCountryDropdown() {
    // Check if selectedCountry exists in countries list
    final validCountry = countries.any((c) => c.id == selectedCountry?.id)
        ? selectedCountry
        : (countries.isNotEmpty ? countries.first : null);

    if (validCountry != selectedCountry && validCountry != null) {
      selectedCountry = validCountry;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Country", style:AppTextStyle.smallNav),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: AppColors.inputFieldBgDynamic(context),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.borderDynamic(context)),
          ),
          child: DropdownButton<CountryModel>(
            value: validCountry,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: AppColors.cardBackgroundDynamic(context),
            style: TextStyle(color: AppColors.textPrimaryDynamic(context)),
            items: countries.map((e) {
              return DropdownMenuItem(
                value: e,
                child: Row(
                  children: [
                    Text(e.flag ?? '🏳️', style: TextStyle(fontSize: 16.sp)),
                    SizedBox(width: 8.w),
                    Text(e.name ?? 'Unknown'),
                  ],
                ),
              );
            }).toList(),
            onChanged: (val) {
              if (val == null) return;
              _safeSetState(() {
                selectedCountry = val;
                selectedCurrency = val.currency;
              });
            },
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget buildCurrencyDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Currency", style:AppTextStyle.smallNav),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: AppColors.inputFieldBgDynamic(context),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.borderDynamic(context)),
          ),
          child: DropdownButton<String>(
            value: selectedCurrency,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: AppColors.cardBackgroundDynamic(context),
            style: TextStyle(color: AppColors.textPrimaryDynamic(context)),
            items: selectedCurrency != null
                ? [DropdownMenuItem(value: selectedCurrency, child: Text(selectedCurrency!))]
                : [],
            onChanged: null,
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget buildLanguageDropdown() {
    // ✅ FIX #4: Safe language dropdown with validation
    final validLanguage = languages.any((l) => l.id == language?.id)
        ? language
        : (languages.isNotEmpty ? languages.first : null);

    if (validLanguage != language && validLanguage != null) {
      language = validLanguage;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Language", style:AppTextStyle.smallNav),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: AppColors.inputFieldBgDynamic(context),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.borderDynamic(context)),
          ),
          child: languages.isEmpty
              ? Padding(
            padding: EdgeInsets.all(12.w),
            child: Text("No Language Found"),
          )
              : DropdownButton<DropdownItem>(
            value: validLanguage,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: AppColors.cardBackgroundDynamic(context),
            style: TextStyle(color: AppColors.textPrimaryDynamic(context)),
            items: languages.map((e) {
              return DropdownMenuItem(
                value: e,
                child: Text(e.name),
              );
            }).toList(),
            onChanged: (val) {
              if (val == null) return;
              _safeSetState(() => language = val);
            },
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget step2() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20.h),
          buildUploadBox("ID Card (Front)", frontImage, () => openCamera(true)),
          buildUploadBox("ID Card (Back)", backImage, () => openCamera(false)),
        ],
      ),
    );
  }

  Widget step3() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: AppColors.borderDynamic(context)),
          SizedBox(height: 20.h),
          buildSelfieBox(),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 55.h,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelfieUploaded && !isSubmittingKyc
                    ? AppColors.primary
                    : AppColors.disableButtonColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
              onPressed: (isSelfieUploaded && !isSubmittingKyc)
                  ? () async {
                if (frontImage == null || backImage == null) {
                  _showError("Upload ID images first");
                  return;
                }
                await submitKyc();
              }
                  : null,
              child: isSubmittingKyc
                  ? SizedBox(
                height: 24.h,
                width: 24.h,
                child: const CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
                  : Text("Verify my account", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildUploadBox(String title, File? image, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style:AppTextStyle.smallNav),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 120.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.inputFieldBgDynamic(context),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.borderDynamic(context)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: _safeImage(image),
            ),
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget buildSelfieBox() {
    return GestureDetector(
      onTap: openSelfieCamera,
      child: Container(
        height: 140.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.inputFieldBgDynamic(context),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.borderDynamic(context)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: _safeImage(selfieImage),
        ),
      ),
    );
  }
}

class DropdownItem {
  final int id;
  final String name;
  DropdownItem({required this.id, required this.name});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DropdownItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}