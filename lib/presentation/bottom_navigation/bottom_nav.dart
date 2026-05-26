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
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../../data/provider/profile_provider.dart';
import '../../core/theme/app_colors.dart';

/// Bottom-navigation chrome for [MainScreen]'s IndexedStack.
///
/// Why vector icons (lucide_icons) instead of the previous `Image.asset`
/// pipeline:
///   - The PNGs in assets/images/{home,ser,medal,pay}.png are 442-624 byte
///     24x24 sprites. Stretching them to display size (22.w/h after
///     ScreenUtil) pixelates badly on high-DPI devices and the Rankings
///     icon was missing entirely (medal.png exists but rendered as a
///     "24x24" placeholder on the vivo).
///   - Lucide icons are vector glyphs from a font, so they're sharp at any
///     size and tint cleanly with the `color:` property without needing a
///     `color:` overlay on top of a PNG.
///   - Lucide is already a dependency (declared in pubspec.yaml at
///     ^0.257.0); no new package needed.
///
/// Selection state: the only colour difference is selected vs unselected;
/// that's handled by `selectedItemColor` / `unselectedItemColor` on
/// `BottomNavigationBar`, which BottomNavigationBarItem.icon's `Icon`
/// inherits via IconTheme — so we no longer need to thread `currentIndex`
/// into each item to tint manually.
class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

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
      // Set explicit icon size so lucide glyphs render at the same visual
      // weight the old PNGs targeted (22.w in the legacy code).
      selectedIconTheme: IconThemeData(size: 24.sp),
      unselectedIconTheme: IconThemeData(size: 24.sp),

      items: [
        /// Home
        BottomNavigationBarItem(
          icon: const Icon(LucideIcons.home),
          label: "Home",
        ),

        /// Explore
        BottomNavigationBarItem(
          icon: const Icon(LucideIcons.search),
          label: "Explore",
        ),

        /// Rankings (was the visibly broken one — missing-asset placeholder)
        BottomNavigationBarItem(
          icon: const Icon(LucideIcons.trophy),
          label: "Rankings",
        ),

        /// Portfolio
        BottomNavigationBarItem(
          icon: const Icon(LucideIcons.wallet),
          label: "Portfolio",
        ),

        /// Profile — kept as a CircleAvatar so an uploaded user photo can
        /// appear instead of a stock icon. Fallback `Icons.person` is also
        /// vector so it's sharp.
        BottomNavigationBarItem(
          icon: Consumer<ProfileProvider>(
            builder: (context, provider, child) {
              final profile = provider.profile;
              final isSelected = currentIndex == 4;

              return Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.grey,
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
                          color: isSelected ? AppColors.primary : Colors.grey,
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