import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_style.dart';
import '../../../data/model/ranking_entry.dart';
import '../../../data/provider/rankings_provider.dart';
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
const Color _kPodiumSubText = Color(0xFFE4E4E7);

/// Tab index → backend `category` string. Order matches the visible
/// label list below.
const List<String> _kCategories = [
  'overall',
  'profit',
  'win_rate',
  'hot_streak',
];
const List<String> _kTabLabels = [
  'Overall',
  'Profit',
  'Win Rate',
  'Hot Streak',
];

/// Rankings tab — wired to `RankingsProvider` ➜ `GET /api/rankings`.
///
/// Each tab caches its own state in the provider so swiping between them
/// is instant after first load. Page is built as four states:
///   - loading first page  → skeleton cards
///   - error               → centred message + Retry
///   - empty (total_users=0) → "No Rankings Yet" CTA card
///   - loaded              → optional "YOU #N" sticky chip, podium
///                           (top 3 in #2/#1/#3 layout), zebra list
///                           with infinite scroll + RefreshIndicator
class RankingsPage extends StatefulWidget {
  const RankingsPage({super.key});

  @override
  State<RankingsPage> createState() => _RankingsPageState();
}

class _RankingsPageState extends State<RankingsPage> {
  int _selectedTab = 0;
  final PageController _pageController = PageController();
  // One scroll controller per tab so each tab's list scrolls
  // independently and the infinite-scroll listener can target the
  // correct category.
  final List<ScrollController> _scrollControllers = List.generate(
    _kCategories.length,
    (_) => ScrollController(),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<RankingsProvider>();
      provider.setCategory(_kCategories[0]);
      provider.ensureLoaded();
    });
    for (var i = 0; i < _scrollControllers.length; i++) {
      _scrollControllers[i].addListener(() => _onScroll(i));
    }
  }

  void _onScroll(int tabIdx) {
    if (tabIdx != _selectedTab) return;
    final c = _scrollControllers[tabIdx];
    if (!c.hasClients) return;
    // Trigger pagination when ~200 px from the bottom.
    if (c.position.pixels >= c.position.maxScrollExtent - 200) {
      context.read<RankingsProvider>().loadMoreFor(_kCategories[tabIdx]);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final c in _scrollControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _selectTab(int i) {
    if (i == _selectedTab) return;
    setState(() => _selectedTab = i);
    context.read<RankingsProvider>().setCategory(_kCategories[i]);
    _pageController.animateToPage(
      i,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _onPageChanged(int i) {
    setState(() => _selectedTab = i);
    context.read<RankingsProvider>().setCategory(_kCategories[i]);
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
              onPageChanged: _onPageChanged,
              itemCount: _kTabLabels.length,
              itemBuilder: (context, i) => _TabContent(
                key: ValueKey('rankings_tab_$i'),
                category: _kCategories[i],
                scrollController: _scrollControllers[i],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 5.h, 16.w, 0.h),
      decoration: BoxDecoration(
        // Match the GlobalAppBar bg so the tab strip reads as part of the
        // header in dark mode (in light mode both are white already).
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderDynamic(context),
            width: 1,
          ),
        ),
      ),
      // Figma: tabs are spread edge-to-edge (space-between), and each tab's
      // underline matches the *text* width (IntrinsicWidth) — not text+padding.
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_kTabLabels.length, (i) {
          final bool active = i == _selectedTab;
          return IntrinsicWidth(
            child: GestureDetector(
              onTap: () => _selectTab(i),
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 4.h),
                    child: Text(
                      _kTabLabels[i],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTextStyle.fontFamily,
                        fontSize: 16.sp,
                        fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                        color: active
                            ? AppColors.textPrimaryDynamic(context)
                            : AppColors.textSecondaryDynamic(context),
                      ),
                    ),
                  ),
                  Container(
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: active
                          ? const Color(0xFFAA45FF)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(9999.r),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Per-tab content ──────────────────────────────────────────────────

class _TabContent extends StatelessWidget {
  const _TabContent({
    super.key,
    required this.category,
    required this.scrollController,
  });

  final String category;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Consumer<RankingsProvider>(
      builder: (context, provider, _) {
        final state = provider.stateFor(category);

        // First-time fetch — keep it visually quiet (plain spinner, no
        // skeleton); preserves Abhishek's Figma chrome on success.
        if (state.isLoading && state.response == null) {
          return const Center(child: CircularProgressIndicator());
        }
        // Network/parse failure: minimal centered text — no icon, no
        // button, doesn't introduce a new designed widget.
        if (state.error != null && state.response == null) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 28.w),
              child: Text(
                state.error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTextStyle.fontFamily,
                  fontSize: 14.sp,
                  color: AppColors.textSecondaryDynamic(context),
                ),
              ),
            ),
          );
        }
        final r = state.response;
        if (r == null || r.totalUsers == 0) {
          return const _EmptyView();
        }

        return SingleChildScrollView(
          controller: scrollController,
          padding: EdgeInsets.only(bottom: 24.h),
          child: Column(
            children: [
              if (r.podium.length == 3) _Podium(entries: r.podium),
              _LeaderboardList(entries: r.leaderboard, unit: r.unit),
            ],
          ),
        );
      },
    );
  }
}

// ── States: empty ────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
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
                    child: Icon(Icons.close, color: Colors.white, size: 15.sp),
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

// ── Podium ──────────────────────────────────────────────────────────

class _Podium extends StatelessWidget {
  const _Podium({required this.entries});
  final List<RankingEntry> entries; // backend has reordered to [#2, #1, #3]

