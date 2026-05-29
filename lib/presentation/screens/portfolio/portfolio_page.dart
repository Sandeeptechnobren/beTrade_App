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
  // Explicit controller (was DefaultTabController) so we can re-fetch
  // the Closed list when the user switches to that tab — gives the
  // Closed Positions tab the same first-load spinner as Open and keeps
  // it fresh after a sell.
  late final TabController _tabController;

  // Figma tokens (Portfolio screen)
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

  /// Wallet balance visibility toggle — tapped via the eye icon next to
  /// "Available to trade". Session-only (resets on app restart).
  bool _balanceHidden = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Re-fetch the Closed list each time the user lands on that tab so
    // the spinner shows (matching Open's first-load behaviour) and the
    // list reflects any position just closed via a sell.
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      if (_tabController.index == 1 && mounted) {
        context.read<PositionsProvider>().fetchSettledPositions();
      }
    });
    // Fetch real balance + transactions + open positions on first
    // paint. WalletProvider replaces the hardcoded "0.00" balance card,
    // PositionsProvider populates the Open Positions list below.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<WalletProvider>().fetchBalance();
      context.read<WalletProvider>().fetchTransactions();
      // P0-C: fire both list fetches in parallel so the Closed
      // Positions tab is ready when the user switches to it.
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
    return Scaffold(
      appBar: GlobalAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 0),
              child: _walletCard(),
            ),
            SizedBox(height: 20.h),
            _tabBar(),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: TabBarView(
                  controller: _tabController,
                  children: [_openPositions(), _closedPositions()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Wallet card ──────────────────────────────────────────────────

  /// Dark-purple Figma wallet card — `Frame 1000003916` (#2E1065 bg,
  /// 20.r radius, 16 padding). Header row + balance + 2 pill buttons.
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
              // Left: "Available to trade" + balance
              Expanded(child: _walletLabelAndBalance()),
              // Right: ··· menu chip
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
        // When hidden, swap the number for fixed-width bullets so the
        // card doesn't reflow as the real balance changes.
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
                // Eye / Eye-slash toggle. Hit target is widened with
                // Padding so the tap lands comfortably on phone.
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

  // ─── Tabs ─────────────────────────────────────────────────────────

  /// Figma "Frame 1000005059" — labels 16/600 with a 47×6 rounded
  /// rectangle indicator (#3D006D) sitting below the active label.
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

  // ─── Open positions ───────────────────────────────────────────────

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
            padding: EdgeInsets.symmetric(vertical: 16.h),
            itemCount: provider.openPositions.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (_, i) => _positionCard(provider.openPositions[i]),
          ),
        );
      },
    );
  }

  /// Position card — Figma `Frame 1171276423`.
  ///   - Outer:   white bg, 1px #E4E4E7, 12 radius, 16 padding, gap 8
  ///   - Title:   market question 16/400/#09090B
  ///   - Inner:   #F4F4F5 panel, 6 radius, 12 padding, gap 4
  ///   - 4 rows:  Entry Price, Prediction, Profit Earned, Shares
  ///              (label 14/400 #71717A, value 14/500 #71717A; profit
  ///              flips to #16A34A green / #DC2626 red by sign)
  ///   - Footer:  "Close position" outlined pill (white bg, 1px border,
  ///              9999 radius, 44 height, 16/500 #18181B text)
  Widget _positionCard(PositionModel p) {
    final isProfit = p.unrealisedPnlGhs >= 0;
    final profitColor = isProfit ? _profitGreen : _profitRed;

    // Shares: integer if whole, else 2 decimals to match Figma's "119
    // shares" while still respecting fractional positions ("3.76 shares").
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
            // Close position — opens the sell sheet (P0-D). On a
            // completed sell, refresh + show a confirmation snackbar.
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  if (p.marketUuid == null) return;
                  final messenger = ScaffoldMessenger.of(context);
                  final sold = await SellPositionSheet.open(context, p);
                  if (sold == true) {
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Position closed.')),
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

  /// P0-C — Closed Positions tab. Reads `provider.settledPositions`
  /// which is populated by `GET /api/positions?status=settled`. Each
  /// row carries `realized_pnl_ghs` (positive for winners, negative
  /// for losers) and `payout_ghs` (non-null only when the user won
  /// and the SettleMarketJob wrote a Payout row).
  Widget _closedPositions() {
    return Consumer<PositionsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoadingSettled && provider.settledPositions.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.settledPositions.isEmpty) {
          return Center(
            child: Text(
              'No Closed Positions',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade600,
              ),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: _refreshAll,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            itemCount: provider.settledPositions.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (_, i) =>
                _closedPositionCard(provider.settledPositions[i]),
          ),
        );
      },
    );
  }

  /// Card for one closed position. Mirrors the open-position layout
  /// but swaps the "Profit Earned" row for "Realized P&L" + a payout
  /// row, and replaces the "Close position" button with a dimmed
  /// status pill (Won / Lost).
  Widget _closedPositionCard(PositionModel p) {
    // Three closed states:
    //   - Sold  → exited by selling (settled_at null). Neutral grey.
    //   - Won   → market resolved in the user's favour.
    //   - Lost  → market resolved against the user.
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

/// Figma tab indicator — a 47×6 rounded rectangle (radius 1000) sitting
/// just below the active label. Matches "Rectangle 248" in
/// `Frame 1000004991`.
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
