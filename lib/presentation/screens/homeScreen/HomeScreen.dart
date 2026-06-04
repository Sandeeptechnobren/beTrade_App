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
import '../../../data/model/trade_model.dart';
import '../../../data/provider/category_provider.dart';
import '../../../data/provider/default_amount_provider.dart';
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

  const HomeScreen({
    super.key,
    this.showKycBanner = false,
    this.onBannerTap,
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

  // Loops the swipe/tap hint hand until the user performs the gesture.
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
            debugPrint("❌ Load more error: $e");
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
      // Sync the user's default amount from `/userDefaultSettings/list` so
      // the swipe action sends the correct cost_ghs even if the user
      // hasn't opened Default Settings yet this session.
      context.read<DefaultAmountProvider>().loadFromBackend();

      final prefs = await SharedPreferences.getInstance();

      if (_isDisposed || !mounted) return;

      bool isFirstTime = prefs.getBool("isFirstTime") ?? true;

      if (isFirstTime && mounted && !_isDisposed) {
        setState(() {
          showHint = true;
        });
      }
    } catch (e) {
      debugPrint("❌ Init error: $e");
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

  /// Animated hint hand — nudges left/right for the swipe steps and does a
  /// tap-pulse for the tap step. Loops via [_hintCtrl] until the user acts.
  Widget _buildHintHand() {
    // Figma swipe-hand SVGs for the swipe steps; tap step keeps the Material
    // tap icon (no tap SVG supplied).
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
          // Tap step: a ripple ring expands behind a pulsing hand.
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
        // Swipe nudge: left for step 0 (NO), right for step 1 (YES).
        final double dir = hintStep == 0 ? -1.0 : 1.0;
        return Transform.translate(
          offset: Offset(dir * 46 * t, 0),
          child: child,
        );
      },
      child: hand,
    );
  }

  /// The purple swipe arrow for the swipe steps (left for NO, right for YES),
  /// or a short bar for the tap step — matches the Figma hint. The arrow
  /// nudges in the swipe direction along with the hand.
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
    final bool toRight = hintStep == 1; // step 0 = left (NO), 1 = right (YES)
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
                          Image.asset("assets/logo/IconLogo.png", height:32.h,width: 27.w,),
                          // Image.asset("assets/logo/IconLogo.png", height: 35.h),
                          SizedBox(width: 5.w),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => _openFilterBottomSheet(context),
                        child: Row(
                          children: [
                            Text(
                              context.watch<TradeProvider>().selectedCategory,
                              style: AppTextStyle.body,
                            ),
                            Icon(Icons.keyboard_arrow_down),
                          ],
                        ),
                      ),
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
                      // Container(
                      //   width: 40.w,
                      //   height: 40.h,
                      //   decoration: BoxDecoration(
                      //     color: AppColors.inputFieldBgDynamic(context),
                      //     shape: BoxShape.circle,
                      //   ),
                      //   child:
                      //   // Center(
                      //   //   child: Icon(Icons.notifications_none, size: 20.sp),
                      //   // ),
                      //   Center(
                      //     child: Image.asset(
                      //       "assets/images/Bell.png",
                      //       width: 20.w,
                      //       height: 20.h,
                      //       fit: BoxFit.contain,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
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
                  child: provider.categories.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : _buildPollList(
                    categoryName: context
                        .watch<TradeProvider>()
                        .selectedCategory,
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
                    HapticFeedback.mediumImpact(); // confirm the tap
                    await _closeHint();
                  }
                },
                onHorizontalDragUpdate: (details) {
                  if (!showHint || _isDisposed) return;
                  if (details.delta.dx < -8 && hintStep == 0) {
                    HapticFeedback.mediumImpact(); // confirm the left swipe
                    _safeSetState(() {
                      hintStep = 1;
                    });
                  } else if (details.delta.dx > 8 && hintStep == 1) {
                    HapticFeedback.mediumImpact(); // confirm the right swipe
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

    if (tradeProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (tradeProvider.error.isNotEmpty) {
      return Center(child: Text(tradeProvider.error));
    }
    if (tradeProvider.trades.isEmpty) {
      return const Center(child: Text("No Data"));
    }

    return RefreshIndicator(
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
        itemCount:
        tradeProvider.trades.length +
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
}

class PollCard extends StatefulWidget {
  final TradeModel trade;

  const PollCard({super.key, required this.trade});

  @override
  State<PollCard> createState() => _PollCardState();
}

class _PollCardState extends State<PollCard>
    with SingleTickerProviderStateMixin {
  // Live horizontal drag offset (px): >0 = swiping right (YES), <0 = left (NO).
  double _dragDx = 0;

  // Drives the smooth spring-back to centre after each release.
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

  /// Glide the card smoothly back to centre (runs on every release).
  void _springBack() {
    _springAnim = Tween<double>(begin: _dragDx, end: 0).animate(
      CurvedAnimation(parent: _swipeCtrl, curve: Curves.easeOutCubic),
    );
    _swipeCtrl.forward(from: 0);
  }

  /// Swipe and tap both open the same `TradePage` bottom sheet (one
  /// consistent UX) but they differ in how the cost is set:
  ///
  ///   * Swipe → pre-fills `amount` from `DefaultAmountProvider` and
  ///     hides the input field + quick chips (`useDefaultAmount: true`).
  ///     The user just confirms with Buy.
  ///   * Tap → leaves `amount = 0`; user types it in the input field.
  ///
  /// Swipe direction is forwarded as `initialOutcome` so the YES/NO
  /// toggle is pre-selected.
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
      message: "Please set a valid default amount first",
      duration: const Duration(seconds: 3),
    );
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text(message),
    //     backgroundColor: Colors.red,
    //   ),
    // );
  }

  bool _ensureReadyToTrade() {
    final provider = context.read<DefaultAmountProvider>();

    // Still fetching from backend (or never started). Don't treat a
    // null amount as "user has no default" — that case is handled below
    // after the load has actually completed. Show a brief purple loader
    // so the swipe doesn't feel ignored.
    if (!provider.hasLoaded || provider.defaultAmount == null) {
      CustomSnackBar.showLoader(
        context,
        message: "Loading your settings, please wait...",
        duration: const Duration(seconds: 2),
      );
      return false;
    }

    // Loaded, but the user genuinely has no default amount set. Send
    // them to the settings sheet so they can pick one before this
    // swipe-buy makes sense.
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
        // Tap path doesn't use the default amount — the user types the
        // cost themselves on TradePage. So no _ensureReadyToTrade gate
        // here. Only the swipe path (which pre-fills from the default)
        // gates on the provider state.
        debugPrint("CLICK UUID: ${trade.uuid}");
        CommonBottomSheet.open(
          context: context,
          builder: (controller) => TradePage(
            scrollController: controller,
            tradeUuid: trade.uuid,
          ),
        );
      },

      // 👇 SWIPE LOGIC + live direction feedback (YES = right / NO = left)
      onHorizontalDragStart: (_) => _swipeCtrl.stop(),
      onHorizontalDragUpdate: (details) {
        if (!mounted) return;
        setState(() => _dragDx += details.delta.dx);
      },
      onHorizontalDragEnd: (details) {
        final double velocity = details.primaryVelocity ?? 0;
        final double dx = _dragDx;
        final double w = MediaQuery.of(context).size.width;

        // Commit on a quick flick OR a far-enough drag.
        final bool committed = velocity.abs() >= 300 || dx.abs() > w * 0.28;

        // Always glide the card back to centre (smooth, not a jump).
        _springBack();

        if (!committed) return;
        // Direction from the drag, falling back to the flick velocity.
        final bool goYes = (dx != 0 ? dx : velocity) > 0;
        _handleSwipe(goYes ? "yes" : "no"); // 👉 yes = right, 👈 no = left
      },

      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        // Follow the finger + a subtle tilt — production swipe feel.
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
                  Image.network(
                    trade.image!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),

                /// Gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.black.withOpacity(0.85)
                            : Colors.black.withOpacity(0.6), // light me halka
                      ],
                    ),
                  ),
                ),

                /// Bottom Content
                Positioned(
                  top: 14.h,
                  left: 14.w,
                  child: Container(
                    height: 36.h,
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
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
                  right:14.w,
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
                          CircleAvatar(
                            radius: 12.r,
                            backgroundColor: Colors.white,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            "3975 trades",
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
                          Expanded(child: _modernVoteBar("NO", 67, Colors.red)),
                          SizedBox(width: 10.w),
                          Expanded(child: _modernVoteBar("YES", 33, Colors.green)),
                        ],
                      ),
                    ],
                  ),
                ),

                // 👉 Swipe-right (YES) stamp — fades in as you drag right.
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
                // 👈 Swipe-left (NO) stamp — fades in as you drag left.
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

  /// Tinder-style stamp shown over the card while swiping
  /// (YES = right / green, NO = left / red). Opacity is driven by [_dragDx].
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