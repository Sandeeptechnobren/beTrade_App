import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_style.dart';
import '../../../data/model/ranking_entry.dart';
import '../../../data/provider/rankings_provider.dart';
import '../../widget/Common_header_withlogo.dart';

/// Leaderboard screen at bottom-nav index 2.
///
/// Four tabs: Overall / Profit / Win Rate / Hot Streak. Each tab
/// renders a podium (top 3) on a purple gradient card + a paginated
/// leaderboard list (from rank 4 onwards). The current user's row is
/// highlighted with a light purple background and the name rewritten
/// to "You" by the backend.
class RankingsScreen extends StatefulWidget {
  const RankingsScreen({super.key});

  @override
  State<RankingsScreen> createState() => _RankingsScreenState();
}

class _RankingsScreenState extends State<RankingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  // Keep these in display order. Backend accepts the snake_case
  // version — `category` field below.
  static const _tabs = <_RankingTabDef>[
    _RankingTabDef(label: 'Overall', category: 'overall'),
    _RankingTabDef(label: 'Profit', category: 'profit'),
    _RankingTabDef(label: 'Win Rate', category: 'win_rate'),
    _RankingTabDef(label: 'Hot Streak', category: 'hot_streak'),
  ];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: _tabs.length, vsync: this);
    // Fetch the first tab as soon as the frame paints; other tabs
    // fetch lazily when the user swipes to them.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context
            .read<RankingsProvider>()
            .fetch(category: _tabs[0].category);
      }
    });
    _tab.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tab.indexIsChanging) return;
    final cat = _tabs[_tab.index].category;
    final provider = context.read<RankingsProvider>();
    if (provider.responseFor(cat) == null) {
      provider.fetch(category: cat);
    }
  }

  @override
  void dispose() {
    _tab.removeListener(_onTabChanged);
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteDynamic(context),
      // Identical BeTrade™ + bell header as Explore/Portfolio/Profile
      // (via `GlobalAppBar`). The TabBar lives in the AppBar's native
      // `bottom` slot so Material binds it tightly to the title row
      // with no extra vertical padding — what the Figma rankings
      // layout needs.
      appBar: GlobalAppBar(
        showBottomDivider: false,
        bottom: _buildTabBar(context),
      ),
      body: TabBarView(
        controller: _tab,
        children: _tabs
            .map((t) => _RankingTab(category: t.category))
            .toList(),
      ),
    );
  }

  /// Tab strip rendered in `GlobalAppBar`'s `bottom` slot. Returns
  /// only the TabBar — the BeTrade™ + bell row is provided by
  /// `GlobalAppBar` itself so this screen matches Explore/Portfolio/
  /// Profile pixel-for-pixel above the tabs.
  PreferredSizeWidget _buildTabBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor =
        isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    return PreferredSize(
      preferredSize: Size.fromHeight(36.h),
      child: Theme(
        // Suppress the grey ripple/splash on tab cells so press feedback
        // doesn't render as a big grey rectangle behind the labels.
        data: Theme.of(context).copyWith(
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
        ),
        child: TabBar(
          controller: _tab,
          isScrollable: false,
          // Single hairline directly under the labels — the purple
          // active-tab indicator overlays this divider.
          dividerColor: dividerColor,
          dividerHeight: 1,
          indicatorSize: TabBarIndicatorSize.label,
          indicatorWeight: 3,
          indicatorPadding: EdgeInsets.zero,
          indicator: UnderlineTabIndicator(
            borderRadius: BorderRadius.circular(2),
            borderSide: BorderSide(
              color: AppColors.primary,
              width: 3,
            ),
          ),
          labelColor: AppColors.textPrimaryDynamic(context),
          unselectedLabelColor: AppColors.textSecondaryDynamic(context),
          labelStyle: AppTextStyle.body.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 14.sp,
          ),
          unselectedLabelStyle: AppTextStyle.body.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 14.sp,
          ),
          // Just enough vertical breathing room for the underline to
          // sit cleanly below the text.
          labelPadding: EdgeInsets.only(top: 4.h, bottom: 6.h),
          tabs: _tabs.map((t) => Tab(text: t.label)).toList(),
        ),
      ),
    );
  }
}

class _RankingTabDef {
  final String label;
  final String category;
  const _RankingTabDef({required this.label, required this.category});
}

