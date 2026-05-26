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

  /// Reusable image-icon widget — tinted by selected state.
  Widget buildNavImage(String path, int index) {
    return Image.asset(
      path,
      width: 22.w,
      height: 22.h,
      color: currentIndex == index ? AppColors.primary : Colors.grey,
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

        /// Profile — CircleAvatar so an uploaded profile photo can show
        /// through; falls back to Icons.person glyph when no avatar exists.
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
                // Use the 200×200 thumbnail for the nav avatar — full
                // resolution is wasted here at radius 11 and re-fetched
                // every tab open. Falls back to the original avatar if
                // no thumbnail is set, then to a person glyph if neither.
                child: CircleAvatar(
                  radius: 11.r,
                  backgroundColor: Colors.transparent,
                  backgroundImage:
                      profile != null && profile.displayAvatar.isNotEmpty
                          ? NetworkImage(profile.displayAvatar)
                          : null,
                  onBackgroundImageError:
                      profile != null && profile.displayAvatar.isNotEmpty
                          ? (_, __) {}
                          : null,
                  child: profile == null || profile.displayAvatar.isEmpty
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
