// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// import '../../../core/theme/app_colors.dart';
// import '../../../core/theme/app_text_style.dart';
//
// /// Rankings tab landing screen.
// ///
// /// Empty-state for now — backend leaderboard isn't wired up yet so all
// /// four tabs render the same "No Rankings Yet" placeholder. Tab state
// /// is tracked locally so tapping animates the underline, but no data
// /// fetch happens per tab change.
// class RankingsPage extends StatefulWidget {
//   const RankingsPage({super.key});
//
//   @override
//   State<RankingsPage> createState() => _RankingsPageState();
// }
//
// class _RankingsPageState extends State<RankingsPage> {
//   int _selectedTab = 0;
//
//   static const List<String> _tabs = [
//     'Overall',
//     'Profit',
//     'Win Rate',
//     'Hot Streak',
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.cardBackgroundDynamic(context),
//       body: SafeArea(
//         child: Column(
//           children: [
//             _buildTopBar(),
//             _buildTabBar(),
//             Expanded(child: _buildEmptyState()),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTopBar() {
//     return Padding(
//       padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             children: [
//               Image.asset("assets/logo/IconLogo.png", height: 33.h),
//               SizedBox(width: 5.w),
//               RichText(
//                 text: TextSpan(
//                   children: [
//                     TextSpan(
//                       text: "BeTrade",
//                       style: TextStyle(
//                         fontFamily: AppTextStyle.fontFamily,
//                         fontSize: 15.sp,
//                         fontWeight: FontWeight.w700,
//                         color: AppColors.textPrimaryDynamic(context),
//                       ),
//                     ),
//                     WidgetSpan(
//                       alignment: PlaceholderAlignment.top,
//                       child: Transform.translate(
//                         offset: const Offset(1, -5),
//                         child: Text(
//                           "™",
//                           style: TextStyle(
//                             fontFamily: AppTextStyle.fontFamily,
//                             fontSize: 10.sp,
//                             fontWeight: FontWeight.w600,
//                             color: AppColors.textPrimaryDynamic(context),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           Container(
//             width: 40.w,
//             height: 40.h,
//             decoration: BoxDecoration(
//               color: AppColors.iconContainerDynamic(context),
//               shape: BoxShape.circle,
//             ),
//             child: Center(
//               child: Image.asset(
//                 "assets/images/Bell.png",
//                 width: 20.w,
//                 height: 20.h,
//                 fit: BoxFit.contain,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTabBar() {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 16.w),
//       decoration: BoxDecoration(
//         border: Border(
//           bottom: BorderSide(
//             color: AppColors.borderDynamic(context),
//             width: 1,
//           ),
//         ),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: List.generate(_tabs.length, (i) {
//           return Padding(
//             padding: EdgeInsets.only(right: i == _tabs.length - 1 ? 0 : 20.w),
//             child: _tabItem(i),
//           );
//         }),
//       ),
//     );
//   }
//
//   /// IntrinsicWidth so the underline pill stretches to exactly the
//   /// text width — Figma shows the underline matching each label's
//   /// glyph width (50 / 37 / 62 / 74).
//   Widget _tabItem(int i) {
//     final selected = _selectedTab == i;
//     return IntrinsicWidth(
//       child: GestureDetector(
//         behavior: HitTestBehavior.opaque,
//         onTap: () => setState(() => _selectedTab = i),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Padding(
//               padding: EdgeInsets.only(bottom: 4.h),
//               child: Text(
//                 _tabs[i],
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontFamily: AppTextStyle.fontFamily,
//                   fontSize: 16.sp,
//                   fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
//                   color: selected
//                       ? AppColors.textPrimaryDynamic(context)
//                       : AppColors.textSecondaryDynamic(context),
//                 ),
//               ),
//             ),
//             Container(
//               height: 4.h,
//               decoration: BoxDecoration(
//                 color: selected
//                     ? const Color(0xFFAA45FF)
//                     : Colors.transparent,
//                 borderRadius: BorderRadius.circular(9999.r),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildEmptyState() {
//     return Center(
//       child: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 28.w),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Figma empty-state badge — three layered shapes:
//             //  1) Outer light-grey circle (#F4F4F5) backdrop
//             //  2) subs.png document scroll inside it
//             //  3) Small darker-grey circle on the document with the X
//             //
//             // We stack them explicitly so the cross sits crisply on
//             // top regardless of what's baked into the PNG.
//             SizedBox(
//               width: 80.w,
//               height: 80.w,
//               child: Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   Container(
//                     width: 80.w,
//                     height: 80.w,
//                     decoration: BoxDecoration(
//                       color: AppColors.iconContainerDynamic(context),
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                   Image.asset(
//                     "assets/images/subs.png",
//                     width: 60.w,
//                     height: 60.w,
//                     fit: BoxFit.contain,
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 16.h),
//             Text(
//               "No Rankings Yet",
//               style: TextStyle(
//                 fontFamily: AppTextStyle.fontFamily,
//                 fontSize: 16.sp,
//                 fontWeight: FontWeight.w600,
//                 color: AppColors.textPrimaryDynamic(context),
//               ),
//             ),
//             SizedBox(height: 8.h),
//             Text(
//               "Start trading to see how you rank.",
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontFamily: AppTextStyle.fontFamily,
//                 fontSize: 16.sp,
//                 fontWeight: FontWeight.w400,
//                 color: AppColors.textSecondaryDynamic(context),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_style.dart';
import '../../widget/Common_header_withlogo.dart';

