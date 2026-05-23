import 'package:betrade/data/model/position_model.dart';
import 'package:betrade/data/provider/positions_provider.dart';
import 'package:betrade/data/provider/wallet_provider.dart';
import 'package:betrade/presentation/screens/portfolio/position_detail_page.dart';
import 'package:betrade/presentation/screens/portfolio/wallet_history.dart';
import 'package:betrade/presentation/screens/portfolio/withdraw/withdrawal.dart' hide DepositPage;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:betrade/presentation/widget/icon_container.dart';
import 'package:betrade/presentation/widget/rounded_tab_indicator.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../widget/Common_header_withlogo.dart';
import '../../widget/common_bottom_sheet.dart';
import 'deposit/newDeposit.dart';

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  @override
  void initState() {
    super.initState();
    // Fetch real balance + transactions + open positions on first
    // paint. WalletProvider replaces the hardcoded "0.00" balance card,
    // PositionsProvider populates the Open Positions list below.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<WalletProvider>().fetchBalance();
      context.read<WalletProvider>().fetchTransactions();
      context.read<PositionsProvider>().fetchOpenPositions();
    });
  }

  /// Pull-to-refresh handler — re-fetches both wallet + positions.
  Future<void> _refreshAll() async {
    final wallet = context.read<WalletProvider>();
    final positions = context.read<PositionsProvider>();
    await Future.wait([
      wallet.fetchBalance(),
      positions.fetchOpenPositions(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: GlobalAppBar(),
        body: SafeArea(
          child: Column(
            children: [
              RefreshIndicator(
                onRefresh: _refreshAll,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20.h),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            image: const DecorationImage(
                              image: AssetImage("assets/images/splash.png"),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(22.r),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "Available to trade",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                          fontSize: 16.sp,
                                        ),
                                      ),
                                      SizedBox(width: 5.w),
                                      const Icon(
                                        Iconsax.eye,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                  Material(
                                    color: AppColors.iconContainer1,
                                    borderRadius: BorderRadius.circular(50.r),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(50.r),
                                      onTap: () {
                                        CommonBottomSheet.open(
                                          context: context,
                                          builder: (controller) => WalletHistoryPage(),
                                        );
                                        // Navigator.push(
                                        //   context,
                                        //   MaterialPageRoute(
                                        //     builder: (_) => const WalletHistoryPage(),
                                        //   ),
                                        // );
                                      },
                                      child: SizedBox(
                                        height: 40.w,
                                        width: 40.w,
                                        child: Center(
                                          child: Icon(
                                            Icons.more_horiz,
                                            color: Colors.white,
                                            size: 22.sp,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(height:0.h),
                              Consumer<WalletProvider>(
                                builder: (context, wallet, _) {
                                  final display = wallet.isLoadingBalance &&
                                          wallet.balance == 0
                                      ? '...'
                                      : wallet.balance.toStringAsFixed(2);
                                  return Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        display,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 30.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        wallet.currency,
                                        style: TextStyle(
                                          fontFamily: "SFProRounded",
                                          fontSize: 14.sp,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              SizedBox(height: 20.h),
                              Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(30.r),
                                      onTap: () {
                                        CommonBottomSheet.open(
                                          context: context,
                                          builder: (controller) => DepositPage(
                                            scrollController: controller,
                                          ),
                                        );
                                      },
                                      child: _gradientButton("Deposit"),
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(30.r),
                                      onTap: () {
                                        CommonBottomSheet.open(
                                          context: context,
                                          builder: (controller) => WithdrawPage(
                                            scrollController: controller,
                                          ),
                                        );
                                      },
                                      child: _outlineButton("Withdraw"),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20.h),
                        TabBar(
                          labelColor: Colors.black,
                          unselectedLabelColor: Colors.grey,
                          indicator: RoundedTabIndicator(
                            color: AppColors.primary,
                            radius: 10,
                            height: 3,
                          ),
                          tabs: const [
                            Tab(text: "Open Positions"),
                            Tab(text: "Closed Positions"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: TabBarView(
                    children: [_openPositions(), _closedPositions()],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _openPositions() {
    return Consumer<PositionsProvider>(
      builder: (context, provider, _) {
        // First load — show a spinner so users don't see the empty
        // state flash before data arrives.
        if (provider.isLoadingOpen && provider.openPositions.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.openError != null && provider.openPositions.isEmpty) {
          return _positionsErrorState(provider);
        }
        if (provider.openPositions.isEmpty) {
          return _emptyOpenPositions();
        }
        return RefreshIndicator(
          onRefresh: _refreshAll,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            itemCount: provider.openPositions.length,
            separatorBuilder: (_, __) => SizedBox(height: 10.h),
            itemBuilder: (_, i) => _positionCard(provider.openPositions[i]),
          ),
        );
      },
    );
  }

  /// Single open position card — tap navigates to PositionDetailPage.
  Widget _positionCard(PositionModel p) {
    final isProfit = p.unrealisedPnlGhs >= 0;
    final accent = p.isYes ? const Color(0xff1B5E20) : Colors.red;
    final pnlColor = isProfit ? const Color(0xff1B5E20) : Colors.red;

    return InkWell(
      borderRadius: BorderRadius.circular(14.r),
      onTap: () {
        if (p.marketUuid == null) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PositionDetailPage(
              marketUuid: p.marketUuid!,
              marketTitleHint: p.marketDescription,
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.inputFieldBgDynamic(context),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row: market description (truncated)
            Text(
              (p.marketDescription ?? '').isEmpty
                  ? 'Market'
                  : p.marketDescription!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            // Side chip + shares
            Row(
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    p.isYes ? 'BUY YES' : 'BUY NO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  '${p.shares.toStringAsFixed(2)} shares',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            // Avg / current price subtitle
            Text(
              'Avg ${p.avgCostGhs.toStringAsFixed(4)} · '
              'Now ${p.currentPrice.toStringAsFixed(4)}',
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 8.h),
            // Value + P&L row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Value ${p.marketValueGhs.toStringAsFixed(2)} GHS',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${isProfit ? '+' : ''}'
                  '${p.unrealisedPnlGhs.toStringAsFixed(2)} GHS '
                  '(${isProfit ? '+' : ''}'
                  '${p.unrealisedPnlPct.toStringAsFixed(1)}%)',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: pnlColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Empty state — same look as the previous placeholder but driven
  /// by real data (only shown when /api/positions returns []).
  Widget _emptyOpenPositions() {
    return RefreshIndicator(
      onRefresh: _refreshAll,
      child: ListView(
        children: [
          SizedBox(height: 40.h),
          Image.asset("assets/images/no_open_position.png"),
          SizedBox(height: 12.h),
          Center(
            child: Text(
              "No Open Positions",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            "When you trade on a market, your\nactive positions will appear here.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12.sp),
          ),
        ],
      ),
    );
  }

  Widget _positionsErrorState(PositionsProvider provider) {
    return RefreshIndicator(
      onRefresh: _refreshAll,
      child: ListView(
        children: [
          SizedBox(height: 60.h),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  Text(
                    provider.openError ?? 'Could not load positions.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13.sp),
                  ),
                  SizedBox(height: 12.h),
                  TextButton(
                    onPressed: () => provider.fetchOpenPositions(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _closedPositions() {
    return Center(
      child: Text("No Closed Positions", style: TextStyle(fontSize: 14.sp)),
    );
  }

  Widget _gradientButton(String text) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.r),
        color: AppColors.primary,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          fontFamily: 'SFProRounded',
        ),
      ),
    );
  }

  Widget _outlineButton(String text) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.r),
        color: Colors.white,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.black,
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          fontFamily: 'SFProRounded',
        ),
      ),
    );
  }
}
