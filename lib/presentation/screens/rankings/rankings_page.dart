import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_style.dart';

/// Rankings tab landing screen.
///
/// Empty-state for now — backend leaderboard isn't wired up yet so all
/// four tabs render the same "No Rankings Yet" placeholder. Tab state
/// is tracked locally so tapping animates the underline, but no data
/// fetch happens per tab change.
class RankingsPage extends StatefulWidget {
  const RankingsPage({super.key});

  @override
  State<RankingsPage> createState() => _RankingsPageState();
}

class _RankingsPageState extends State<RankingsPage> {
  int _selectedTab = 0;

  static const List<String> _tabs = [
    'Overall',
    'Profit',
    'Win Rate',
    'Hot Streak',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBackgroundDynamic(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            _buildTabBar(),
            Expanded(child: _buildEmptyState()),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset("assets/logo/IconLogo.png", height: 33.h),
              SizedBox(width: 5.w),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "BeTrade",
                      style: TextStyle(
                        fontFamily: AppTextStyle.fontFamily,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryDynamic(context),
                      ),
                    ),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.top,
                      child: Transform.translate(
                        offset: const Offset(1, -5),
                        child: Text(
                          "™",
                          style: TextStyle(
                            fontFamily: AppTextStyle.fontFamily,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimaryDynamic(context),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: AppColors.iconContainerDynamic(context),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(
                "assets/images/Bell.png",
                width: 20.w,
                height: 20.h,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderDynamic(context),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_tabs.length, (i) {
          return Padding(
            padding: EdgeInsets.only(right: i == _tabs.length - 1 ? 0 : 20.w),
            child: _tabItem(i),
          );
        }),
      ),
    );
  }

  /// IntrinsicWidth so the underline pill stretches to exactly the
  /// text width — Figma shows the underline matching each label's
  /// glyph width (50 / 37 / 62 / 74).
  Widget _tabItem(int i) {
    final selected = _selectedTab == i;
    return IntrinsicWidth(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _selectedTab = i),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 4.h),
              child: Text(
                _tabs[i],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTextStyle.fontFamily,
                  fontSize: 16.sp,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected
                      ? AppColors.textPrimaryDynamic(context)
                      : AppColors.textSecondaryDynamic(context),
                ),
              ),
            ),
            Container(
              height: 4.h,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFAA45FF)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(9999.r),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Figma empty-state badge — three layered shapes:
            //  1) Outer light-grey circle (#F4F4F5) backdrop
            //  2) subs.png document scroll inside it
            //  3) Small darker-grey circle on the document with the X
            //
            // We stack them explicitly so the cross sits crisply on
            // top regardless of what's baked into the PNG.
            SizedBox(
              width: 80.w,
              height: 80.w,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      color: AppColors.iconContainerDynamic(context),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Image.asset(
                    "assets/images/subs.png",
                    width: 60.w,
                    height: 60.w,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              "No Rankings Yet",
              style: TextStyle(
                fontFamily: AppTextStyle.fontFamily,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryDynamic(context),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "Start trading to see how you rank.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTextStyle.fontFamily,
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondaryDynamic(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
