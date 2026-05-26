// import 'package:betrade/core/theme/app_text_style.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:provider/provider.dart';
// import '../../../data/provider/profile_provider.dart';
// import '../../core/theme/app_colors.dart';
//
// class CustomBottomNav extends StatelessWidget {
//   final int currentIndex;
//   final Function(int) onTap;
//
//   const CustomBottomNav({
//     super.key,
//     required this.currentIndex,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(
//       currentIndex: currentIndex,
//       onTap: onTap,
//       type: BottomNavigationBarType.fixed,
//       selectedItemColor: AppColors.primary,
//       unselectedItemColor: Colors.grey,
//       selectedLabelStyle: AppTextStyle.smallNav,
//       unselectedLabelStyle: AppTextStyle.smallNav,
//       items: [
//         BottomNavigationBarItem(
//           icon: Image.asset(
//             "assets/images/home.png",
//             width: 22.w,
//             height: 22.h,
//           ),
//           label: "Home",
//         ),
//
//         BottomNavigationBarItem(
//           icon: Image.asset(
//             "assets/images/ser.png",
//             width: 22.w,
//             height: 22.h,
//           ),
//           label: "Explore",
//         ),
//
//         BottomNavigationBarItem(
//           icon: Image.asset(
//             "assets/images/medal.png",
//             width: 22.w,
//             height: 22.h,
//           ),
//           label: "Rankings",
//         ),
//
//         BottomNavigationBarItem(
//           icon: Image.asset(
//             "assets/images/pay.png",
//             width: 22.w,
//             height: 22.h,
//           ),
//           label: "Portfolio",
//         ),
//
//         BottomNavigationBarItem(
//           icon: Consumer<ProfileProvider>(
//             builder: (context, provider, child) {
//               final profile = provider.profile;
//               return CircleAvatar(
//                 radius: 11.r,
//                 backgroundImage: profile != null && profile.avatar.isNotEmpty
//                     ? NetworkImage(profile.avatar)
//                     : null,
//                 child: profile == null || profile.avatar.isEmpty
//                     ? Icon(Icons.person, size: 22.sp)
//                     : null,
//               );
//             },
//           ),
//           label: "Profile",
//         ),
//       ],
//     );
//   }
// }

import 'package:betrade/core/theme/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../data/provider/profile_provider.dart';
import '../../core/theme/app_colors.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  /// 🔥 Reusable Image Icon Widget
  Widget buildNavImage(String path, int index) {
    return Image.asset(
      path,
      width: 22.w,
      height: 22.h,
      color: currentIndex == index
          ? AppColors.primary
          : Colors.grey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      // Anchor the navbar colour so scrolling content underneath does
      // not bleed the Material 3 surface tint into the nav and turn it
      // grey (QA #16). Setting backgroundColor explicitly + elevation 0
      // is enough on the classic BottomNavigationBar widget — it does
      // not expose surfaceTintColor.
      backgroundColor: AppColors.bottomNavBackgroundDynamic(context),
      elevation: 0,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: AppTextStyle.smallNav,
      unselectedLabelStyle: AppTextStyle.smallNav,

      items: [
        /// Home
        BottomNavigationBarItem(
          icon: buildNavImage("assets/images/home.png", 0),
          label: "Home",
        ),

        /// Explore
        BottomNavigationBarItem(
          icon: buildNavImage("assets/images/ser.png", 1),
          label: "Explore",
        ),

        /// Rankings
        BottomNavigationBarItem(
          icon: buildNavImage("assets/images/medal.png", 2),
          label: "Rankings",
        ),

        /// Portfolio
        BottomNavigationBarItem(
          icon: buildNavImage("assets/images/pay.png", 3),
          label: "Portfolio",
        ),

        /// Profile
        BottomNavigationBarItem(
          icon: Consumer<ProfileProvider>(
            builder: (context, provider, child) {
              final profile = provider.profile;

              return Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: currentIndex == 4
                        ? AppColors.primary
                        : Colors.grey,
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 11.r,
                  backgroundColor: Colors.transparent,
                  backgroundImage:
                  profile != null && profile.avatar.isNotEmpty
                      ? NetworkImage(profile.avatar)
                      : null,
                  child: profile == null || profile.avatar.isEmpty
                      ? Icon(
                    Icons.person,
                    size: 18.sp,
                    color: currentIndex == 4
                        ? AppColors.primary
                        : Colors.grey,
                  )
                      : null,
                ),
              );
            },
          ),
          label: "Profile",
        ),
      ],
    );
  }
}