const Color _kPodiumPurple = Color(0xFF2E1065);
const Color _kRingGold = Color(0xFFEAB308); // 1st place
const Color _kRingSilver = Color(0xFFCBD5E1); // 2nd place
const Color _kRingBronze = Color(0xFFB45309); // 3rd place
const Color _kTrendUp = Color(0xFF22C55E);
const Color _kTrendDown = Color(0xFFDC2626);
const Color _kTrendSame = Color(0xFFA1A1AA);
const Color _kRowEven = Color(0xFFFFFFFF);
const Color _kRowOdd = Color(0xFFFAFAFA);
const Color _kRowYou = Color(0xFFFAF4FF); // current-user highlight
const Color _kListText = Color(0xFF27272A);
const Color _kPodiumSubText = Color(0xFFE4E4E7);

class RankingsPage extends StatefulWidget {
  const RankingsPage({super.key});

  @override
  State<RankingsPage> createState() => _RankingsPageState();
}

class _RankingsPageState extends State<RankingsPage> {
  int _selectedTab = 0;
  final PageController _pageController = PageController();

  static const List<String> _tabs = [
    'Overall',
    'Profit',
    'Win Rate',
    'Hot Streak',
  ];
  final bool _hasRankings = true;
  final List<_Ranker> _overall = const [
    _Ranker(
        rank: 1,
        name: 'Kwabena O.',
        avatar: 'assets/svgs/Frame 25.svg',
        value: '40 trades',
        trend: _Trend.up),
    _Ranker(
        rank: 2,
        name: 'Adwoa M.',
        avatar: 'assets/svgs/Frame 25 (1).svg',
        value: '38 trades',
        trend: _Trend.same),
    _Ranker(
        rank: 3,
        name: 'Yaw B.',
        avatar: 'assets/svgs/Frame 25 (2).svg',
        value: '35 trades',
        trend: _Trend.down),
    _Ranker(
        rank: 4,
        name: 'Akosua D.',
        avatar: 'assets/svgs/Frame 25 (3).svg',
        value: '31 trades',
        trend: _Trend.up),
    _Ranker(
        rank: 5,
        name: 'Kofi A.',
        avatar: 'assets/svgs/Frame 26.svg',
        value: '29 trades',
        trend: _Trend.down),
    _Ranker(
        rank: 6,
        name: 'Ama S.',
        avatar: 'assets/svgs/Frame 26 (1).svg',
        value: '27 trades',
        trend: _Trend.up),
    _Ranker(
        rank: 7,
        name: 'You',
        avatar: 'assets/svgs/Frame 26 (2).svg',
        value: '24 trades',
        trend: _Trend.up,
        isYou: true),
    _Ranker(
        rank: 8,
        name: 'Esi N.',
        avatar: 'assets/svgs/Frame 26 (3).svg',
        value: '21 trades',
        trend: _Trend.same),
    _Ranker(
        rank: 9,
        name: 'Fiifi K.',
        avatar: 'assets/svgs/Frame 27.svg',
        value: '18 trades',
        trend: _Trend.down),
  ];

