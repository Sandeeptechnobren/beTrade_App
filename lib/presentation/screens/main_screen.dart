// // // import 'package:betrade/core/theme/app_text_style.dart';
// // // import 'package:betrade/presentation/screens/explore/explore_page.dart';
// // // import 'package:betrade/presentation/screens/homeScreen/HomeScreen.dart';
// // // import 'package:betrade/presentation/screens/portfolio/portfolio_page.dart';
// // // import 'package:betrade/presentation/screens/profile/info_chart_screen.dart';
// // // import 'package:betrade/presentation/screens/profile/profile_page.dart';
// // // import 'package:betrade/presentation/screens/verification/verify_account.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:flutter_screenutil/flutter_screenutil.dart';
// // // import 'package:provider/provider.dart';
// // // import '../../core/theme/app_colors.dart';
// // // import '../../data/provider/profile_provider.dart';
// // // import '../bottom_navigation/bottom_nav.dart';
// // //
// // // class MainScreen extends StatefulWidget {
// // //   final bool showWelcomePopup;
// // //
// // //   const MainScreen({super.key, this.showWelcomePopup = false});
// // //
// // //   @override
// // //   State<MainScreen> createState() => _MainScreenState();
// // // }
// // //
// // // class _MainScreenState extends State<MainScreen> {
// // //   int currentIndex = 0;
// // //   String firstName = "User"; // Default value
// // //
// // //   final screens = [
// // //     HomeScreen(),
// // //     ExplorePage(),
// // //     InfoChartScreen(),
// // //     PortfolioPage(),
// // //     ProfilePage(),
// // //   ];
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //
// // //     // Fetch profile data when screen loads
// // //     WidgetsBinding.instance.addPostFrameCallback((_) {
// // //       Provider.of<ProfileProvider>(context, listen: false).fetchProfile();
// // //       _getFirstNameFromProfile();
// // //     });
// // //
// // //     if (widget.showWelcomePopup) {
// // //       WidgetsBinding.instance.addPostFrameCallback((_) {
// // //         _showWelcomePopup();
// // //       });
// // //     }
// // //   }
// // //
// // //   void _getFirstNameFromProfile() {
// // //     final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
// // //     final profile = profileProvider.profile;
// // //
// // //     if (profile != null && profile.firstName.isNotEmpty) {
// // //       setState(() {
// // //         firstName = profile.firstName;
// // //       });
// // //     }
// // //   }
// // //
// // //   void _showWelcomePopup() {
// // //     showDialog(
// // //       context: context,
// // //       barrierDismissible: false,
// // //       builder: (context) {
// // //         return Dialog(
// // //           backgroundColor: Colors.white,
// // //           insetPadding: EdgeInsets.all(10.w),
// // //           elevation: 4,
// // //           shape: RoundedRectangleBorder(
// // //             borderRadius: BorderRadius.circular(20.r),
// // //           ),
// // //           child: Padding(
// // //             padding: EdgeInsets.all(20.w),
// // //             child: Column(
// // //               mainAxisSize: MainAxisSize.min,
// // //               children: [
// // //                 Text(
// // //                   "Welcome aboard, $firstName 🎉",
// // //                   style: AppTextStyle.subHeading,
// // //                 ),
// // //                 SizedBox(height: 10.h),
// // //                 Text(
// // //                   "Your account is ready. Let's quickly verify your details so you can start trading and withdraw your winnings.",
// // //                   textAlign: TextAlign.center,
// // //                   style: TextStyle(
// // //                     fontSize: 13.sp,
// // //                     color: Colors.grey,
// // //                     fontFamily: 'SFProRounded',
// // //                   ),
// // //                 ),
// // //                 SizedBox(height: 20.h),
// // //                 GestureDetector(
// // //                   onTap: () {
// // //                     Navigator.pop(context);
// // //                     showModalBottomSheet(
// // //                       context: context,
// // //                       isScrollControlled: true,
// // //                       backgroundColor: Colors.transparent,
// // //                       builder: (context) {
// // //                         return Padding(
// // //                           padding: EdgeInsets.only(
// // //                             left: 10.w,
// // //                             right: 10.w,
// // //                             top: 20.h,
// // //                             bottom: 20.h,
// // //                           ),
// // //                           child: ClipRRect(
// // //                             borderRadius: BorderRadius.only(
// // //                               topLeft: Radius.circular(20.r),
// // //                               topRight: Radius.circular(20.r),
// // //                               bottomLeft: Radius.circular(15.r),
// // //                               bottomRight: Radius.circular(15.r),
// // //                             ),
// // //                             child: Container(
// // //                               color: Colors.white,
// // //                               child: FractionallySizedBox(
// // //                                 heightFactor: 0.9,
// // //                                 child: VerificationFlow(),
// // //                               ),
// // //                             ),
// // //                           ),
// // //                         );
// // //                       },
// // //                     );
// // //                   },
// // //                   child: Container(
// // //                     width: double.infinity,
// // //                     padding: EdgeInsets.symmetric(vertical: 14.h),
// // //                     decoration: BoxDecoration(
// // //                       borderRadius: BorderRadius.circular(30.r),
// // //                       color: AppColors.primary,
// // //                     ),
// // //                     child: Center(
// // //                       child: Text(
// // //                         "Verify my account",
// // //                         style: TextStyle(
// // //                           fontSize: 14.sp,
// // //                           color: Colors.white,
// // //                           fontFamily: 'SFProRounded',
// // //                         ),
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 ),
// // //                 SizedBox(height: 10.h),
// // //                 GestureDetector(
// // //                   onTap: () {
// // //                     Navigator.pop(context);
// // //                   },
// // //                   child: Container(
// // //                     width: double.infinity,
// // //                     padding: EdgeInsets.symmetric(vertical: 14.h),
// // //                     alignment: Alignment.center,
// // //                     decoration: BoxDecoration(
// // //                       borderRadius: BorderRadius.circular(30.r),
// // //                       border: Border.all(
// // //                         width: 2.w,
// // //                         color: Colors.grey.shade200,
// // //                       ),
// // //                     ),
// // //                     child: Row(
// // //                       mainAxisAlignment: MainAxisAlignment.center,
// // //                       children: [
// // //                         Text(
// // //                           "Skip for now",
// // //                           style: TextStyle(
// // //                             fontSize: 14.sp,
// // //                             fontFamily: 'SFProRounded',
// // //                             color: Colors.black,
// // //                           ),
// // //                         ),
// // //                         SizedBox(width: 5.w),
// // //                         Icon(
// // //                           Icons.arrow_forward_ios_rounded,
// // //                           size: 16.sp,
// // //                         ),
// // //                       ],
// // //                     ),
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //           ),
// // //         );
// // //       },
// // //     );
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     // Listen to ProfileProvider for real-time updates
// // //     return Consumer<ProfileProvider>(
// // //       builder: (context, profileProvider, child) {
// // //         // Update first name when profile data is loaded
// // //         final profile = profileProvider.profile;
// // //         if (profile != null && profile.firstName.isNotEmpty && firstName != profile.firstName) {
// // //           WidgetsBinding.instance.addPostFrameCallback((_) {
// // //             setState(() {
// // //               firstName = profile.firstName;
// // //             });
// // //           });
// // //         }
// // //
// // //         return Scaffold(
// // //           body: IndexedStack(
// // //             index: currentIndex,
// // //             children: screens,
// // //           ),
// // //           bottomNavigationBar: CustomBottomNav(
// // //             currentIndex: currentIndex,
// // //             onTap: (index) {
// // //               setState(() {
// // //                 currentIndex = index;
// // //               });
// // //             },
// // //           ),
// // //         );
// // //       },
// // //     );
// // //   }
// // // }
// //
// // import 'package:betrade/core/theme/app_text_style.dart';
// // import 'package:betrade/presentation/screens/explore/explore_page.dart';
// // import 'package:betrade/presentation/screens/homeScreen/HomeScreen.dart';
// // import 'package:betrade/presentation/screens/portfolio/portfolio_page.dart';
// // import 'package:betrade/presentation/screens/profile/info_chart_screen.dart';
// // import 'package:betrade/presentation/screens/profile/profile_page.dart';
// // import 'package:betrade/presentation/screens/verification/verify_account.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_screenutil/flutter_screenutil.dart';
// // import 'package:provider/provider.dart';
// // import '../../core/theme/app_colors.dart';
// // import '../../data/provider/profile_provider.dart';
// // import '../bottom_navigation/bottom_nav.dart';
// //
// // class MainScreen extends StatefulWidget {
// //   final bool showWelcomePopup;
// //
// //   const MainScreen({super.key, this.showWelcomePopup = false});
// //
// //   @override
// //   State<MainScreen> createState() => _MainScreenState();
// // }
// //
// // class _MainScreenState extends State<MainScreen> {
// //   int currentIndex = 0;
// //   String firstName = "User";
// //
// //   final screens = [
// //     HomeScreen(),
// //     ExplorePage(),
// //     InfoChartScreen(),
// //     PortfolioPage(),
// //     ProfilePage(),
// //   ];
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       _getFirstNameFromArguments();
// //       if (firstName == "User") {
// //         _fetchProfileAndGetName();
// //       }
// //       if (widget.showWelcomePopup) {
// //         Future.delayed(Duration(milliseconds: 500), () {
// //           _showWelcomePopup();
// //         });
// //       }
// //     });
// //   }
// //
// //   void _getFirstNameFromArguments() {
// //     final args = ModalRoute.of(context)?.settings.arguments;
// //     if (args is Map && args['firstName'] != null) {
// //       setState(() {
// //         firstName = args['firstName'];
// //       });
// //     }
// //   }
// //
// //   void _fetchProfileAndGetName() async {
// //     final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
// //     await profileProvider.fetchProfile();
// //
// //     final profile = profileProvider.profile;
// //     if (profile != null && profile.firstName.isNotEmpty) {
// //       setState(() {
// //         firstName = profile.firstName;
// //       });
// //     }
// //   }
// //
// //   // void _showWelcomePopup() {
// //   //   showDialog(
// //   //     context: context,
// //   //     barrierDismissible: false,
// //   //     builder: (context) {
// //   //       return Dialog(
// //   //         backgroundColor: Colors.white,
// //   //         insetPadding: EdgeInsets.all(10.w),
// //   //         elevation: 4,
// //   //         shape: RoundedRectangleBorder(
// //   //           borderRadius: BorderRadius.circular(20.r),
// //   //         ),
// //   //         child: Padding(
// //   //           padding: EdgeInsets.all(20.w),
// //   //           child: Column(
// //   //             mainAxisSize: MainAxisSize.min,
// //   //             children: [
// //   //               Text(
// //   //                 "Welcome aboard, $firstName 🎉",
// //   //                 style: AppTextStyle.subHeading,
// //   //               ),
// //   //               SizedBox(height: 10.h),
// //   //               Text(
// //   //                 "Your account is ready. Let's quickly verify your details so you can start trading and withdraw your winnings.",
// //   //                 textAlign: TextAlign.center,
// //   //                 style: TextStyle(
// //   //                   fontSize: 13.sp,
// //   //                   color: Colors.grey,
// //   //                   fontFamily: 'SFProRounded',
// //   //                 ),
// //   //               ),
// //   //               SizedBox(height: 20.h),
// //   //               GestureDetector(
// //   //                 onTap: () {
// //   //                   Navigator.pop(context);
// //   //                   showModalBottomSheet(
// //   //                     context: context,
// //   //                     isScrollControlled: true,
// //   //                     backgroundColor: Colors.transparent,
// //   //                     builder: (context) {
// //   //                       return Padding(
// //   //                         padding: EdgeInsets.only(
// //   //                           left: 10.w,
// //   //                           right: 10.w,
// //   //                           top: 20.h,
// //   //                           bottom: 20.h,
// //   //                         ),
// //   //                         child: ClipRRect(
// //   //                           borderRadius: BorderRadius.only(
// //   //                             topLeft: Radius.circular(20.r),
// //   //                             topRight: Radius.circular(20.r),
// //   //                             bottomLeft: Radius.circular(15.r),
// //   //                             bottomRight: Radius.circular(15.r),
// //   //                           ),
// //   //                           child: Container(
// //   //                             color: Colors.white,
// //   //                             child: FractionallySizedBox(
// //   //                               heightFactor: 0.9,
// //   //                               child: VerificationFlow(),
// //   //                             ),
// //   //                           ),
// //   //                         ),
// //   //                       );
// //   //                     },
// //   //                   );
// //   //                 },
// //   //                 child: Container(
// //   //                   width: double.infinity,
// //   //                   padding: EdgeInsets.symmetric(vertical: 14.h),
// //   //                   decoration: BoxDecoration(
// //   //                     borderRadius: BorderRadius.circular(30.r),
// //   //                     color: AppColors.primary,
// //   //                   ),
// //   //                   child: Center(
// //   //                     child: Text(
// //   //                       "Verify my account",
// //   //                       style: TextStyle(
// //   //                         fontSize: 14.sp,
// //   //                         color: Colors.white,
// //   //                         fontFamily: 'SFProRounded',
// //   //                       ),
// //   //                     ),
// //   //                   ),
// //   //                 ),
// //   //               ),
// //   //               SizedBox(height: 10.h),
// //   //               GestureDetector(
// //   //                 onTap: () {
// //   //                   Navigator.pop(context);
// //   //                 },
// //   //                 child: Container(
// //   //                   width: double.infinity,
// //   //                   padding: EdgeInsets.symmetric(vertical: 14.h),
// //   //                   alignment: Alignment.center,
// //   //                   decoration: BoxDecoration(
// //   //                     borderRadius: BorderRadius.circular(30.r),
// //   //                     border: Border.all(
// //   //                       width: 2.w,
// //   //                       color: Colors.grey.shade200,
// //   //                     ),
// //   //                   ),
// //   //                   child: Row(
// //   //                     mainAxisAlignment: MainAxisAlignment.center,
// //   //                     children: [
// //   //                       Text(
// //   //                         "Skip for now",
// //   //                         style: TextStyle(
// //   //                           fontSize: 14.sp,
// //   //                           fontFamily: 'SFProRounded',
// //   //                           color: Colors.black,
// //   //                         ),
// //   //                       ),
// //   //                       SizedBox(width: 5.w),
// //   //                       Icon(
// //   //                         Icons.arrow_forward_ios_rounded,
// //   //                         size: 16.sp,
// //   //                       ),
// //   //                     ],
// //   //                   ),
// //   //                 ),
// //   //               ),
// //   //             ],
// //   //           ),
// //   //         ),
// //   //       );
// //   //     },
// //   //   );
// //   // }
// //   void _showWelcomePopup() {
// //     showDialog(
// //       context: context,
// //       barrierDismissible: false,
// //       builder: (context) {
// //         final isDarkMode = Theme.of(context).brightness == Brightness.dark;
// //
// //         return Dialog(
// //           backgroundColor: AppColors.cardBackgroundDynamic(context),
// //           insetPadding: EdgeInsets.all(10.w),
// //           elevation: 4,
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(20.r),
// //           ),
// //           child: Padding(
// //             padding: EdgeInsets.all(20.w),
// //             child: Column(
// //               mainAxisSize: MainAxisSize.min,
// //               children: [
// //                 Text(
// //                   "Welcome aboard, $firstName 🎉",
// //                   style: AppTextStyle.subHeading.copyWith(
// //                     color: AppColors.textPrimaryDynamic(context),
// //                   ),
// //                 ),
// //                 SizedBox(height: 10.h),
// //                 Text(
// //                   "Your account is ready. Let's quickly verify your details so you can start trading and withdraw your winnings.",
// //                   textAlign: TextAlign.center,
// //                   style: TextStyle(
// //                     fontSize: 13.sp,
// //                     color: AppColors.textSecondaryDynamic(context),
// //                     fontFamily: 'SFProRounded',
// //                   ),
// //                 ),
// //                 SizedBox(height: 20.h),
// //
// //                 // ✅ Primary Button with InkWell (Better UX)
// //                 InkWell(
// //                   onTap: () {
// //                     Navigator.pop(context);
// //                     showModalBottomSheet(
// //                       context: context,
// //                       isScrollControlled: true,
// //                       backgroundColor: Colors.transparent,
// //                       builder: (context) {
// //                         return Padding(
// //                           padding: EdgeInsets.only(
// //                             left: 10.w,
// //                             right: 10.w,
// //                             top: 20.h,
// //                             bottom: 20.h,
// //                           ),
// //                           child: ClipRRect(
// //                             borderRadius: BorderRadius.only(
// //                               topLeft: Radius.circular(20.r),
// //                               topRight: Radius.circular(20.r),
// //                               bottomLeft: Radius.circular(15.r),
// //                               bottomRight: Radius.circular(15.r),
// //                             ),
// //                             child: Container(
// //                               color: AppColors.cardBackgroundDynamic(context),
// //                               child: FractionallySizedBox(
// //                                 heightFactor: 0.9,
// //                                 child:VerificationFlow(),
// //                               ),
// //                             ),
// //                           ),
// //                         );
// //                       },
// //                     );
// //                   },
// //                   borderRadius: BorderRadius.circular(30.r),
// //                   child: Container(
// //                     width: double.infinity,
// //                     padding: EdgeInsets.symmetric(vertical: 14.h),
// //                     decoration: BoxDecoration(
// //                       borderRadius: BorderRadius.circular(30.r),
// //                       color: AppColors.primary,
// //                     ),
// //                     child: const Center(
// //                       child: Text(
// //                         "Verify my account",
// //                         style: TextStyle(
// //                           fontSize: 14,
// //                           color: Colors.white,
// //                           fontFamily: 'SFProRounded',
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //
// //                 SizedBox(height: 10.h),
// //
// //                 // ✅ Secondary Button with InkWell
// //                 InkWell(
// //                   onTap: () {
// //                     Navigator.pop(context);
// //                   },
// //                   borderRadius: BorderRadius.circular(30.r),
// //                   child: Container(
// //                     width: double.infinity,
// //                     padding: EdgeInsets.symmetric(vertical: 14.h),
// //                     alignment: Alignment.center,
// //                     decoration: BoxDecoration(
// //                       borderRadius: BorderRadius.circular(30.r),
// //                       border: Border.all(
// //                         width: 2.w,
// //                         color: AppColors.borderDynamic(context),
// //                       ),
// //                     ),
// //                     child: Row(
// //                       mainAxisAlignment: MainAxisAlignment.center,
// //                       children: [
// //                         Text(
// //                           "Skip for now",
// //                           style: TextStyle(
// //                             fontSize: 14.sp,
// //                             fontFamily: 'SFProRounded',
// //                             color: AppColors.textPrimaryDynamic(context),
// //                           ),
// //                         ),
// //                         SizedBox(width: 5.w),
// //                         Icon(
// //                           Icons.arrow_forward_ios_rounded,
// //                           size: 16.sp,
// //                           color: AppColors.textPrimaryDynamic(context),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Consumer<ProfileProvider>(
// //       builder: (context, profileProvider, child) {
// //         final profile = profileProvider.profile;
// //         if (profile != null && profile.firstName.isNotEmpty && firstName != profile.firstName) {
// //           WidgetsBinding.instance.addPostFrameCallback((_) {
// //             setState(() {
// //               firstName = profile.firstName;
// //             });
// //           });
// //         }
// //
// //         return Scaffold(
// //           body: IndexedStack(
// //             index: currentIndex,
// //             children: screens,
// //           ),
// //           bottomNavigationBar: CustomBottomNav(
// //             currentIndex: currentIndex,
// //             onTap: (index) {
// //               setState(() {
// //                 currentIndex = index;
// //               });
// //             },
// //           ),
// //         );
// //       },
// //     );
// //   }
// // }
//
//
// import 'package:betrade/core/theme/app_text_style.dart';
// import 'package:betrade/presentation/screens/explore/explore_page.dart';
// import 'package:betrade/presentation/screens/homeScreen/HomeScreen.dart';
// import 'package:betrade/presentation/screens/portfolio/portfolio_page.dart';
// import 'package:betrade/presentation/screens/profile/info_chart_screen.dart';
// import 'package:betrade/presentation/screens/profile/profile_page.dart';
// import 'package:betrade/presentation/screens/verification/verify_account.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:provider/provider.dart';
// import '../../core/theme/app_colors.dart';
// import '../../data/provider/profile_provider.dart';
// import '../bottom_navigation/bottom_nav.dart';
//
// class MainScreen extends StatefulWidget {
//   final bool showWelcomePopup;
//
//   const MainScreen({super.key, this.showWelcomePopup = false});
//
//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }
//
// class _MainScreenState extends State<MainScreen> {
//   int currentIndex = 0;
//   String firstName = "User";
//
//   final screens = [
//     HomeScreen(),
//     ExplorePage(),
//     InfoChartScreen(),
//     PortfolioPage(),
//     ProfilePage(),
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await _handleUserNameAndPopup();
//     });
//   }
//
//   /// ✅ MAIN FIX METHOD
//   Future<void> _handleUserNameAndPopup() async {
//     // 1. Route arguments se name lo (login ke baad pass ho to)
//     final args = ModalRoute.of(context)?.settings.arguments;
//     if (args is Map &&
//         args['firstName'] != null &&
//         args['firstName'].toString().isNotEmpty) {
//       firstName = args['firstName'];
//     }
//
//     // 2. Agar abhi bhi default hai → API se fetch karo
//     if (firstName == "User" || firstName.isEmpty) {
//       final profileProvider =
//       Provider.of<ProfileProvider>(context, listen: false);
//
//       await profileProvider.fetchProfile();
//
//       final profile = profileProvider.profile;
//
//       if (profile != null && profile.firstName.isNotEmpty) {
//         firstName = profile.firstName;
//       }
//     }
//
//     // 3. UI update
//     if (mounted) {
//       setState(() {});
//     }
//
//     // 4. Popup show karo (correct name ke saath)
//     if (widget.showWelcomePopup && mounted) {
//       _showWelcomePopup();
//     }
//   }
//
//   /// ✅ POPUP
//   void _showWelcomePopup() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) {
//         return Dialog(
//           backgroundColor: AppColors.cardBackgroundDynamic(context),
//           insetPadding: EdgeInsets.all(10.w),
//           elevation: 4,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20.r),
//           ),
//           child: Padding(
//             padding: EdgeInsets.all(20.w),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   "Welcome aboard, ${firstName.isNotEmpty ? firstName : "Trader"} 🎉",
//                   style: AppTextStyle.subHeading.copyWith(
//                     color: AppColors.textPrimaryDynamic(context),
//                   ),
//                 ),
//                 SizedBox(height: 10.h),
//                 Text(
//                   "Your account is ready. Let's quickly verify your details so you can start trading and withdraw your winnings.",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 13.sp,
//                     color: AppColors.textSecondaryDynamic(context),
//                     fontFamily: 'SFProRounded',
//                   ),
//                 ),
//                 SizedBox(height: 20.h),
//
//                 /// ✅ Verify Button
//                 InkWell(
//                   onTap: () {
//                     Navigator.pop(context);
//                     showModalBottomSheet(
//                       context: context,
//                       isScrollControlled: true,
//                       backgroundColor: Colors.transparent,
//                       builder: (context) {
//                         return Padding(
//                           padding: EdgeInsets.only(
//                             left: 10.w,
//                             right: 10.w,
//                             top: 20.h,
//                             bottom: 20.h,
//                           ),
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(20.r),
//                             child: Container(
//                               color:
//                               AppColors.cardBackgroundDynamic(context),
//                               child: FractionallySizedBox(
//                                 heightFactor: 0.9,
//                                 child: VerificationFlow(),
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     );
//                   },
//                   borderRadius: BorderRadius.circular(30.r),
//                   child: Container(
//                     width: double.infinity,
//                     padding: EdgeInsets.symmetric(vertical: 14.h),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(30.r),
//                       color: AppColors.primary,
//                     ),
//                     child: const Center(
//                       child: Text(
//                         "Verify my account",
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Colors.white,
//                           fontFamily: 'SFProRounded',
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//
//                 SizedBox(height: 10.h),
//
//                 /// ✅ Skip Button
//                 InkWell(
//                   onTap: () {
//                     Navigator.pop(context);
//                   },
//                   borderRadius: BorderRadius.circular(30.r),
//                   child: Container(
//                     width: double.infinity,
//                     padding: EdgeInsets.symmetric(vertical: 14.h),
//                     alignment: Alignment.center,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(30.r),
//                       border: Border.all(
//                         width: 2.w,
//                         color: AppColors.borderDynamic(context),
//                       ),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           "Skip for now",
//                           style: TextStyle(
//                             fontSize: 14.sp,
//                             fontFamily: 'SFProRounded',
//                             color:
//                             AppColors.textPrimaryDynamic(context),
//                           ),
//                         ),
//                         SizedBox(width: 5.w),
//                         Icon(
//                           Icons.arrow_forward_ios_rounded,
//                           size: 16.sp,
//                           color:
//                           AppColors.textPrimaryDynamic(context),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   /// ✅ BUILD
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: IndexedStack(
//         index: currentIndex,
//         children: screens,
//       ),
//       bottomNavigationBar: CustomBottomNav(
//         currentIndex: currentIndex,
//         onTap: (index) {
//           setState(() {
//             currentIndex = index;
//           });
//         },
//       ),
//     );
//   }
// }

import 'dart:async';
import 'dart:ui';
import 'package:betrade/core/theme/app_text_style.dart';
import 'package:betrade/presentation/screens/explore/explore_page.dart';
import 'package:betrade/presentation/screens/homeScreen/HomeScreen.dart';
import 'package:betrade/presentation/screens/portfolio/portfolio_page.dart';
import 'package:betrade/presentation/screens/profile/info_chart_screen.dart';
import 'package:betrade/presentation/screens/profile/profile_page.dart';
import 'package:betrade/presentation/screens/verification/verify_account.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/provider/profile_provider.dart';
import '../../data/services/local_storage.dart';
import '../../data/services/auth_service.dart';
import '../auth/auth_screen.dart';
import '../bottom_navigation/bottom_nav.dart';

class MainScreen extends StatefulWidget {
  final bool showWelcomePopup;

  const MainScreen({super.key, this.showWelcomePopup = false});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;
  String firstName = "User";

  Timer? _tokenTimer;
  bool _isDialogShowing = false;

  final screens = [
    HomeScreen(),
    ExplorePage(),
    InfoChartScreen(),
    PortfolioPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();

    _startTokenChecker();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _handleUserNameAndPopup();
    });
  }

  void _startTokenChecker() {
    _tokenTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      String? token = LocalStorage.getToken();
      if (token == null) return;
      bool isValid = await AuthService().verifyToken(token);
      if (!isValid && !_isDialogShowing) {
        _isDialogShowing = true;
        _tokenTimer?.cancel();
        if (!mounted) return;
        showGeneralDialog(
          context: context,
          barrierDismissible: false,
          barrierLabel: "Session Expired",
          barrierColor: Colors.black.withOpacity(0.6),
          transitionDuration: const Duration(milliseconds: 500),

          pageBuilder: (_, __, ___) {
            return Center(
              child: Material(
                color: Colors.transparent,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.05),
                            Colors.white.withOpacity(0.02),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TweenAnimationBuilder(
                            tween: Tween(begin: 0.8, end: 1.2),
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.easeInOut,
                            builder: (context, value, child) {
                              return Container(
                                height: 70 * value,
                                width: 70 * value,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red.withOpacity(0.08),
                                ),
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.red.withOpacity(0.15),
                                    ),
                                    child: const Icon(
                                      Icons.warning_amber_rounded,
                                      color: Colors.redAccent,
                                      size: 36,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            "Session Terminated 🚫",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),

                          const SizedBox(height: 10),
                          const Text(
                            "We detected a login from another device.\nFor your security, your session has been ended.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.5,
                              color: Colors.white70,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 22),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.redAccent,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                "Securing your account...",
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: Colors.white60,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },

          // 🔥 ADVANCED ANIMATION
          transitionBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: ScaleTransition(
                  scale: CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutBack,
                  ),
                  child: child,
                ),
              ),
            );
          },
        );

        Future.delayed(const Duration(seconds: 2), () async {
          await LocalStorage.clearToken();
          if (!mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const AuthScreen()),
                (route) => false,
          );
        });
      }
    });
  }

  Future<void> _handleUserNameAndPopup() async {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map &&
        args['firstName'] != null &&
        args['firstName'].toString().isNotEmpty) {
      firstName = args['firstName'];
    }

    if (firstName == "User" || firstName.isEmpty) {
      final profileProvider =
      Provider.of<ProfileProvider>(context, listen: false);

      await profileProvider.fetchProfile();

      final profile = profileProvider.profile;

      if (profile != null && profile.firstName.isNotEmpty) {
        firstName = profile.firstName;
      }
    }

    if (mounted) {
      setState(() {});
    }

    if (widget.showWelcomePopup && mounted) {
      _showWelcomePopup();
    }
  }

  /// ✅ WELCOME POPUP
  void _showWelcomePopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.cardBackgroundDynamic(context),
          insetPadding: EdgeInsets.all(10.w),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Welcome aboard, ${firstName.isNotEmpty ? firstName : "Trader"} 🎉",
                  style: AppTextStyle.subHeading.copyWith(
                    color: AppColors.textPrimaryDynamic(context),
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  "Your account is ready. Let's quickly verify your details so you can start trading and withdraw your winnings.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textSecondaryDynamic(context),
                    fontFamily: 'SFProRounded',
                  ),
                ),
                SizedBox(height: 20.h),

                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) {
                        return Padding(
                          padding: EdgeInsets.all(10.w),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20.r),
                            child: Container(
                              color:
                              AppColors.cardBackgroundDynamic(context),
                              child: FractionallySizedBox(
                                heightFactor: 0.9,
                                child: VerificationFlow(),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  borderRadius: BorderRadius.circular(30.r),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.r),
                      color: AppColors.primary,
                    ),
                    child: const Center(
                      child: Text(
                        "Verify my account",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 10.h),

                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.r),
                      border: Border.all(
                        width: 2.w,
                        color: AppColors.borderDynamic(context),
                      ),
                    ),
                    child: Text(
                      "Skip for now",
                      style: TextStyle(
                        color: AppColors.textPrimaryDynamic(context),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _tokenTimer?.cancel(); // 🔥 IMPORTANT
    super.dispose();
  }

  /// ✅ BUILD
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}