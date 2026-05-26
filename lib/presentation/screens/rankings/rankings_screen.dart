import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
      appBar: GlobalAppBar(),
      body: Column(
        children: [
          // Tab strip — purple underline on active, muted on inactive
          TabBar(
            controller: _tab,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            indicatorPadding: EdgeInsets.symmetric(horizontal: 8.w),
            labelColor: AppColors.textPrimaryDynamic(context),
            unselectedLabelColor: AppColors.textSecondaryDynamic(context),
            labelStyle:
                AppTextStyle.body.copyWith(fontWeight: FontWeight.w700),
            unselectedLabelStyle:
                AppTextStyle.body.copyWith(fontWeight: FontWeight.w500),
            tabs: _tabs.map((t) => Tab(text: t.label)).toList(),
          ),
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: _tabs
                  .map(
                    (t) => _RankingTab(category: t.category),
                  )
                  .toList(),
            ),
          ),
        ],
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
    // Error and no cached data
    if (response == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 80.h),
          Center(
            child: Text(
              error ?? 'No data yet.',
              style: TextStyle(
                color: AppColors.textSecondaryDynamic(context),
              ),
            ),
          ),
        ],
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

class _EmptyState extends StatelessWidget {
  final String unit;
  const _EmptyState({required this.unit});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: 160.h),
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
              Text(
                'Start trading to see how you rank.',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textSecondaryDynamic(context),
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

  Color get _crownColor {
    switch (entry.rank) {
      case 1:
        return const Color(0xFFFFD700); // gold
      case 2:
        return Colors.white; // silver
      case 3:
      default:
        return const Color(0xFFCD7F32); // bronze
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarSize = isCentre ? 72.0 : 60.0;
    return Flexible(
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
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
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.white24,
                            alignment: Alignment.center,
                            child: Icon(Icons.person,
                                size: 26.sp, color: Colors.white),
                          ),
                        )
                      : Container(
                          color: Colors.white24,
                          alignment: Alignment.center,
                          child: Icon(Icons.person,
                              size: 26.sp, color: Colors.white),
                        ),
                ),
              ),
              Positioned(
                top: -12.h,
                child: Icon(
                  Icons.emoji_events, // trophy/crown stand-in
                  color: _crownColor,
                  size: 22.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            entry.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isCentre ? 13.sp : 12.sp,
              color: Colors.white,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            valueLabel,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
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