/// One tab body — podium card + leaderboard list. Reads its own slice
/// of `RankingsProvider` via `Consumer` so a fetch on a different tab
/// doesn't rebuild this one.
class _RankingTab extends StatelessWidget {
  final String category;
  const _RankingTab({required this.category});

  @override
  Widget build(BuildContext context) {
    return Consumer<RankingsProvider>(
      builder: (context, provider, _) {
        final response = provider.responseFor(category);
        final loading = provider.isLoading(category);
        final error = provider.errorFor(category);

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () =>
              provider.fetch(category: category, force: true),
          child: _buildContent(context, response, loading, error),
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    RankingResponse? response,
    bool loading,
    String? error,
  ) {
    // Initial load — full screen spinner
    if (loading && response == null) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    // Error and no cached data — render the same styled empty state
    // as "no data yet" so the screen never falls back to raw plain
    // text. Pull-to-refresh will retry the fetch.
    if (response == null) {
      return _EmptyState(
        unit: '',
        message: error,
      );
    }

    // No traders yet — Figma's empty-state design for "Overall" with
    // no trade activity in the system.
    final hasData =
        response.podium.isNotEmpty || response.leaderboard.isNotEmpty;
    if (!hasData) {
      return _EmptyState(unit: response.unit);
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      children: [
        if (response.podium.isNotEmpty)
          _PodiumCard(podium: response.podium, response: response),
        SizedBox(height: 16.h),
        ...response.leaderboard.map(
          (entry) => _LeaderboardRow(entry: entry, response: response),
        ),
      ],
    );
  }
}

/// Figma rankings empty-state: light-grey circle with a cancel-style
/// icon, "No Rankings Yet" heading, then a one-line subtitle. Used
/// when the category has no qualifying users yet *and* when an error
/// dropped the response (the subtitle becomes the error text in that
/// case). The widget is a `ListView` so a `RefreshIndicator` wrapper
/// can still trigger pull-to-refresh from the empty surface.
class _EmptyState extends StatelessWidget {
  final String unit;
  final String? message;
  const _EmptyState({required this.unit, this.message});

  @override
  Widget build(BuildContext context) {
    final subtitle = message ?? 'Start trading to see how you rank.';
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: 140.h),
        Center(
          child: Column(
            children: [
              Container(
                width: 72.w,
                height: 72.w,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cancel_outlined,
                  size: 40.sp,
                  color: Colors.grey.shade500,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'No Rankings Yet',
                style: AppTextStyle.heading.copyWith(
                  fontSize: 18.sp,
                  color: AppColors.textPrimaryDynamic(context),
                ),
              ),
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textSecondaryDynamic(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Top-3 podium card — purple gradient with a subtle sparkle pattern,
/// three avatar+crown cells in [#2, #1, #3] order so #1 sits centre.
class _PodiumCard extends StatelessWidget {
  final List<RankingEntry> podium;
  final RankingResponse response;
  const _PodiumCard({required this.podium, required this.response});

  @override
  Widget build(BuildContext context) {
    // Backend already reorders to [#2, #1, #3] when 3 results exist.
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4A1A8A),
            Color(0xFF6B2EA8),
          ],
        ),
        image: const DecorationImage(
          image: AssetImage('assets/images/splash.png'),
          fit: BoxFit.cover,
          opacity: 0.25,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: podium.asMap().entries.map((e) {
          // After backend reorder: index 0 = rank 2, 1 = rank 1, 2 = rank 3
          final isCentreFirst = e.value.rank == 1;
          return _PodiumCell(
            entry: e.value,
            isCentre: isCentreFirst,
            valueLabel: response.formatValue(e.value.value),
          );
        }).toList(),
      ),
    );
  }
}

class _PodiumCell extends StatelessWidget {
  final RankingEntry entry;
  final bool isCentre;
  final String valueLabel;
  const _PodiumCell({
    required this.entry,
    required this.isCentre,
    required this.valueLabel,
  });

  /// Rank → ring + crown colour. Matches Figma's gold / silver / bronze
  /// medal palette (with bronze leaning warm-orange like the design).
  Color get _crownColor {
    switch (entry.rank) {
      case 1:
        return const Color(0xFFFFC83D); // gold
      case 2:
        return const Color(0xFFE6E6E6); // silver / off-white
      case 3:
      default:
        return const Color(0xFFE08A2C); // warm bronze (Figma value)
    }
  }

  @override
  Widget build(BuildContext context) {
    // Centre cell (#1) is visually elevated: larger avatar + bigger
    // crown + bolder name. Side cells (#2 left, #3 right) are slightly
    // smaller so the eye lands on #1 first.
    final avatarSize = isCentre ? 78.0 : 64.0;
    final crownSize = isCentre ? 26.0 : 20.0;
    final crownTopOffset = isCentre ? -18.0 : -14.0;
    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              // Spacer that reserves vertical room for the crown so the
              // Column below doesn't collide with the next row.
              SizedBox(height: avatarSize.w + 6.h),
              // Avatar with coloured ring.
              Positioned(
                top: 6.h,
                child: Container(
                  width: avatarSize.w,
                  height: avatarSize.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: _crownColor, width: 3),
                  ),
                  child: ClipOval(
                    child: entry.displayAvatar.isNotEmpty
                        ? Image.network(
                            entry.displayAvatar,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _avatarFallback(),
                          )
                        : _avatarFallback(),
                  ),
                ),
              ),
              // Crown — Figma uses a classic 3-peak crown with rounded
              // peaks. `LucideIcons.crown` is the closest line-icon
              // match available in the project's existing icon set.
              Positioned(
                top: crownTopOffset.h,
                child: Icon(
                  LucideIcons.crown,
                  color: _crownColor,
                  size: crownSize.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            entry.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isCentre ? 13.sp : 12.sp,
              color: Colors.white,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            valueLabel,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.white.withValues(alpha: 0.78),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarFallback() => Container(
        color: Colors.white24,
        alignment: Alignment.center,
        child: Icon(Icons.person, size: 26.sp, color: Colors.white),
      );
}

/// One row in the leaderboard list (rank 4+).
///
/// Row layout: movement-arrow + rank | avatar | name | value (right).
/// Current user's row gets a light-purple background tint so they
/// can spot themselves in the list.
class _LeaderboardRow extends StatelessWidget {
  final RankingEntry entry;
  final RankingResponse response;
  const _LeaderboardRow({required this.entry, required this.response});

  @override
  Widget build(BuildContext context) {
    final highlight = entry.isCurrentUser
        ? AppColors.primary.withValues(alpha: 0.08)
        : Colors.transparent;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: highlight,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          _MovementBadge(movement: entry.movement),
          SizedBox(width: 10.w),
          Text(
            '${entry.rank}',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryDynamic(context),
            ),
          ),
          SizedBox(width: 14.w),
          _RowAvatar(url: entry.displayAvatar),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              entry.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: entry.isCurrentUser
                    ? FontWeight.w700
                    : FontWeight.w500,
                color: AppColors.textPrimaryDynamic(context),
              ),
            ),
          ),
          Text(
            response.formatValue(entry.value),
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryDynamic(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _MovementBadge extends StatelessWidget {
  final String movement;
  const _MovementBadge({required this.movement});

  @override
  Widget build(BuildContext context) {
    // Backend currently returns 'none' for everyone (deferred to
    // phase 2). When it starts returning 'up' / 'down', this widget
    // surfaces them as coloured arrow chips.
    final isUp = movement == 'up';
    final isDown = movement == 'down';
    final color = isUp
        ? Colors.green.shade600
        : isDown
            ? Colors.red.shade600
            : Colors.grey.shade400;
    final icon = isUp
        ? Icons.arrow_upward_rounded
        : isDown
            ? Icons.arrow_downward_rounded
            : Icons.remove_rounded;
    return Container(
      width: 22.w,
      height: 22.w,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(icon, size: 14.sp, color: color),
      ),
    );
  }
}

class _RowAvatar extends StatelessWidget {
  final String url;
  const _RowAvatar({required this.url});

  @override
  Widget build(BuildContext context) {
    const size = 36.0;
    if (url.isEmpty) {
      return Container(
        width: size.w,
        height: size.w,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.person, size: 20.sp, color: Colors.white),
      );
    }
    return SizedBox(
      width: size.w,
      height: size.w,
      child: ClipOval(
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: Colors.grey.shade300,
            alignment: Alignment.center,
            child: Icon(Icons.person, size: 20.sp, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