  final List<_Ranker> _profit = const [
    _Ranker(
        rank: 1,
        name: 'Adwoa M.',
        avatar: 'assets/svgs/Frame 25 (1).svg',
        value: '¢12.5k',
        trend: _Trend.up),
    _Ranker(
        rank: 2,
        name: 'Kwabena O.',
        avatar: 'assets/svgs/Frame 25.svg',
        value: '¢11.7k',
        trend: _Trend.down),
    _Ranker(
        rank: 3,
        name: 'Kofi A.',
        avatar: 'assets/svgs/Frame 26.svg',
        value: '¢10.2k',
        trend: _Trend.up),
    _Ranker(
        rank: 4,
        name: 'Yaw B.',
        avatar: 'assets/svgs/Frame 25 (2).svg',
        value: '¢9.4k',
        trend: _Trend.same),
    _Ranker(
        rank: 5,
        name: 'Akosua D.',
        avatar: 'assets/svgs/Frame 25 (3).svg',
        value: '¢8.1k',
        trend: _Trend.up),
    _Ranker(
        rank: 6,
        name: 'You',
        avatar: 'assets/svgs/Frame 26 (2).svg',
        value: '¢6.8k',
        trend: _Trend.up,
        isYou: true),
    _Ranker(
        rank: 7,
        name: 'Ama S.',
        avatar: 'assets/svgs/Frame 26 (1).svg',
        value: '¢5.3k',
        trend: _Trend.down),
    _Ranker(
        rank: 8,
        name: 'Esi N.',
        avatar: 'assets/svgs/Frame 26 (3).svg',
        value: '¢4.6k',
        trend: _Trend.same),
    _Ranker(
        rank: 9,
        name: 'Fiifi K.',
        avatar: 'assets/svgs/Frame 27.svg',
        value: '¢3.9k',
        trend: _Trend.down),
  ];

  final List<_Ranker> _winRate = const [
    _Ranker(
        rank: 1,
        name: 'Yaw B.',
        avatar: 'assets/svgs/Frame 25 (2).svg',
        value: '95%',
        trend: _Trend.up),
    _Ranker(
        rank: 2,
        name: 'Esi N.',
        avatar: 'assets/svgs/Frame 26 (3).svg',
        value: '89%',
        trend: _Trend.up),
    _Ranker(
        rank: 3,
        name: 'Akosua D.',
        avatar: 'assets/svgs/Frame 25 (3).svg',
        value: '85%',
        trend: _Trend.same),
    _Ranker(
        rank: 4,
        name: 'Adwoa M.',
        avatar: 'assets/svgs/Frame 25 (1).svg',
        value: '82%',
        trend: _Trend.down),
    _Ranker(
        rank: 5,
        name: 'Kwabena O.',
        avatar: 'assets/svgs/Frame 25.svg',
        value: '78%',
        trend: _Trend.down),
    _Ranker(
        rank: 6,
        name: 'Kofi A.',
        avatar: 'assets/svgs/Frame 26.svg',
        value: '74%',
        trend: _Trend.up),
    _Ranker(
        rank: 7,
        name: 'You',
        avatar: 'assets/svgs/Frame 26 (2).svg',
        value: '71%',
        trend: _Trend.up,
        isYou: true),
    _Ranker(
        rank: 8,
        name: 'Ama S.',
        avatar: 'assets/svgs/Frame 26 (1).svg',
        value: '67%',
        trend: _Trend.same),
    _Ranker(
        rank: 9,
        name: 'Fiifi K.',
        avatar: 'assets/svgs/Frame 27.svg',
        value: '60%',
        trend: _Trend.down),
  ];

