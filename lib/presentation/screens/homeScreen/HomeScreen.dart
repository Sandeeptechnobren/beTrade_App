import 'package:betrade/core/theme/app_text_style.dart';
import 'package:betrade/presentation/screens/homeScreen/trade_filter_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/model/trade_model.dart';
import '../../../data/provider/category_provider.dart';
import '../../../data/provider/default_amount_provider.dart';
import '../../../data/provider/trade_provider.dart';
import '../../widget/common_bottom_sheet.dart';
import '../../widget/common_share_button.dart';
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
                      Image.asset(
                        "assets/images/IconLogo.png",
                        height: 35.h,
                        errorBuilder: (_, __, ___) => const SizedBox(),
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

  const PollCard({super.key, required this.trade});

  @override
  State<PollCard> createState() => _PollCardState();
}

class _PollCardState extends State<PollCard> {
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  bool _ensureReadyToTrade() {
    final provider = context.read<DefaultAmountProvider>();
    if (!provider.hasLoaded) {
      _showSnack("Loading default amount, please wait...");
      return false;
    }
    if (provider.defaultAmount <= 0) {
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
        if (!_ensureReadyToTrade()) return;
        CommonBottomSheet.open(
          context: context,
          builder: (controller) => TradePage(
            scrollController: controller,
            tradeUuid: trade.uuid,
          ),
        );
      },

      // 👇 SWIPE LOGIC HERE
      onHorizontalDragEnd: (details) {
        double velocity = details.primaryVelocity ?? 0;

        if (velocity.abs() < 300) return;

        if (velocity > 0) {
          _handleSwipe("yes"); // 👉 RIGHT
        } else {
          _handleSwipe("no"); // 👈 LEFT
        }
      },

      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
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
              ],
            ),
          ),
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