  @override
  Widget build(BuildContext context) {
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
            Positioned.fill(child: CustomPaint(painter: _PodiumPatternPainter())),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 20.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: _PodiumAvatar(r: entries[0], pos: _PodiumPos.second)),
                  Expanded(child: _PodiumAvatar(r: entries[1], pos: _PodiumPos.first)),
                  Expanded(child: _PodiumAvatar(r: entries[2], pos: _PodiumPos.third)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _PodiumPos { first, second, third }

class _PodiumAvatar extends StatelessWidget {
  const _PodiumAvatar({required this.r, required this.pos});
  final RankingEntry r;
  final _PodiumPos pos;

  @override
  Widget build(BuildContext context) {
    final bool isFirst = pos == _PodiumPos.first;
    final Color ringColor = pos == _PodiumPos.first
        ? _kRingGold
        : pos == _PodiumPos.second
            ? _kRingSilver
            : _kRingBronze;
    final String crown = pos == _PodiumPos.first
        ? 'assets/svgs/Ytaj.svg'
        : pos == _PodiumPos.second
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
            child: _AvatarImage(url: r.displayImageUrl, size: avatarSize),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          r.isCurrentUser ? 'You' : r.name,
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
          _formatValue(r.value, _unitFromContext(context, pos)),
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
}

// The unit string is on the response, not the entry. Read it from the
// nearest provider since the podium is rebuilt cheaply on each change.
String _unitFromContext(BuildContext context, _PodiumPos pos) {
  final prov = context.read<RankingsProvider>();
  return prov.currentState.response?.unit ?? '';
}

// ── Leaderboard list ────────────────────────────────────────────────

class _LeaderboardList extends StatelessWidget {
  const _LeaderboardList({required this.entries, required this.unit});
  final List<RankingEntry> entries;
  final String unit;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    // Light mode keeps the original white / #FAFAFA zebra. Dark mode uses
    // the card bg with a faintly lighter odd row so the zebra survives,
    // and a deep-violet current-user tint instead of the light #FAF4FF.
    final Color rowEven =
        isDark ? AppColors.cardBackgroundDynamic(context) : _kRowEven;
    final Color rowOdd = isDark ? const Color(0xFF242426) : _kRowOdd;
    final Color rowYou = isDark ? const Color(0xFF2A1E3A) : _kRowYou;
    return Column(
      children: List.generate(entries.length, (i) {
        final r = entries[i];
        final Color bg = r.isCurrentUser
            ? rowYou
            : (i.isEven ? rowEven : rowOdd);
        return _RankRow(r: r, unit: unit, bg: bg);
      }),
    );
  }
}

class _RankRow extends StatelessWidget {
  const _RankRow({required this.r, required this.unit, required this.bg});
  final RankingEntry r;
  final String unit;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    final FontWeight weight =
        r.isCurrentUser ? FontWeight.w600 : FontWeight.w400;
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
                color: AppColors.textPrimaryDynamic(context),
              ),
            ),
          ),
          SizedBox(width: 6.w),
          _trendIcon(r.movement),
          SizedBox(width: 12.w),
          ClipOval(
            child: _AvatarImage(url: r.displayImageUrl, size: 32.w),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              r.isCurrentUser ? 'You' : r.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppTextStyle.fontFamily,
                fontSize: 16.sp,
                fontWeight: weight,
                color: AppColors.textPrimaryDynamic(context),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            _formatValue(r.value, unit),
            style: TextStyle(
              fontFamily: AppTextStyle.fontFamily,
              fontSize: 16.sp,
              fontWeight: weight,
              color: AppColors.textPrimaryDynamic(context),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _trendIcon(String movement) {
  switch (movement) {
    case 'up':
      return Icon(Icons.arrow_circle_up, size: 20.sp, color: _kTrendUp);
    case 'down':
      return Icon(Icons.arrow_circle_down, size: 20.sp, color: _kTrendDown);
    case 'same':
    case 'none':
    default:
      // v1 backend always returns 'none' (real arrows arrive with v2's
      // daily rank snapshots). Render the same grey dash-in-circle the
      // Figma uses for the no-change rows so the layout stays identical.
      return Icon(Icons.remove_circle, size: 20.sp, color: _kTrendSame);
  }
}

/// Format the unit-erased `value` per the category unit string.
///   trades / days → integer count.
///   GHS           → "₵12.50" with sign.
///   %             → "85%".
String _formatValue(double value, String unit) {
  switch (unit) {
    case 'GHS':
      return '₵${value.toStringAsFixed(2)}';
    case '%':
      return '${value.round()}%';
    case 'days':
      final n = value.round();
      return n == 1 ? '1 day' : '$n days';
    case 'trades':
      final n = value.round();
      return n == 1 ? '1 trade' : '$n trades';
    default:
      return value.toStringAsFixed(2);
  }
}

/// NetworkImage with a graceful fallback if [url] is null or fails to load.
class _AvatarImage extends StatelessWidget {
  const _AvatarImage({required this.url, required this.size});
  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return Container(
        width: size,
        height: size,
        color: AppColors.borderDynamic(context),
        alignment: Alignment.center,
        child: Icon(
          Icons.person,
          size: size * 0.6,
          color: AppColors.textSecondaryDynamic(context),
        ),
      );
    }
    return Image.network(
      url!,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: size,
        height: size,
        color: AppColors.borderDynamic(context),
        alignment: Alignment.center,
        child: Icon(
          Icons.person,
          size: size * 0.6,
          color: AppColors.textSecondaryDynamic(context),
        ),
      ),
    );
  }
}


class _PodiumPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
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