  final List<_Ranker> _hotStreak = const [
    _Ranker(
        rank: 1,
        name: 'Kofi A.',
        avatar: 'assets/svgs/Frame 26.svg',
        value: '14 days',
        trend: _Trend.up),
    _Ranker(
        rank: 2,
        name: 'Kwabena O.',
        avatar: 'assets/svgs/Frame 25.svg',
        value: '11 days',
        trend: _Trend.same),
    _Ranker(
        rank: 3,
        name: 'Ama S.',
        avatar: 'assets/svgs/Frame 26 (1).svg',
        value: '9 days',
        trend: _Trend.up),
    _Ranker(
        rank: 4,
        name: 'Yaw B.',
        avatar: 'assets/svgs/Frame 25 (2).svg',
        value: '7 days',
        trend: _Trend.down),
    _Ranker(
        rank: 5,
        name: 'Adwoa M.',
        avatar: 'assets/svgs/Frame 25 (1).svg',
        value: '5 days',
        trend: _Trend.up),
    _Ranker(
        rank: 6,
        name: 'Akosua D.',
        avatar: 'assets/svgs/Frame 25 (3).svg',
        value: '3 days',
        trend: _Trend.down),
    _Ranker(
        rank: 7,
        name: 'Esi N.',
        avatar: 'assets/svgs/Frame 26 (3).svg',
        value: '2 days',
        trend: _Trend.same),
    _Ranker(
        rank: 8,
        name: 'You',
        avatar: 'assets/svgs/Frame 26 (2).svg',
        value: '1 day',
        trend: _Trend.up,
        isYou: true),
    _Ranker(
        rank: 9,
        name: 'Fiifi K.',
        avatar: 'assets/svgs/Frame 27.svg',
        value: '1 day',
        trend: _Trend.same),
  ];