// class PollCard extends StatelessWidget {
//   final TradeModel trade;
//
//   const PollCard({super.key, required this.trade});
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         debugPrint("CLICK UUID: ${trade.uuid}");
//         CommonBottomSheet.open(
//           context: context,
//           builder: (controller) =>
//               TradePage(scrollController: controller, tradeUuid: trade.uuid),
//         );
//       },
//       child:
//       Container(
//         margin: EdgeInsets.only(bottom: 10.h),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(30.r),
//           child: Container(
//             height: 605.h,
//             color: Theme.of(context).brightness == Brightness.dark
//                 ? Colors.black
//                 : Colors.grey.shade900,
//             child: Stack(
//               fit: StackFit.expand,
//               children: [
//                 if (trade.image != null && trade.image!.isNotEmpty)
//                   Image.network(
//                     trade.image!,
//                     fit: BoxFit.cover,
//                     width: double.infinity,
//                     height: double.infinity,
//                     loadingBuilder: (context, child, progress) {
//                       if (progress == null) return child;
//
//                       return Container(
//                         color: Theme.of(context).brightness == Brightness.dark
//                             ? Colors.black
//                             : Colors.grey.shade900,
//                         child: const Center(
//                           child: CircularProgressIndicator(),
//                         ),
//                       );
//                     },
//                     errorBuilder: (context, error, stackTrace) {
//                       return Container(
//                         color: Theme.of(context).brightness == Brightness.dark
//                             ? Colors.black
//                             : Colors.grey.shade900,
//                       );
//                     },
//                   ),
//
//                 /// ✅ GRADIENT (ADAPTIVE)
//                 Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                       colors: [
//                         Colors.transparent,
//                         Theme.of(context).brightness == Brightness.dark
//                             ? Colors.black.withOpacity(0.85)
//                             : Colors.black.withOpacity(0.6), // light me halka
//                       ],
//                     ),
//                   ),
//                 ),
//
//                 /// ✅ CATEGORY TAG
//                 Positioned(
//                   top: 14.h,
//                   left: 14.w,
//                   child: Container(
//                     height: 36.h,
//                     padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
//                     decoration: BoxDecoration(
//                       color: AppColors.whiteDynamic(context),
//                       borderRadius: BorderRadius.circular(16.r),
//                     ),
//                     child: Center(
//                       child: Text(
//                         trade.categoryName ?? "",
//                         style: AppTextStyle.small,
//                       ),
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   top: 14.h,
//                   right:14.w,
//                   child: CommonShareButton(onTap: () {}),
//                 ),
//                 Positioned(
//                   bottom: 12.h,
//                   left: 12.w,
//                   right: 12.w,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           CircleAvatar(
//                             radius: 12.r,
//                             backgroundColor: Colors.white,
//                           ),
//                           SizedBox(width: 4.w),
//                           Text(
//                             "3975 trades",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 12.sp,
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 6.h),
//
//                       Text(
//                         trade.description ?? "",
//                         style: AppTextStyle.headingWhite,
//                       ),
//
//                       SizedBox(height: 10.h),
//
//                       Row(
//                         children: [
//                           Expanded(child: _modernVoteBar("NO", 67, Colors.red)),
//                           SizedBox(width: 10.w),
//                           Expanded(child: _modernVoteBar("YES", 33, Colors.green)),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       // child:ClipRRect(
//       //   borderRadius: BorderRadius.circular(25.r),
//       //   child: Container(
//       //     height: 605.h,
//       //     margin: EdgeInsets.only(bottom: 10.h),
//       //     decoration: BoxDecoration(borderRadius: BorderRadius.circular(25.r)),
//       //     child: Stack(
//       //       children: [
//       //         if (trade.image != null && trade.image!.isNotEmpty)
//       //           ClipRRect(
//       //             borderRadius: BorderRadius.circular(0.r),
//       //             child: Image.network(
//       //               trade.image!,
//       //               height: double.infinity,
//       //               width: double.infinity,
//       //               fit: BoxFit.cover,
//       //               loadingBuilder: (context, child, loadingProgress) {
//       //                 if (loadingProgress == null) return child;
//       //                 return Container(
//       //                   color: Colors.grey.shade800,
//       //                   child: const Center(
//       //                     child: CircularProgressIndicator(),
//       //                   ),
//       //                 );
//       //               },
//       //               errorBuilder: (context, error, stackTrace) {
//       //                 debugPrint("❌ Image error: $error");
//       //                 return Container(color: Colors.grey.shade800);
//       //               },
//       //             ),
//       //           ),
//       //         Container(
//       //           decoration: BoxDecoration(
//       //             borderRadius: BorderRadius.circular(16.r),
//       //             gradient: LinearGradient(
//       //               begin: Alignment.topCenter,
//       //               end: Alignment.bottomCenter,
//       //               colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
//       //             ),
//       //           ),
//       //         ),
//       //         Positioned(
//       //           top: 12.h,
//       //           left: 12.w,
//       //           child: Container(
//       //             height: 36.h,
//       //             padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
//       //             decoration: BoxDecoration(
//       //               color: AppColors.whiteDynamic(context),
//       //               borderRadius: BorderRadius.circular(16.r),
//       //             ),
//       //             child: Center(
//       //               child: Text(
//       //                 trade.categoryName ?? "",
//       //                 style: AppTextStyle.small,
//       //               ),
//       //             ),
//       //           ),
//       //         ),
//       //         Positioned(
//       //           top: 12.h,
//       //           right: 12.w,
//       //           child: CommonShareButton(onTap: () {}),
//       //         ),
//       //         Positioned(
//       //           bottom: 12.h,
//       //           left: 12.w,
//       //           right: 12.w,
//       //           child: Column(
//       //             crossAxisAlignment: CrossAxisAlignment.start,
//       //             children: [
//       //               Row(
//       //                 children: [
//       //                   CircleAvatar(radius: 12.r, backgroundColor: Colors.white),
//       //                   SizedBox(width: 4.w),
//       //                   Text(
//       //                     "3975 trades",
//       //                     style: TextStyle(color: Colors.white, fontSize: 12.sp),
//       //                   ),
//       //                 ],
//       //               ),
//       //               SizedBox(height: 6.h),
//       //               Text(
//       //                 trade.description ?? "",
//       //                 style: AppTextStyle.headingWhite,
//       //               ),
//       //               SizedBox(height: 10.h),
//       //               Row(
//       //                 children: [
//       //                   Expanded(child: _modernVoteBar("NO", 67, Colors.red)),
//       //                   SizedBox(width: 10.w),
//       //                   Expanded(child: _modernVoteBar("YES", 33, Colors.green)),
//       //                 ],
//       //               ),
//       //             ],
//       //           ),
//       //         ),
//       //       ],
//       //     ),
//       //   ),
//       // ),
//     );
//   }
//
//   Widget _modernVoteBar(String label, int percent, Color color) {
//     return Container(
//       padding: EdgeInsets.all(14.w),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(20.r),
//         gradient: const LinearGradient(
//           colors: [Color(0xff2A2A2A), Color(0xff3A3A3A)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Text(
//                 label,
//                 style: TextStyle(
//                   color: color,
//                   fontSize: 14.sp,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const Spacer(),
//               Text(
//                 "$percent%",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 14.sp,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 10.h),
//           ClipRRect(
//             borderRadius: BorderRadius.circular(20.r),
//             child: Stack(
//               children: [
//                 Container(
//                   height: 10.h,
//                   width: double.infinity,
//                   color: Colors.white,
//                 ),
//                 FractionallySizedBox(
//                   widthFactor: percent / 100,
//                   child: Container(
//                     height: 10.h,
//                     decoration: BoxDecoration(
//                       color: color,
//                       borderRadius: BorderRadius.circular(20.r),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
