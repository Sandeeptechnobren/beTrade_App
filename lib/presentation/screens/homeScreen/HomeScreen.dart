import 'package:betrade/core/theme/app_text_style.dart';
import 'package:betrade/presentation/screens/homeScreen/trade_filter_bottom_sheet.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/model/category_detail_model.dart';
import '../../../data/model/trade_model.dart';
import '../../../data/provider/category_provider.dart';
import '../../../data/provider/default_amount_provider.dart';
import '../../../data/provider/trade_provider.dart';
import '../../../data/services/home_service.dart';
import '../../../data/services/market_card_service.dart';
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

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  int hintStep = 0;
  bool showHint = false;
  bool _isDisposed = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
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
                      Image.asset("assets/logo/IconLogo.png", height: 35.h),
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
                        decoration: BoxDecoration(
                          color: AppColors.inputFieldBgDynamic(context),
                          shape: BoxShape.circle,
                        ),
                        child:
                        // Center(
                        //   child: Icon(Icons.notifications_none, size: 20.sp),
                        // ),
                        Center(
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
                    await _closeHint();
                  }
                },
                onHorizontalDragUpdate: (details) {
                  if (!showHint || _isDisposed) return;
                  if (details.delta.dx < -8 && hintStep == 0) {
                    _safeSetState(() {
                      hintStep = 1;
                    });
                  } else if (details.delta.dx > 8 && hintStep == 1) {
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
                          Icon(
                            hintStep == 0
                                ? Icons.swipe_left
                                : hintStep == 1
                                ? Icons.swipe_right
                                : Icons.touch_app,
                            color: Colors.white,
                            size: 60,
                          ),
                          SizedBox(height: 20.h),
                          Text(
                            hintStep == 0
                                ? "SWIPE LEFT FOR NO"
                                : hintStep == 1
                                ? "SWIPE RIGHT FOR YES"
                                : "TAP TO VIEW DETAILS",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10.h),
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

  const PollCard({
    super.key,
    required this.trade,
  });

  @override
  State<PollCard> createState() => _PollCardState();
}

class _PollCardState extends State<PollCard> {

  MarketCardModel? tradeDetail;

  bool isLoading = false;

  // ✅ Prevent multiple API calls
  static final Map<String, MarketCardModel>
  _cache = {};

  @override
  void initState() {
    super.initState();
    _loadTradeDetail();
  }

  Future<void> _loadTradeDetail() async {

    if (isLoading) return;

    // ✅ USE UUID ONLY
    final uuid = widget.trade.uuid;

    debugPrint("TRADE UUID => $uuid");

    if (uuid.isEmpty) {

      debugPrint("❌ UUID EMPTY");

      return;
    }

    // ✅ CACHE CHECK
    if (_cache.containsKey(uuid)) {

      debugPrint(
        "✅ USING CACHED DATA",
      );

      setState(() {

        tradeDetail = _cache[uuid];
      });

      return;
    }

    try {

      isLoading = true;

      debugPrint(
        "🚀 MARKET CARD API CALL STARTED",
      );

      final result =
      await MarketCardService.getTradeDetail(
        uuid,
      );

      if (result != null) {

        debugPrint(
          "✅ MARKET CARD RESPONSE RECEIVED",
        );

        debugPrint(
          "TOTAL TRADES => ${result.totalTrades}",
        );

        debugPrint(
          "YES % => ${result.yesPercentage}",
        );

        debugPrint(
          "NO % => ${result.noPercentage}",
        );

        // ✅ SAVE CACHE
        _cache[uuid] = result;

        if (!mounted) return;

        setState(() {

          tradeDetail = result;
        });

      } else {

        debugPrint(
          "❌ MARKET DETAIL RESULT NULL",
        );
      }

    } catch (e) {

      debugPrint(
        "❌ MARKET CARD API ERROR => $e",
      );

    } finally {

      isLoading = false;

      debugPrint(
        "🏁 MARKET CARD API FINISHED",
      );
    }
  }

  void _handleSwipe(String outcome) {

    if (!_ensureReadyToTrade()) return;

    _openTradeSheet(
      initialOutcome: outcome,
      useDefaultAmount: true,
    );
  }

  void _openTradeSheet({
    String initialOutcome = 'yes',
    bool useDefaultAmount = false,
  }) {

    final uuid = widget.trade.uuid;

    if (uuid.isEmpty) return;

    CommonBottomSheet.open(
      context: context,
      builder: (controller) => TradePage(
        scrollController: controller,
        tradeUuid: uuid,
        initialOutcome: initialOutcome,
        useDefaultAmount: useDefaultAmount,
      ),
    );
  }

  bool _ensureReadyToTrade() {

    final provider =
    context.read<DefaultAmountProvider>();

    if (!provider.hasLoaded) {

      CustomSnackBar.showLoader(
        context,
        message: "Loading default amount...",
        duration: const Duration(seconds: 3),
      );

      return false;
    }

    if ((provider.defaultAmount ?? 0) <= 0) {

      CustomSnackBar.showError(
        context,
        message: "Please set default amount first",
        duration: const Duration(seconds: 3),
      );

      CommonBottomSheet.open(
        context: context,
        builder: (controller) =>
            DefaultSettingsPage(
              scrollController: controller,
            ),
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

        if (!_ensureReadyToTrade()) return;

        _openTradeSheet();
      },

      onHorizontalDragEnd: (details) {

        final velocity =
            details.primaryVelocity ?? 0;

        if (velocity.abs() < 300) return;

        if (velocity > 0) {

          _handleSwipe("yes");

        } else {

          _handleSwipe("no");
        }
      },

      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),

        child: ClipRRect(
          borderRadius:
          BorderRadius.circular(30.r),

          child: Container(
            height: 605.h,

            color:
            Theme.of(context).brightness ==
                Brightness.dark
                ? Colors.black
                : Colors.grey.shade900,

            child: Stack(
              fit: StackFit.expand,

              children: [

                if (trade.image?.isNotEmpty == true)
                  Image.network(

                    trade.image!,

                    fit: BoxFit.cover,

                    width: double.infinity,

                    height: double.infinity,

                    loadingBuilder:
                        (
                        context,
                        child,
                        progress,
                        ) {

                      if (progress == null) {
                        return child;
                      }

                      return Container(
                        color: Colors.grey.shade300,

                        child: const Center(
                          child:
                          CircularProgressIndicator(),
                        ),
                      );
                    },

                    errorBuilder:
                        (
                        context,
                        error,
                        stackTrace,
                        ) {

                      return Container(
                        color: Colors.grey.shade800,

                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),

                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,

                      colors: [

                        Colors.transparent,

                        Colors.black.withOpacity(
                          0.85,
                        ),
                      ],
                    ),
                  ),
                ),

                Positioned(
                  top: 14.h,
                  left: 14.w,

                  child: Container(
                    height: 36.h,

                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius:
                      BorderRadius.circular(
                        16.r,
                      ),
                    ),

                    child: Center(
                      child: Text(
                        trade.categoryName,
                        style: AppTextStyle.small,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: 14.h,
                  right: 14.w,

                  child: CommonShareButton(
                    onTap: () {},
                  ),
                ),
                Positioned(
                  bottom: 14.h,
                  left: 14.w,
                  right: 14.w,
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [

                      Row(
                        children: [

                          SizedBox(

                            height: 30.h,

                            width: (() {

                              final count =
                                  tradeDetail?.users.length ?? 0;

                              if (count == 0) {
                                return 30.w;
                              }

                              if (count == 1) {
                                return 30.w;
                              }

                              if (count == 2) {
                                return 50.w;
                              }

                              return 70.w;

                            })(),

                            child: Stack(

                              children: List.generate(

                                tradeDetail?.users.length ?? 0,

                                    (index) {

                                  if (index > 2) {
                                    return const SizedBox();
                                  }

                                  final user =
                                  tradeDetail!.users[index];

                                  return Positioned(

                                    left: index * 20,

                                    child: CircleAvatar(

                                      radius: 14.r,

                                      backgroundColor:
                                      Colors.white,

                                      backgroundImage:
                                      user.image.isNotEmpty
                                          ? NetworkImage(
                                        user.image,
                                      )
                                          : null,

                                      child:
                                      user.image.isEmpty
                                          ? Icon(
                                        Icons.person,
                                        size: 14.sp,
                                        color: Colors.grey,
                                      )
                                          : null,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          SizedBox(width: 8.w),

                          Text(
                            "${tradeDetail?.totalTrades ?? 0} trades",

                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight:
                              FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 10.h),

                      Text(
                        trade.description,
                        style:
                        AppTextStyle.headingWhite,
                      ),

                      SizedBox(height: 14.h),

                      Row(
                        children: [

                          Expanded(
                            child: _modernVoteBar(
                              "NO",
                              tradeDetail
                                  ?.noPercentage ?? 0,
                              Colors.red,
                            ),
                          ),

                          SizedBox(width: 10.w),

                          Expanded(
                            child: _modernVoteBar(
                              "YES",
                              tradeDetail
                                  ?.yesPercentage ?? 0,
                              Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _modernVoteBar(
      String label,
      int percent,
      Color color,
      ) {

    return Container(
      padding: EdgeInsets.all(14.w),

      decoration: BoxDecoration(

        borderRadius:
        BorderRadius.circular(20.r),

        gradient: const LinearGradient(

          colors: [

            Color(0xff2A2A2A),
            Color(0xff3A3A3A),
          ],

          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

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
            borderRadius:
            BorderRadius.circular(20.r),

            child: Stack(
              children: [

                Container(
                  height: 10.h,
                  width: double.infinity,
                  color: Colors.white,
                ),

                FractionallySizedBox(

                  widthFactor:
                  (percent.clamp(0, 100)) / 100,

                  child: Container(
                    height: 10.h,

                    decoration: BoxDecoration(
                      color: color,

                      borderRadius:
                      BorderRadius.circular(
                        20.r,
                      ),
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