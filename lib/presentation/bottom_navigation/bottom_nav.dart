import 'package:betrade/core/theme/app_text_style.dart';
import 'package:betrade/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../../data/provider/profile_provider.dart';

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
      items: [
        BottomNavigationBarItem(
          icon: Icon(Iconsax.home_15, size: 22.sp),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search, size: 22.sp),
          label: "Explore",
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Iconsax.arrow_swap,
            size: 22.sp,
            fontWeight: FontWeight.bold,
          ),
          label: "Trade",
        ),
        BottomNavigationBarItem(
          icon: Icon(Iconsax.wallet, size: 22.sp),
          label: "Portfolio",
        ),
        BottomNavigationBarItem(
          icon: Consumer<ProfileProvider>(
            builder: (context, provider, child) {
              final profile = provider.profile;
              return CircleAvatar(
                radius: 11.r,
                backgroundImage: profile != null && profile.avatar.isNotEmpty
                    ? NetworkImage(profile.avatar)
                    : null,
                child: profile == null || profile.avatar.isEmpty
                    ? Icon(Icons.person, size: 22.sp)
                    : null,
              );
            },
          ),
          label: "Profile",
        ),
      ],
    );
  }
}
