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
//   String firstName = "User"; // Default value
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
//     // Fetch profile data when screen loads
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<ProfileProvider>(context, listen: false).fetchProfile();
//       _getFirstNameFromProfile();
//     });
//
//     if (widget.showWelcomePopup) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _showWelcomePopup();
//       });
//     }
//   }
//
//   void _getFirstNameFromProfile() {
//     final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
//     final profile = profileProvider.profile;
//
//     if (profile != null && profile.firstName.isNotEmpty) {
//       setState(() {
//         firstName = profile.firstName;
//       });
//     }
//   }
//
//   void _showWelcomePopup() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) {
//         return Dialog(
//           backgroundColor: Colors.white,
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
//                   "Welcome aboard, $firstName 🎉",
//                   style: AppTextStyle.subHeading,
//                 ),
//                 SizedBox(height: 10.h),
//                 Text(
//                   "Your account is ready. Let's quickly verify your details so you can start trading and withdraw your winnings.",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 13.sp,
//                     color: Colors.grey,
//                     fontFamily: 'SFProRounded',
//                   ),
//                 ),
//                 SizedBox(height: 20.h),
//                 GestureDetector(
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
//                             borderRadius: BorderRadius.only(
//                               topLeft: Radius.circular(20.r),
//                               topRight: Radius.circular(20.r),
//                               bottomLeft: Radius.circular(15.r),
//                               bottomRight: Radius.circular(15.r),
//                             ),
//                             child: Container(
//                               color: Colors.white,
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
//                   child: Container(
//                     width: double.infinity,
//                     padding: EdgeInsets.symmetric(vertical: 14.h),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(30.r),
//                       color: AppColors.primary,
//                     ),
//                     child: Center(
//                       child: Text(
//                         "Verify my account",
//                         style: TextStyle(
//                           fontSize: 14.sp,
//                           color: Colors.white,
//                           fontFamily: 'SFProRounded',
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 10.h),
//                 GestureDetector(
//                   onTap: () {
//                     Navigator.pop(context);
//                   },
//                   child: Container(
//                     width: double.infinity,
//                     padding: EdgeInsets.symmetric(vertical: 14.h),
//                     alignment: Alignment.center,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(30.r),
//                       border: Border.all(
//                         width: 2.w,
//                         color: Colors.grey.shade200,
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
//                             color: Colors.black,
//                           ),
//                         ),
//                         SizedBox(width: 5.w),
//                         Icon(
//                           Icons.arrow_forward_ios_rounded,
//                           size: 16.sp,
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
//   @override
//   Widget build(BuildContext context) {
//     // Listen to ProfileProvider for real-time updates
//     return Consumer<ProfileProvider>(
//       builder: (context, profileProvider, child) {
//         // Update first name when profile data is loaded
//         final profile = profileProvider.profile;
//         if (profile != null && profile.firstName.isNotEmpty && firstName != profile.firstName) {
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             setState(() {
//               firstName = profile.firstName;
//             });
//           });
//         }
//
//         return Scaffold(
//           body: IndexedStack(
//             index: currentIndex,
//             children: screens,
//           ),
//           bottomNavigationBar: CustomBottomNav(
//             currentIndex: currentIndex,
//             onTap: (index) {
//               setState(() {
//                 currentIndex = index;
//               });
//             },
//           ),
//         );
//       },
//     );
//   }
// }

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getFirstNameFromArguments();
      if (firstName == "User") {
        _fetchProfileAndGetName();
      }
      if (widget.showWelcomePopup) {
        Future.delayed(Duration(milliseconds: 500), () {
          _showWelcomePopup();
        });
      }
    });
  }

  void _getFirstNameFromArguments() {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['firstName'] != null) {
      setState(() {
        firstName = args['firstName'];
      });
    }
  }

  void _fetchProfileAndGetName() async {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    await profileProvider.fetchProfile();

    final profile = profileProvider.profile;
    if (profile != null && profile.firstName.isNotEmpty) {
      setState(() {
        firstName = profile.firstName;
      });
    }
  }

  // void _showWelcomePopup() {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) {
  //       return Dialog(
  //         backgroundColor: Colors.white,
  //         insetPadding: EdgeInsets.all(10.w),
  //         elevation: 4,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(20.r),
  //         ),
  //         child: Padding(
  //           padding: EdgeInsets.all(20.w),
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Text(
  //                 "Welcome aboard, $firstName 🎉",
  //                 style: AppTextStyle.subHeading,
  //               ),
  //               SizedBox(height: 10.h),
  //               Text(
  //                 "Your account is ready. Let's quickly verify your details so you can start trading and withdraw your winnings.",
  //                 textAlign: TextAlign.center,
  //                 style: TextStyle(
  //                   fontSize: 13.sp,
  //                   color: Colors.grey,
  //                   fontFamily: 'SFProRounded',
  //                 ),
  //               ),
  //               SizedBox(height: 20.h),
  //               GestureDetector(
  //                 onTap: () {
  //                   Navigator.pop(context);
  //                   showModalBottomSheet(
  //                     context: context,
  //                     isScrollControlled: true,
  //                     backgroundColor: Colors.transparent,
  //                     builder: (context) {
  //                       return Padding(
  //                         padding: EdgeInsets.only(
  //                           left: 10.w,
  //                           right: 10.w,
  //                           top: 20.h,
  //                           bottom: 20.h,
  //                         ),
  //                         child: ClipRRect(
  //                           borderRadius: BorderRadius.only(
  //                             topLeft: Radius.circular(20.r),
  //                             topRight: Radius.circular(20.r),
  //                             bottomLeft: Radius.circular(15.r),
  //                             bottomRight: Radius.circular(15.r),
  //                           ),
  //                           child: Container(
  //                             color: Colors.white,
  //                             child: FractionallySizedBox(
  //                               heightFactor: 0.9,
  //                               child: VerificationFlow(),
  //                             ),
  //                           ),
  //                         ),
  //                       );
  //                     },
  //                   );
  //                 },
  //                 child: Container(
  //                   width: double.infinity,
  //                   padding: EdgeInsets.symmetric(vertical: 14.h),
  //                   decoration: BoxDecoration(
  //                     borderRadius: BorderRadius.circular(30.r),
  //                     color: AppColors.primary,
  //                   ),
  //                   child: Center(
  //                     child: Text(
  //                       "Verify my account",
  //                       style: TextStyle(
  //                         fontSize: 14.sp,
  //                         color: Colors.white,
  //                         fontFamily: 'SFProRounded',
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //               SizedBox(height: 10.h),
  //               GestureDetector(
  //                 onTap: () {
  //                   Navigator.pop(context);
  //                 },
  //                 child: Container(
  //                   width: double.infinity,
  //                   padding: EdgeInsets.symmetric(vertical: 14.h),
  //                   alignment: Alignment.center,
  //                   decoration: BoxDecoration(
  //                     borderRadius: BorderRadius.circular(30.r),
  //                     border: Border.all(
  //                       width: 2.w,
  //                       color: Colors.grey.shade200,
  //                     ),
  //                   ),
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     children: [
  //                       Text(
  //                         "Skip for now",
  //                         style: TextStyle(
  //                           fontSize: 14.sp,
  //                           fontFamily: 'SFProRounded',
  //                           color: Colors.black,
  //                         ),
  //                       ),
  //                       SizedBox(width: 5.w),
  //                       Icon(
  //                         Icons.arrow_forward_ios_rounded,
  //                         size: 16.sp,
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }
  void _showWelcomePopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
                  "Welcome aboard, $firstName 🎉",
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

                // ✅ Primary Button with InkWell (Better UX)
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) {
                        return Padding(
                          padding: EdgeInsets.only(
                            left: 10.w,
                            right: 10.w,
                            top: 20.h,
                            bottom: 20.h,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20.r),
                              topRight: Radius.circular(20.r),
                              bottomLeft: Radius.circular(15.r),
                              bottomRight: Radius.circular(15.r),
                            ),
                            child: Container(
                              color: AppColors.cardBackgroundDynamic(context),
                              child: FractionallySizedBox(
                                heightFactor: 0.9,
                                child:VerificationFlow(),
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
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontFamily: 'SFProRounded',
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 10.h),

                // ✅ Secondary Button with InkWell
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(30.r),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Skip for now",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: 'SFProRounded',
                            color: AppColors.textPrimaryDynamic(context),
                          ),
                        ),
                        SizedBox(width: 5.w),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16.sp,
                          color: AppColors.textPrimaryDynamic(context),
                        ),
                      ],
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
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        final profile = profileProvider.profile;
        if (profile != null && profile.firstName.isNotEmpty && firstName != profile.firstName) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              firstName = profile.firstName;
            });
          });
        }

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
      },
    );
  }
}