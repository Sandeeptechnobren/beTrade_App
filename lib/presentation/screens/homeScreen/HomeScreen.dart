import 'package:betrade/core/theme/app_text_style.dart';
import '../../../data/provider/wallet_provider.dart';
import 'package:betrade/core/theme/app_text_style.dart';
import 'package:betrade/presentation/screens/homeScreen/trade_filter_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/share_helper.dart';
import '../../../data/model/trade_model.dart';
import '../../../data/provider/category_provider.dart';
import '../../../data/provider/connectivity_provider.dart';
import '../../../data/provider/default_amount_provider.dart';
import '../../../data/provider/positions_provider.dart';
import '../../../data/provider/trade_provider.dart';
import '../../../data/services/home_service.dart';
import '../../widget/common_bottom_sheet.dart';
import '../../widget/common_share_button.dart';
import '../../widget/customSnackBar.dart';
import '../profile/default_settings_page.dart';
import '../trade/trade_page.dart';

class HomeScreen extends StatefulWidget {
  final bool showKycBanner;
  final VoidCallback? onBannerTap;
  // QA #7 — wired up by MainScreen to jump to the Explore tab and
  // focus its search field. Null-safe so existing call sites that
  // don't pass it still work.
  final VoidCallback? onSearchTap;

  const HomeScreen({
    super.key,
    this.showKycBanner = false,
    this.onBannerTap,
    this.onSearchTap,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int selectedIndex = 0;
  int hintStep = 0;
  bool showHint = false;
  bool _isDisposed = false;
  final ScrollController _scrollController = ScrollController();
  late final AnimationController _hintCtrl;

  @override
  void initState() {
    super.initState();
    _hintCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _scrollController.addListener(() {
      if (!_isDisposed && mounted && _scrollController.hasClients) {
        if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
          try {
            context.read<TradeProvider>().loadMore();
          } catch (e) {
            debugPrint("Load more error: $e");
          }
        }
      }
    });

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed && mounted) {
        _initializeData();
      }
    });
  }

  Future<void> _initializeData() async {
    if (_isDisposed || !mounted) return;

    try {
      context.read<CategoryProvider>().fetchCategories();
      context.read<TradeProvider>().fetchTrades();
      context.read<DefaultAmountProvider>().loadFromBackend();
      context.read<PositionsProvider>().fetchOpenPositions();
      context.read<WalletProvider>().fetchBalance(); // KEEP wallet sync

      final prefs = await SharedPreferences.getInstance();
      if (_isDisposed || !mounted) return;

      final isFirstTime = prefs.getBool("isFirstTime") ?? true;

      if (isFirstTime && mounted && !_isDisposed) {
        setState(() {
          showHint = true;
        });
      }
    } catch (e) {
      debugPrint("Init error: $e");
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _hintCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _safeSetState(VoidCallback fn) {
    if (!_isDisposed && mounted) {
      setState(fn);
    }
  }

  void _openFilterBottomSheet(BuildContext context) {
    if (_isDisposed || !mounted) return;
    CommonBottomSheet.open(
      context: context,
      builder: (controller) => FilterBottomSheet(scrollController: controller),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // QA #5 — Available Cash pill in the header + breakdown sheet.
  // ─────────────────────────────────────────────────────────────

  /// Compact wallet pill rendered in the header (replaces the old
  /// "selectedCategory ⌄" dropdown — categories now surface as the
  /// chip rail directly below). Shows the user's Available Cash so
  /// they know what they can stake before swiping. Tap → opens a
  /// breakdown sheet (Available Cash + Open Positions value +
  /// Total Portfolio).
  Widget _balancePill() {
    return Consumer<WalletProvider>(
      builder: (context, wallet, _) {
        final hasLoaded = wallet.lastUpdated != null;
        final text = hasLoaded ? '₵${wallet.balance.toStringAsFixed(2)}' : '₵—';
        return GestureDetector(
          onTap: () => _openBalanceBreakdown(context),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: AppColors.iconContainerDynamic(context),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 14.sp,
                  color: AppColors.textPrimaryDynamic(context),
                ),
                SizedBox(width: 5.w),
                Text(
                  text,
                  style: TextStyle(
                    fontFamily: AppTextStyle.fontFamily,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryDynamic(context),
                  ),
                ),
                SizedBox(width: 2.w),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 14.sp,
                  color: AppColors.textPrimaryDynamic(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Bottom sheet shown when the user taps the balance pill.
  /// Computes Portfolio Balance client-side as
  ///   Available Cash (WalletProvider.balance)
  /// + Open Positions value (PositionsProvider.totalMarketValueGhs).
  /// `totalMarketValueGhs` is already a getter on PositionsProvider —
  /// no backend work needed.
  void _openBalanceBreakdown(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBackgroundDynamic(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (_) {
        return Consumer2<WalletProvider, PositionsProvider>(
          builder: (sheetCtx, wallet, positions, __) {
            final cash = wallet.balance;
            final invested = positions.totalMarketValueGhs;
            final total = cash + invested;
            return Padding(
              padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 28.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: AppColors.borderDynamic(sheetCtx),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 18.h),
                  Text(
                    "Portfolio Balance",
                    style: TextStyle(
                      fontFamily: AppTextStyle.fontFamily,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondaryDynamic(sheetCtx),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '₵${total.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontFamily: AppTextStyle.fontFamily,
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimaryDynamic(sheetCtx),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  _breakdownRow(sheetCtx, "Available Cash", cash),
                  SizedBox(height: 14.h),
                  _breakdownRow(sheetCtx, "Open Positions", invested),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _breakdownRow(BuildContext context, String label, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTextStyle.fontFamily,
            fontSize: 14.sp,
            color: AppColors.textSecondaryDynamic(context),
          ),
        ),
        Text(
          '₵${value.toStringAsFixed(2)}',
          style: TextStyle(
            fontFamily: AppTextStyle.fontFamily,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryDynamic(context),
          ),
        ),
      ],
    );
  }

  /// QA #5 — categories at first glance. Horizontal scrolling chip
  /// rail rendered directly below the header. Source = CategoryProvider
  /// (already loaded in _initializeData), selection state =
  /// TradeProvider.selectedCategory (same one the old "All ⌄"
  /// dropdown wrote to via FilterBottomSheet, so the swipe deck
  /// filter behaviour is unchanged).
  Widget _categoryChipRail(BuildContext context) {
    return Consumer2<CategoryProvider, TradeProvider>(
      builder: (_, cat, trade, __) {
        // 'All' is the virtual leading chip that resets the filter.
        // Some backends include 'All' in the category list themselves —
        // dedupe so we don't render two "All" chips.
        final raw = cat.categories.map((c) => c.name).toList();
        final names = raw.contains('All') ? raw : <String>['All', ...raw];
        return SizedBox(
          height: 38.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: names.length,
            separatorBuilder: (_, __) => SizedBox(width: 8.w),
            itemBuilder: (_, i) {
              final name = names[i];
              final selected = trade.selectedCategory == name;
              return GestureDetector(
                onTap: () {
                  trade.applyFilter(
                    category: name,
                    sort: trade.selectedSort,
                    date: trade.selectedDate,
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary
                        : AppColors.iconContainerDynamic(context),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    name,
                    style: TextStyle(
                      fontFamily: AppTextStyle.fontFamily,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? Colors.white
                          : AppColors.textPrimaryDynamic(context),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _closeHint() async {
    if (_isDisposed || !mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool("isFirstTime", false);
      _safeSetState(() {
        showHint = false;
      });
    } catch (e) {
      debugPrint("Close hint error: $e");
    }
  }

  Widget _buildHintHand() {
    final Widget hand = hintStep == 2
        ? Icon(Icons.touch_app, color: Colors.white, size: 58.sp)
        : SvgPicture.asset(
            hintStep == 0
                ? 'assets/svgs/swipe-left.svg'
                : 'assets/svgs/swipe-right.svg',
            width: 58.sp,
            height: 58.sp,
          );
    return AnimatedBuilder(
      animation: _hintCtrl,
      builder: (context, child) {
        final double t = Curves.easeInOut.transform(_hintCtrl.value);
        if (hintStep == 2) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: (1 - t) * 0.6,
                child: Container(
                  width: 56.w + 46.w * t,
                  height: 56.w + 46.w * t,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
              Transform.scale(scale: 1.0 - 0.16 * t, child: child),
            ],
          );
        }
        final double dir = hintStep == 0 ? -1.0 : 1.0;
        return Transform.translate(
          offset: Offset(dir * 46 * t, 0),
          child: child,
        );
      },
      child: hand,
    );
  }

  Widget _hintIndicator() {
    const Color purple = Color(0xFFC178FF);
    if (hintStep == 2) {
      return Container(
        width: 54.w,
        height: 4.h,
        decoration: BoxDecoration(
          color: purple,
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }
    final bool toRight = hintStep == 1;
    final Widget line = Container(
      width: 84.w,
      height: 4.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: LinearGradient(
          colors: toRight
              ? [purple.withValues(alpha: 0.0), purple]
              : [purple, purple.withValues(alpha: 0.0)],
        ),
      ),
    );
    final Widget head = Icon(
      toRight ? Icons.arrow_right : Icons.arrow_left,
      color: purple,
      size: 26.sp,
    );
    return AnimatedBuilder(
      animation: _hintCtrl,
      builder: (context, child) {
        final double t = Curves.easeInOut.transform(_hintCtrl.value);
        final double dir = toRight ? 1.0 : -1.0;
        return Transform.translate(
          offset: Offset(dir * 14 * t, 0),
          child: child,
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: toRight ? [line, head] : [head, line],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isDisposed) return const SizedBox();
    final provider = context.watch<CategoryProvider>();
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 9.h,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            "assets/logo/IconLogo.png",
                            height: 32.h,
                            width: 27.w,
                          ),
                          // Image.asset("assets/logo/IconLogo.png", height: 35.h),
                          SizedBox(width: 5.w),
                        ],
                      ),
                      // QA #5 — Available Cash pill replaces the old
                      // "selectedCategory ⌄" dropdown. The category surface
                      // moved into the horizontal chip rail below this
                      // header, where it's far more discoverable. Tapping
                      // the pill opens a Portfolio Balance breakdown.
                      _balancePill(),
                      // QA #7 — search shortcut + bell, grouped on the
                      // right. Tapping the magnifying glass switches to
                      // the Explore tab and auto-focuses its search field
                      // (handled by MainScreen via onSearchTap).
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: widget.onSearchTap,
                            child: Container(
                              width: 40.w,
                              height: 40.h,
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: AppColors.iconContainerDynamic(context),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.search,
                                size: 22.sp,
                                color: AppColors.textPrimaryDynamic(context),
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Container(
                            width: 40.w,
                            height: 40.h,
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              // Figma #F4F4F5
                              color: AppColors.iconContainerDynamic(context),
                              shape: BoxShape.circle,
                            ),
                            child: SvgPicture.asset(
                              "assets/svgs/Bell.svg",
                              width: 24.w,
                              height: 24.h,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // QA #5 — categories visible at first glance.
                // Horizontal scrolling chip rail, tap a chip to filter
                // the swipe deck. Source of truth = TradeProvider
                // (same filter the old "All ⌄" dropdown wrote to).
                _categoryChipRail(context),
                if (widget.showKycBanner)
                  GestureDetector(
                    onTap: widget.onBannerTap,
                    child: Container(
                      width: double.infinity,
                      color: Colors.orange.shade700,
                      padding: EdgeInsets.symmetric(
                        vertical: 12.h,
                        horizontal: 16.w,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              "Complete your KYC verification",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                Expanded(
                  child: provider.categories.isEmpty && provider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildPollList(
                          categoryName:
                              context.watch<TradeProvider>().selectedCategory,
                        ),
                ),
              ],
            ),
          ),
          if (showHint)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () async {
                  if (hintStep == 2) {
                    HapticFeedback.mediumImpact();
                    await _closeHint();
                  }
                },
                onHorizontalDragUpdate: (details) {
                  if (!showHint || _isDisposed) return;
                  if (details.delta.dx < -8 && hintStep == 0) {
                    HapticFeedback.mediumImpact();
                    _safeSetState(() {
                      hintStep = 1;
                    });
                  } else if (details.delta.dx > 8 && hintStep == 1) {
                    HapticFeedback.mediumImpact();
                    _safeSetState(() {
                      hintStep = 2;
                    });
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black.withOpacity(0.7),
                  child: SafeArea(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: Column(
                        key: ValueKey(hintStep),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildHintHand(),
                          SizedBox(height: 20.h),
                          Text(
                            hintStep == 0
                                ? "SWIPE LEFT FOR NO"
                                : hintStep == 1
                                    ? "SWIPE RIGHT FOR YES"
                                    : "TAP TO VIEW THE DETAILS",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 14.h),
                          _hintIndicator(),
                          SizedBox(height: 14.h),
                          Text(
                            hintStep == 0
                                ? "You're not convinced."
                                : hintStep == 1
                                    ? "You think it will happen."
                                    : "Get the full picture.",
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPollList({String? categoryName}) {
    final tradeProvider = context.watch<TradeProvider>();
    final isOffline = context.watch<ConnectivityProvider>().isOffline;

    if (tradeProvider.isLoading && tradeProvider.trades.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (tradeProvider.trades.isEmpty && !tradeProvider.isLoading) {
      // 1) Truly offline with no cached data.
      if (isOffline) {
        return _emptyState(
          icon: Icons.cloud_off,
          title: "You're offline",
          subtitle: "Connect to the internet to load markets.",
          onRetry: () => context.read<TradeProvider>().fetchTrades(),
        );
      }
      // 2) Online, but the fetch failed.
      if (tradeProvider.error.isNotEmpty) {
        return _emptyState(
          icon: Icons.error_outline_rounded,
          title: "Couldn't load markets",
          subtitle: "Something went wrong. Please try again.",
          onRetry: () => context.read<TradeProvider>().fetchTrades(),
        );
      }
      // 3) Online, no error — this category genuinely has no markets.
      final cat = tradeProvider.selectedCategory;
      final inCategory = cat.isNotEmpty && cat != "All";
      return _emptyState(
        icon: Icons.inbox_outlined,
        title: inCategory ? "No markets in $cat yet" : "No markets right now",
        subtitle: inCategory
            ? "Try a different category or check back soon."
            : "Check back soon.",
      );
    }

    return RefreshIndicator(
      key: ValueKey("list_$isOffline"), // Force rebuild on connection change
      color: AppColors.primary,
      backgroundColor: AppColors.whiteDynamic(context),
      onRefresh: () async {
        if (!_isDisposed && mounted) {
          await context.read<TradeProvider>().fetchTrades();
        }
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(10.w),
        itemCount: tradeProvider.trades.length +
            (tradeProvider.isPaginationLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < tradeProvider.trades.length) {
            final trade = tradeProvider.trades[index];
            return PollCard(trade: trade);
          } else {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }

  /// Shared empty / offline / error placeholder for the poll list. [onRetry] is
  /// optional — genuinely-empty categories pass null (no Retry button), while
  /// offline/error states pass a retry callback.
  Widget _emptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onRetry,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64.sp, color: Colors.grey),
            SizedBox(height: 16.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'SFProRounded',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryDynamic(context),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'SFProRounded',
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondaryDynamic(context),
              ),
            ),
            if (onRetry != null) ...[
              SizedBox(height: 16.h),
              TextButton(
                onPressed: onRetry,
                child: Text(
                  "Retry",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontFamily: 'SFProRounded',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class PollCard extends StatefulWidget {
  final TradeModel trade;

  const PollCard({super.key, required this.trade});

  @override
  State<PollCard> createState() => _PollCardState();
}

class _PollCardState extends State<PollCard>
    with SingleTickerProviderStateMixin {
  double _dragDx = 0;
  late final AnimationController _swipeCtrl;
  Animation<double>? _springAnim;

  @override
  void initState() {
    super.initState();
    _swipeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    )..addListener(() {
        if (_springAnim != null && mounted) {
          setState(() => _dragDx = _springAnim!.value);
        }
      });
  }

  @override
  void dispose() {
    _swipeCtrl.dispose();
    super.dispose();
  }

  void _springBack() {
    _springAnim = Tween<double>(begin: _dragDx, end: 0).animate(
      CurvedAnimation(parent: _swipeCtrl, curve: Curves.easeOutCubic),
    );
    _swipeCtrl.forward(from: 0);
  }

  /// Social-proof avatar stack rendered next to the trade count on the
  /// swipe card. Min 1, max 4 (backend currently sends up to 3 — `take(4)`
  /// is forward-compatible). White rim so avatars stay legible against
  /// the dark image overlay. Mirrors the pattern used on the Explore tab.
  Widget _traderAvatarStack(List<String> urls) {
    if (urls.isEmpty) return const SizedBox.shrink();
    final shown = urls.take(4).toList();
    return SizedBox(
      width: ((shown.length - 1) * 14 + 24).w,
      height: 24.h,
      child: Stack(
        children: [
          for (int i = 0; i < shown.length; i++)
            Positioned(left: (i * 14).w, child: _traderAvatar(shown[i])),
        ],
      ),
    );
  }

  Widget _traderAvatar(String url) {
    return Container(
      width: 24.w,
      height: 24.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: ClipOval(
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(
            Icons.person,
            size: 14.sp,
            color: Colors.grey.shade400,
          ),
        ),
      ),
    );
  }

  void _handleSwipe(String outcome) {
    if (!_ensureReadyToTrade()) return;
    _openTradeSheet(initialOutcome: outcome, useDefaultAmount: true);
  }

  void _openTradeSheet({
    String initialOutcome = 'yes',
    bool useDefaultAmount = false,
  }) {
    CommonBottomSheet.open(
      context: context,
      builder: (controller) => TradePage(
        scrollController: controller,
        tradeUuid: widget.trade.uuid ?? '',
        initialOutcome: initialOutcome,
        useDefaultAmount: useDefaultAmount,
      ),
    );
  }

  void _showSnack(String message) {
    CustomSnackBar.showError(
      context,
      message: message,
      duration: const Duration(seconds: 3),
    );
  }

  bool _ensureReadyToTrade() {
    final provider = context.read<DefaultAmountProvider>();
    if (!provider.hasLoaded || provider.defaultAmount == null) {
      CustomSnackBar.showLoader(
        context,
        message: "Loading your settings, please wait...",
        duration: const Duration(seconds: 2),
      );
      return false;
    }

    if (provider.defaultAmount! <= 0) {
      CustomSnackBar.showError(
        context,
        message: "Please set your default trade amount first",
        duration: const Duration(seconds: 3),
      );
      CommonBottomSheet.open(
        context: context,
        builder: (controller) =>
            DefaultSettingsPage(scrollController: controller),
      );
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final trade = widget.trade;

    return GestureDetector(
      onTap: () {
        debugPrint("CLICK UUID: ${trade.uuid}");
        CommonBottomSheet.open(
          context: context,
          builder: (controller) => TradePage(
            scrollController: controller,
            tradeUuid: trade.uuid,
          ),
        );
      },
      onHorizontalDragStart: (_) => _swipeCtrl.stop(),
      onHorizontalDragUpdate: (details) {
        if (!mounted) return;
        setState(() => _dragDx += details.delta.dx);
      },
      onHorizontalDragEnd: (details) {
        final double velocity = details.primaryVelocity ?? 0;
        final double dx = _dragDx;
        final double w = MediaQuery.of(context).size.width;
        final bool committed = velocity.abs() >= 300 || dx.abs() > w * 0.28;
        _springBack();

        if (!committed) return;
        final bool goYes = (dx != 0 ? dx : velocity) > 0;
        _handleSwipe(goYes ? "yes" : "no");
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        transform: Matrix4.translationValues(_dragDx, 0, 0)
          ..rotateZ(_dragDx / MediaQuery.of(context).size.width * 0.22),
        transformAlignment: Alignment.center,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30.r),
          child: Container(
            height: 605.h,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black
                : Colors.grey.shade900,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (trade.image != null && trade.image!.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: trade.image!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    placeholder: (context, url) => Container(
                      color: Colors.grey.shade900,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey.shade900,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_not_supported_outlined,
                              color: Colors.white24, size: 40.sp),
                          SizedBox(height: 8.h),
                          Text(
                            "Offline",
                            style: TextStyle(
                                color: Colors.white24, fontSize: 12.sp),
                          ),
                        ],
                      ),
                    ),
                  ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.black.withOpacity(0.85)
                            : Colors.black.withOpacity(0.6),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 14.h,
                  left: 14.w,
                  child: Container(
                    height: 36.h,
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.whiteDynamic(context),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Center(
                      child: Text(
                        trade.categoryName ?? "",
                        style: AppTextStyle.small,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 14.h,
                  right: 14.w,
                  child: CommonShareButton(onTap: () {}),
                ),
                Positioned(
                  bottom: 12.h,
                  left: 12.w,
                  right: 12.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Real trader profile avatars stacked (up to 4)
                          // replace the old empty white placeholder
                          // CircleAvatar. trade.traderAvatars is populated
                          // by /trade/list (backend caps at 3 today; the
                          // `.take(4)` is forward-compatible). When the
                          // market has zero traders yet, the stack hides
                          // and only the count remains.
                          if (trade.traderAvatars.isNotEmpty) ...[
                            _traderAvatarStack(trade.traderAvatars),
                            SizedBox(width: 6.w),
                          ],
                          Text(
                            "${trade.totalTradesDisplay} trades",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        trade.description ?? "",
                        style: AppTextStyle.headingWhite,
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        children: [
                          Expanded(
                              child: _modernVoteBar(
                                  "NO", trade.no?.percent ?? 0, Colors.red)),
                          SizedBox(width: 10.w),
                          Expanded(
                              child: _modernVoteBar("YES", 33, Colors.green)),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 80.h,
                  left: 24.w,
                  child: Opacity(
                    opacity: (_dragDx / 90).clamp(0.0, 1.0),
                    child: Transform.rotate(
                      angle: -0.35,
                      child: _swipeStamp("YES", const Color(0xFF22C55E)),
                    ),
                  ),
                ),
                Positioned(
                  top: 80.h,
                  right: 24.w,
                  child: Opacity(
                    opacity: (-_dragDx / 90).clamp(0.0, 1.0),
                    child: Transform.rotate(
                      angle: 0.35,
                      child: _swipeStamp("NO", const Color(0xFFEF4444)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _swipeStamp(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        border: Border.all(color: color, width: 4),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 34.sp,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _modernVoteBar(String label, int percent, Color color) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: const LinearGradient(
          colors: [Color(0xff2A2A2A), Color(0xff3A3A3A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                "$percent%",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: Stack(
              children: [
                Container(
                  height: 10.h,
                  width: double.infinity,
                  color: Colors.white,
                ),
                FractionallySizedBox(
                  widthFactor: percent / 100,
                  child: Container(
                    height: 10.h,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
