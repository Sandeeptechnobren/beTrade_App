import 'package:betrade/core/utils/app_notify.dart';
import 'package:betrade/data/model/position_model.dart';
import 'package:betrade/data/provider/positions_provider.dart';
import 'package:betrade/data/provider/wallet_provider.dart';
import 'package:betrade/presentation/screens/portfolio/position_detail_page.dart';
import 'package:betrade/presentation/screens/portfolio/wallet_history.dart';
import 'package:betrade/presentation/screens/portfolio/withdraw/withdrawal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../widget/Common_header_withlogo.dart';
import '../../widget/common_bottom_sheet.dart';
import 'deposit/newDeposit.dart';
import 'sell_position_sheet.dart';

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  static const Color _walletBg = Color(0xFF2E1065); // wallet card bg
  static const Color _walletMenuBg = Color(0xFFC178FF); // ··· circle
  static const Color _depositBg = Color(0xFF8E10FC); // Deposit pill
  static const Color _tabActiveColor = Color(0xFF09090B);
  static const Color _tabInactiveColor = Color(0xFF71717A);
  static const Color _tabIndicatorColor = Color(0xFF3D006D);
  static const Color _cardBorder = Color(0xFFE4E4E7);
  static const Color _cardTitleColor = Color(0xFF09090B);
  static const Color _innerPanelBg = Color(0xFFF4F4F5);
  static const Color _labelMuted = Color(0xFF71717A);
  static const Color _profitGreen = Color(0xFF16A34A);
  static const Color _profitRed = Color(0xFFDC2626);
  static const Color _closeBtnText = Color(0xFF18181B);
  bool _balanceHidden = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      if (_tabController.index == 1 && mounted) {
        context.read<PositionsProvider>().fetchSettledPositions();
      }
    });
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<WalletProvider>().fetchBalance();
      context.read<WalletProvider>().fetchTransactions();
      context.read<PositionsProvider>().fetchOpenPositions();
      context.read<PositionsProvider>().fetchSettledPositions();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Pull-to-refresh handler — re-fetches both wallet + positions.
  Future<void> _refreshAll() async {
    final wallet = context.read<WalletProvider>();
    final positions = context.read<PositionsProvider>();
    await Future.wait([
      wallet.fetchBalance(),
      positions.fetchOpenPositions(),
      positions.fetchSettledPositions(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final double tabBarHeight = (48.h).clamp(48.0, 60.0).toDouble();
    return Scaffold(
      appBar: GlobalAppBar(),
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 20.h),
                child: _walletCard(),
              ),
            ),
            SliverOverlapAbsorber(
              handle:
                  NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverPersistentHeader(
                pinned: true,
                delegate: _PinnedTabBarDelegate(
                  height: tabBarHeight,
                  child: ColoredBox(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: _tabBar(),
                  ),
                ),
              ),
            ),
          ],
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: TabBarView(
              controller: _tabController,
              children: [_openPositions(), _closedPositions()],
            ),
          ),
        ),
      ),
    );
  }

  Widget _walletCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _walletBg,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _walletLabelAndBalance()),
              Material(
                color: _walletMenuBg,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    CommonBottomSheet.open(
                      context: context,
                      builder: (controller) => WalletHistoryPage(),
                    );
                  },
                  child: SizedBox(
                    height: 28.w,
                    width: 28.w,
                    child: Icon(
                      Icons.more_horiz,
                      color: Colors.white,
                      size: 18.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(9999),
                  onTap: () {
                    CommonBottomSheet.open(
                      context: context,
                      builder: (controller) => DepositPage(
                        scrollController: controller,
                      ),
                    );
                  },
                  child: _pillButton("Deposit",
                      bg: _depositBg, textColor: Colors.white),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(9999),
                  onTap: () {
                    CommonBottomSheet.open(
                      context: context,
                      builder: (controller) => WithdrawPage(
                        scrollController: controller,
                      ),
                    );
                  },
                  child: _pillButton("Withdraw",
                      bg: Colors.white, textColor: _closeBtnText),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _walletLabelAndBalance() {
    return Consumer<WalletProvider>(
      builder: (context, wallet, _) {
        final loading = wallet.isLoadingBalance && wallet.balance == 0;
        final numeric = loading ? '...' : wallet.balance.toStringAsFixed(2);
        final display = _balanceHidden ? '••••••' : numeric;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "Available to trade",
                  style: TextStyle(
                    fontFamily: 'SFProRounded',
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFFAFAFA),
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(width: 4.w),
                GestureDetector(
                  onTap: () => setState(() => _balanceHidden = !_balanceHidden),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 4.h),
                    child: Icon(
                      _balanceHidden ? Iconsax.eye_slash : Iconsax.eye,
                      color: const Color(0xFFF8FAFC),
                      size: 20.sp,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  display,
                  style: TextStyle(
                    fontFamily: 'SFProRounded',
                    color: Colors.white,
                    fontSize: 40.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.0,
                  ),
                ),
                SizedBox(width: 4.w),
                Padding(
                  padding: EdgeInsets.only(bottom: 4.h),
                  child: Text(
                    wallet.currency,
                    style: TextStyle(
                      fontFamily: 'SFProRounded',
                      fontSize: 16.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _pillButton(String text,
      {required Color bg, required Color textColor}) {
    return Container(
      height: 52.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 15.6.sp,
          fontWeight: FontWeight.w700,
          fontFamily: 'SFProRounded',
        ),
      ),
    );
  }
  Widget _tabBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: TabBar(
        controller: _tabController,
        labelColor: _tabActiveColor,
        unselectedLabelColor: _tabInactiveColor,
        labelStyle: TextStyle(
          fontFamily: 'SFProRounded',
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'SFProRounded',
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        indicatorSize: TabBarIndicatorSize.label,
        labelPadding: EdgeInsets.symmetric(horizontal: 12.w),
        indicator: _FigmaTabIndicator(color: _tabIndicatorColor),
        tabs: const [
          Tab(text: "Open Positions"),
          Tab(text: "Closed Positions"),
        ],
      ),
    );
  }

  Widget _tabScrollView(BuildContext context, Widget bodySliver) {
    return RefreshIndicator(
      onRefresh: _refreshAll,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
          bodySliver,
        ],
      ),
    );
  }

  Widget _openPositions() {
    return Consumer<PositionsProvider>(
      builder: (context, provider, _) {
        final Widget body;
        if (provider.isLoadingOpen && provider.openPositions.isEmpty) {
          body = const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (provider.openError != null &&
            provider.openPositions.isEmpty) {
          body = SliverFillRemaining(
            hasScrollBody: false,
            child: _positionsErrorBody(provider),
          );
        } else if (provider.openPositions.isEmpty) {
          body = SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: _emptyStatePlaceholder(
                title: "No Open Positions",
                subtitle:
                    "When you trade on a market, your active positions will appear here.",
              ),
            ),
          );
        } else {
          body = SliverPadding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            sliver: SliverList.separated(
              itemCount: provider.openPositions.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (_, i) => _positionCard(provider.openPositions[i]),
            ),
          );
        }
        return _tabScrollView(context, body);
      },
    );
  }
  Widget _positionCard(PositionModel p) {
    final isProfit = p.unrealisedPnlGhs >= 0;
    final profitColor = isProfit ? _profitGreen : _profitRed;
    final sharesText = p.shares == p.shares.roundToDouble()
        ? p.shares.toStringAsFixed(0)
        : p.shares.toStringAsFixed(2);

    final profitText =
        '${isProfit ? '+' : ''}${p.unrealisedPnlGhs.toStringAsFixed(2)}GHS';

    final prediction = p.isYes
        ? 'YES'
        : (p.outcomeLabel.isNotEmpty ? p.outcomeLabel.toUpperCase() : 'NO');

    return InkWell(
      borderRadius: BorderRadius.circular(12.r),
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
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _cardBorder, width: 1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title — market question
            Text(
              (p.marketDescription ?? '').isEmpty
                  ? 'Market'
                  : p.marketDescription!,
              style: TextStyle(
                fontFamily: 'SFProRounded',
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: _cardTitleColor,
                height: 1.4,
              ),
            ),
            SizedBox(height: 8.h),
            // Grey inner panel — 4 label/value rows
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: _innerPanelBg,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Column(
                children: [
                  _statRow(
                      'Entry Price', '${p.avgCostGhs.toStringAsFixed(2)}GHS'),
                  SizedBox(height: 4.h),
                  _statRow('Prediction', prediction),
                  SizedBox(height: 4.h),
                  _statRow('Profit Earned', profitText,
                      valueColor: profitColor),
                  SizedBox(height: 4.h),
                  _statRow('Shares', '$sharesText shares'),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  if (p.marketUuid == null) return;
                  final sold = await SellPositionSheet.open(context, p);
                  if (sold == true) {
                    AppNotify.success(
                      'Your position has been closed.',
                      title: 'Position closed',
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: _cardBorder, width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                ),
                child: Text(
                  'Close position',
                  style: TextStyle(
                    fontFamily: 'SFProRounded',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: _closeBtnText,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'SFProRounded',
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: _labelMuted,
            height: 1.4,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'SFProRounded',
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: valueColor ?? _labelMuted,
            height: 1.4,
          ),
        ),
      ],
    );
  }
  Widget _emptyStatePlaceholder({required String title, String? subtitle}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 80.w,
          height: 80.w,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1) Outer light disc (#F4F4F5)
              Container(
                width: 80.w,
                height: 80.w,
                decoration: const BoxDecoration(
                  color: _innerPanelBg,
                  shape: BoxShape.circle,
                ),
              ),
              // 2) Document scroll
              Image.asset(
                "assets/images/subs.png",
                width: 48.w,
                height: 60.w,
                fit: BoxFit.contain,
              ),
              // 3) Grey cross badge (#D4D4D8 disc + white X)
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
        SizedBox(height: 12.h),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'SFProRounded',
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            height: 1.4,
            color: _cardTitleColor, // #09090B
          ),
        ),
        if (subtitle != null) ...[
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 28.w),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'SFProRounded',
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                height: 1.4,
                color: _labelMuted, // #71717A
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _positionsErrorBody(PositionsProvider provider) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
    );
  }
  Widget _closedPositions() {
    return Consumer<PositionsProvider>(
      builder: (context, provider, _) {
        final Widget body;
        if (provider.isLoadingSettled && provider.settledPositions.isEmpty) {
          body = const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (provider.settledPositions.isEmpty) {
          body = SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: _emptyStatePlaceholder(
                title: 'No Closed Positions',
                subtitle:
                    "When you trade on a market, your close positions will appear here.",
              ),
            ),
          );
        } else {
          body = SliverPadding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            sliver: SliverList.separated(
              itemCount: provider.settledPositions.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (_, i) =>
                  _closedPositionCard(provider.settledPositions[i]),
            ),
          );
        }
        return _tabScrollView(context, body);
      },
    );
  }

  Widget _closedPositionCard(PositionModel p) {
    final bool isSettled = p.settledAt != null;
    final String statusLabel;
    final Color statusColor;
    if (!isSettled) {
      statusLabel = 'Sold';
      statusColor = _labelMuted; // neutral — neither win nor loss
    } else if (p.outcomeIsWinner == true) {
      statusLabel = 'Won';
      statusColor = _profitGreen;
    } else {
      statusLabel = 'Lost';
      statusColor = _profitRed;
    }
    final pnlColor = p.realizedPnlGhs >= 0 ? _profitGreen : _profitRed;
    final pnlSign = p.realizedPnlGhs >= 0 ? '+' : '';

    final sharesText = p.shares == p.shares.roundToDouble()
        ? p.shares.toStringAsFixed(0)
        : p.shares.toStringAsFixed(2);

    final prediction = p.isYes
        ? 'YES'
        : (p.outcomeLabel.isNotEmpty ? p.outcomeLabel.toUpperCase() : 'NO');

    final settledOn = p.settledAt != null
        ? '${p.settledAt!.year}-${p.settledAt!.month.toString().padLeft(2, '0')}-${p.settledAt!.day.toString().padLeft(2, '0')}'
        : '—';

    return InkWell(
      borderRadius: BorderRadius.circular(12.r),
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
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _cardBorder, width: 1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              (p.marketDescription ?? '').isEmpty
                  ? 'Market'
                  : p.marketDescription!,
              style: TextStyle(
                fontFamily: 'SFProRounded',
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: _cardTitleColor,
                height: 1.4,
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: _innerPanelBg,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Column(
                children: [
                  _statRow('Your Prediction', prediction),
                  SizedBox(height: 4.h),
                  _statRow(
                    'Realized P&L',
                    '$pnlSign${p.realizedPnlGhs.toStringAsFixed(2)} GHS',
                    valueColor: pnlColor,
                  ),
                  SizedBox(height: 4.h),
                  _statRow(
                    'Payout',
                    p.payoutGhs == null
                        ? '—'
                        : '${p.payoutGhs!.toStringAsFixed(2)} GHS',
                  ),
                  SizedBox(height: 4.h),
                  _statRow('Shares Held', '$sharesText shares'),
                  SizedBox(height: 4.h),
                  _statRow('Settled', settledOn),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(9999.r),
              ),
              child: Center(
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontFamily: 'SFProRounded',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PinnedTabBarDelegate extends SliverPersistentHeaderDelegate {
  const _PinnedTabBarDelegate({required this.child, required this.height});

  final Widget child;
  final double height;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_PinnedTabBarDelegate oldDelegate) =>
      oldDelegate.height != height || oldDelegate.child != child;
}

class _FigmaTabIndicator extends Decoration {
  final Color color;

  const _FigmaTabIndicator({required this.color});

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) =>
      _FigmaTabIndicatorPainter(color);
}

class _FigmaTabIndicatorPainter extends BoxPainter {
  _FigmaTabIndicatorPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    const indicatorWidth = 47.0;
    const indicatorHeight = 6.0;
    final size = cfg.size!;
    final rect = Rect.fromLTWH(
      offset.dx + (size.width - indicatorWidth) / 2,
      offset.dy + size.height - indicatorHeight,
      indicatorWidth,
      indicatorHeight,
    );
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(1000));
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rrect, paint);
  }
}