  List<_Ranker> _rankersFor(int tab) {
    switch (tab) {
      case 1:
        return _profit;
      case 2:
        return _winRate;
      case 3:
        return _hotStreak;
      case 0:
      default:
        return _overall;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBackgroundDynamic(context),
      appBar: const GlobalAppBar(showDivider: false),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _selectedTab = i),
              itemCount: _tabs.length,
              itemBuilder: (context, i) =>
                  _hasRankings ? _buildRankingContent(i) : _buildEmptyState(),
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

  Widget _tabItem(int i) {
    final selected = _selectedTab == i;
    return IntrinsicWidth(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() => _selectedTab = i);
          _pageController.animateToPage(
            i,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
          );
        },
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
                color: selected ? const Color(0xFFAA45FF) : Colors.transparent,
                borderRadius: BorderRadius.circular(9999.r),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingContent(int tab) {
    final data = _rankersFor(tab);
    final podium = data.take(3).toList();
    final rest = data.length > 3 ? data.sublist(3) : const <_Ranker>[];

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        children: [
          if (podium.length == 3) _buildPodium(podium),
          _buildList(rest),
        ],
      ),
    );
  }

  Widget _buildPodium(List<_Ranker> top) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
      decoration: BoxDecoration(
        color: _kPodiumPurple,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Stack(
          children: [
            // Faint Figma background texture (white at ~5% opacity).
            Positioned.fill(
              child: CustomPaint(painter: _PodiumPatternPainter()),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 20.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: _podiumAvatar(top[1], _PodiumRank.second)),
                  Expanded(child: _podiumAvatar(top[0], _PodiumRank.first)),
                  Expanded(child: _podiumAvatar(top[2], _PodiumRank.third)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _podiumAvatar(_Ranker r, _PodiumRank pos) {
    final bool isFirst = pos == _PodiumRank.first;
    final Color ringColor = pos == _PodiumRank.first
        ? _kRingGold
        : pos == _PodiumRank.second
            ? _kRingSilver
            : _kRingBronze;
    final String crown = pos == _PodiumRank.first
        ? 'assets/svgs/Ytaj.svg'
        : pos == _PodiumRank.second
            ? 'assets/svgs/Staj.svg'
            : 'assets/svgs/Otaj.svg';

    final double avatarSize = isFirst ? 92.w : 76.w;
    final double crownWidth = isFirst ? 46.w : 34.w;
    final double ringWidth = isFirst ? 4.w : 3.w;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(crown, width: crownWidth, fit: BoxFit.contain),
        SizedBox(height: 6.h),
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: ringColor, width: ringWidth),
          ),
          child: ClipOval(
            child: SvgPicture.asset(
              r.avatar,
              width: avatarSize,
              height: avatarSize,
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          r.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: AppTextStyle.fontFamily,
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          r.value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: AppTextStyle.fontFamily,
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: _kPodiumSubText,
          ),
        ),
      ],
    );
  }

  Widget _buildList(List<_Ranker> rows) {
    return Column(
      children: List.generate(rows.length, (i) {
        final r = rows[i];
        final Color bg = r.isYou ? _kRowYou : (i.isEven ? _kRowEven : _kRowOdd);
        return _rankRow(r, bg);
      }),
    );
  }

  Widget _rankRow(_Ranker r, Color bg) {
    final FontWeight weight = r.isYou ? FontWeight.w600 : FontWeight.w400;
    return Container(
      height: 64.h,
      color: bg,
      padding: EdgeInsets.symmetric(horizontal: 28.w),
      child: Row(
        children: [
          SizedBox(
            width: 22.w,
            child: Text(
              '${r.rank}',
              style: TextStyle(
                fontFamily: AppTextStyle.fontFamily,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: _kListText,
              ),
            ),
          ),
          SizedBox(width: 6.w),
          _trendIcon(r.trend),
          SizedBox(width: 12.w),
          ClipOval(
            child: SvgPicture.asset(
              r.avatar,
              width: 32.w,
              height: 32.w,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              r.isYou ? 'You' : r.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppTextStyle.fontFamily,
                fontSize: 16.sp,
                fontWeight: weight,
                color: _kListText,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            r.value,
            style: TextStyle(
              fontFamily: AppTextStyle.fontFamily,
              fontSize: 16.sp,
              fontWeight: weight,
              color: _kListText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _trendIcon(_Trend t) {
    switch (t) {
      case _Trend.up:
        return Icon(Icons.arrow_circle_up, size: 20.sp, color: _kTrendUp);
      case _Trend.down:
        return Icon(Icons.arrow_circle_down, size: 20.sp, color: _kTrendDown);
      case _Trend.same:
        return Icon(Icons.remove_circle, size: 20.sp, color: _kTrendSame);
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                  SvgPicture.asset(
                    "assets/svgs/Document.svg",
                    width: 48.w,
                    height: 60.w,
                    fit: BoxFit.contain,
                  ),
                  Container(
                    width: 25.w,
                    height: 25.w,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD4D4D8),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 15.sp,
                    ),
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

enum _Trend { up, down, same }

enum _PodiumRank { first, second, third }

class _Ranker {
  final int rank;
  final String name;
  final String avatar;
  final String value;
  final _Trend trend;
  final bool isYou;

  const _Ranker({
    required this.rank,
    required this.name,
    required this.avatar,
    required this.value,
    required this.trend,
    this.isYou = false,
  });
}

class _PodiumPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    const double spacing = 60;
    const double radius = 11;
    bool stagger = false;

    for (double y = 18; y < size.height; y += spacing) {
      final double startX = stagger ? 18 + spacing / 2 : 18;
      for (double x = startX; x < size.width; x += spacing) {
        for (int k = 0; k < 3; k++) {
          final double angle = math.pi / 3 * k; // 0°, 60°, 120°
          final double dx = radius * math.cos(angle);
          final double dy = radius * math.sin(angle);
          canvas.drawLine(
            Offset(x - dx, y - dy),
            Offset(x + dx, y + dy),
            paint,
          );
        }
      }
      stagger = !stagger;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
