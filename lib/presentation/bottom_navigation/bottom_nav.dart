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
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_colors.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  Widget buildNavImage(String path, int index) {
    return SvgPicture.asset(
      path,
      width: 22.w,
      height: 22.h,
      colorFilter: ColorFilter.mode(
        currentIndex == index ? AppColors.primary : Colors.grey,
        BlendMode.srcIn,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: AppTextStyle.smallNav,
      unselectedLabelStyle: AppTextStyle.smallNav,

      items: [
        /// Home
        BottomNavigationBarItem(
          icon: buildNavImage("assets/svgs/Home.svg", 0),
          label: "Home",
        ),

        /// Explore
        BottomNavigationBarItem(
          icon: buildNavImage("assets/svgs/search.svg", 1),
          label: "Explore",
        ),

        /// Rankings
        BottomNavigationBarItem(
          icon: buildNavImage("assets/svgs/ranking.svg", 2),
          label: "Rankings",
        ),

        /// Portfolio
        BottomNavigationBarItem(
          icon: buildNavImage("assets/svgs/money.svg", 3),
          label: "Portfolio",
        ),

        /// Profile
        BottomNavigationBarItem(
          icon: buildNavImage("assets/svgs/Profile.svg", 4),
          label: "Profile",
        ),
      ],
    );
  }
}