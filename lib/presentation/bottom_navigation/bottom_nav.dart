import 'package:betrade/core/theme/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../data/provider/profile_provider.dart';
import '../../core/theme/app_colors.dart';

/// Bottom-navigation chrome for [MainScreen]'s IndexedStack.
///
/// Uses vector glyphs from `lucide_icons` for the four primary tabs.
/// Vector renders are sharp at any DPI; the previous `Image.asset` route
/// pointed at 442–624 byte raster sprites which pixelated on high-DPI
/// devices (QA bug #3 — tester report 2026-05-26).
///
/// Profile tab still uses a CircleAvatar so an uploaded user photo can
/// show through; fallback to a person glyph when no avatar is set or the
/// network image fails to load.
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
      selectedIconTheme: IconThemeData(size: 24.sp),
      unselectedIconTheme: IconThemeData(size: 24.sp),

      items: [
        const BottomNavigationBarItem(
          icon: Icon(LucideIcons.home),
          label: "Home",
        ),
        const BottomNavigationBarItem(
          icon: Icon(LucideIcons.search),
          label: "Explore",
        ),
        // 3rd tab hosts the Rankings leaderboard (Overall / Profit /
        // Win Rate / Hot Streak). Replaced the legacy "Chart" label
        // when the real leaderboard surface landed (2026-05-27).
        const BottomNavigationBarItem(
          icon: Icon(LucideIcons.trophy),
          label: "Rankings",
        ),
        const BottomNavigationBarItem(
          icon: Icon(LucideIcons.wallet),
          label: "Portfolio",
        ),
        BottomNavigationBarItem(
          icon: Consumer<ProfileProvider>(
            builder: (context, provider, child) {
              final profile = provider.profile;
              final isSelected = currentIndex == 4;
              final color = isSelected ? AppColors.primary : Colors.grey;

              // Use displayAvatar (thumbnail-with-fallback) for the
              // 22 px circle. Original avatar is way too big for this
              // size — wastes bandwidth on every cold open.
              return Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                ),
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
                      ? Icon(Icons.person, size: 18.sp, color: color)
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
