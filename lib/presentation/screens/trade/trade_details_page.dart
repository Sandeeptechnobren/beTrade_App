import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_style.dart';
import '../../../data/model/trade_detail_model.dart';
import '../../../data/provider/default_amount_provider.dart';
import '../../../data/provider/trade_detail_provider.dart';
import '../../widget/common_bottom_sheet.dart';
import '../../widget/customSnackBar.dart';
import '../profile/default_settings_page.dart';
import 'trade_page.dart';

/// Full-screen "Details" view for a market.
///
/// Pushed from `TradePage` when the user taps the title card. Reads
/// existing data from `TradeDetailProvider` (already populated by
/// `TradePage.initState`) so we don't double-fetch in the common path.
///
/// Two tabs:
///   * Info — Market Activity rows + Resolution Source
///   * Chart — chance % + price chart over time
///
/// Many fields fall back to hardcoded values when the backend does not
/// return them. See `tasks/todo.md` → "Details screen — backend gaps"
/// for the complete list.
class TradeDetailsPage extends StatefulWidget {
  final String tradeUuid;

  /// Provided by `CommonBottomSheet` so the inner scrollview drives
  /// drag-to-resize on the sheet. Match the same contract used by
  /// `TradePage`.
  final ScrollController scrollController;

  const TradeDetailsPage({
    super.key,
    required this.tradeUuid,
    required this.scrollController,
  });

  @override
  State<TradeDetailsPage> createState() => _TradeDetailsPageState();
}

class _TradeDetailsPageState extends State<TradeDetailsPage> {
  bool _isInfoTab = true;
  String _selectedRange = '1D';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TradeDetailProvider>();
    final detail = provider.detail;

    return Scaffold(
      backgroundColor: AppColors.cardBackgroundDynamic(context),
      bottomNavigationBar: detail == null ? null : _buildBuyButtons(),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const Divider(height: 1),
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : detail == null
                      ? const Center(child: Text("No data found"))
                      : _isInfoTab
                          ? _buildInfoTab(detail)
                          : _buildChartTab(detail),
            ),
          ],
        ),
      ),
    );
  }

  /// Bottom Buy Yes / Buy No row. Tapping either closes this details
  /// sheet and reopens the New Trade modal with the chosen outcome
  /// pre-selected, so the user lands on the amount-entry step with
  /// the correct side already toggled.
  Widget _buildBuyButtons() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 55.h,
                child: ElevatedButton(
                  onPressed: () => _openNewTrade('yes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff1B5E20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                  ),
                  child: Text(
                    "Buy Yes",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15.sp,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: SizedBox(
                height: 55.h,
                child: ElevatedButton(
                  onPressed: () => _openNewTrade('no'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                  ),
                  child: Text(
                    "Buy No",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15.sp,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Open the New Trade modal pre-filled with the user's default amount so
  /// they land directly on the quote view (shares, price, max payout,
  /// potential profit) instead of an empty amount input. Mirrors the home-
  /// screen swipe path. If the default amount isn't ready, gate the same
  /// way `_ensureReadyToTrade()` does on HomeScreen:
  ///   - still loading        → purple "Loading your settings..." snackbar
  ///   - loaded but unset/0   → red "Please set default" + DefaultSettings
  ///
  /// TODO: extract this gate to a shared helper to avoid duplicating
  /// HomeScreen._ensureReadyToTrade().
  void _openNewTrade(String outcome) {
    final provider = context.read<DefaultAmountProvider>();

    if (!provider.hasLoaded || provider.defaultAmount == null) {
      CustomSnackBar.showLoader(
        context,
        message: "Loading your settings, please wait...",
        duration: const Duration(seconds: 2),
      );
      return;
    }

    if (provider.defaultAmount! <= 0) {
      Navigator.pop(context);
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
      return;
    }

    Navigator.pop(context);
    CommonBottomSheet.open(
      context: context,
      builder: (controller) => TradePage(
        tradeUuid: widget.tradeUuid,
        scrollController: controller,
        initialOutcome: outcome,
        useDefaultAmount: true,
      ),
    );
  }

  /// Custom in-sheet header to mirror `TradePage`'s pattern (no
  /// `AppBar` inside a bottom sheet — the `Scaffold/AppBar` chrome
  /// looks wrong in a draggable container).
  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(8.w, 4.h, 16.w, 8.h),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              size: 18.sp,
              color: AppColors.textPrimaryDynamic(context),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Text(
            "Details",
            style: AppTextStyle.heading.copyWith(
              color: AppColors.textPrimaryDynamic(context),
            ),
          ),
          const Spacer(),
          _buildTabSwitcher(),
        ],
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppColors.inputFieldBgDynamic(context),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _tabButton('Info', _isInfoTab),
          _tabButton('Chart', !_isInfoTab),
        ],
      ),
    );
  }

  Widget _tabButton(String label, bool selected) {
    return GestureDetector(
      onTap: () => setState(() => _isInfoTab = (label == 'Info')),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.cardBackgroundDynamic(context)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: AppColors.textPrimaryDynamic(context),
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13.sp,
          ),
        ),
      ),
    );
  }

  // ───────────────── Info tab ─────────────────

  Widget _buildInfoTab(TradeDetailModel detail) {
    return SingleChildScrollView(
      controller: widget.scrollController,
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _titleCard(detail),
          SizedBox(height: 24.h),
          Text(
            "Market Activity",
            style: AppTextStyle.heading.copyWith(
              fontSize: 16.sp,
              color: AppColors.textPrimaryDynamic(context),
            ),
          ),
          SizedBox(height: 12.h),
          _activityCard(detail),
          SizedBox(height: 24.h),
          Text(
            "Resolution Source",
            style: AppTextStyle.heading.copyWith(
              fontSize: 16.sp,
              color: AppColors.textPrimaryDynamic(context),
            ),
          ),
          SizedBox(height: 12.h),
          _resolutionCard(detail),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _titleCard(TradeDetailModel detail) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        image: const DecorationImage(
          image: AssetImage("assets/images/splash.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Market • ${detail.categoryName}",
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            detail.title.isNotEmpty ? detail.title : detail.description,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _activityCard(TradeDetailModel detail) {
    // Hardcoded fallbacks — see tasks/todo.md
    final price = detail.currentPricePerShare > 0
        ? "${detail.currentPricePerShare.toStringAsFixed(2)} GHS per share"
        : "12.40 GHS per share";
    final status = detail.marketStatus ?? "Open";
    final volume = detail.totalVolumeGhs != null
        ? "${_formatThousands(detail.totalVolumeGhs!)} GHS"
        : "410,250 GHS";
    final liquidity = detail.liquidityGhs != null
        ? "${_formatThousands(detail.liquidityGhs!)} GHS"
        : "92,000 GHS";
    final closes = detail.closesAt ?? "31/12/2026 • 11:59PM ET";

    final isOpen = status.toLowerCase() == 'open';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.inputFieldBgDynamic(context),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        children: [
          _activityRow("Current Price", price),
          _divider(),
          _activityRow(
            "Market Status",
            _capitalize(status),
            valueColor: isOpen ? Colors.green.shade700 : Colors.grey.shade700,
          ),
          _divider(),
          _activityRow("Total Volume", volume),
          _divider(),
          _activityRow("Liquidity", liquidity),
          _divider(),
          _activityRow("Closes On", closes),
        ],
      ),
    );
  }

  Widget _activityRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.textPrimaryDynamic(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        height: 1,
        color: Colors.grey.shade200,
      );

  Widget _resolutionCard(TradeDetailModel detail) {
    // Hardcoded fallback per user request — see tasks/todo.md
    const fallback =
        "The final market outcome will be determined using verified public information from the following sources:\n"
        "• Official company announcements\n"
        "• Regulatory filings\n"
        "• Major financial news publications\n"
        "• Platform-approved data providers\n"
        "If multiple sources are available, the platform will prioritize official company disclosures and regulatory filings.";
    final text = detail.resolutionSource?.isNotEmpty == true
        ? detail.resolutionSource!
        : fallback;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.inputFieldBgDynamic(context),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13.sp,
          color: AppColors.textPrimaryDynamic(context),
          height: 1.55,
        ),
      ),
    );
  }

  // ───────────────── Chart tab ─────────────────

  Widget _buildChartTab(TradeDetailModel detail) {
    // Chance % derived from current price (LMSR price = implied probability)
    final chance = (detail.currentPricePerShare * 100).clamp(0, 100);
    final chancePct = chance.toStringAsFixed(0);

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Bumped from 26sp → 32sp to match the Figma's prominent
              // "X% Chance" heading on the Chart tab. w800 mirrors the
              // weight in the design.
              Text(
                "$chancePct% Chance",
                style: AppTextStyle.heading.copyWith(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimaryDynamic(context),
                ),
              ),
              // Hardcoded 24h delta badge — needs backend chart endpoint
              // (`/trade/{uuid}/chart`) wired to compute the real delta.
              // See tasks/todo.md.
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  children: [
                    Text(
                      "20%",
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.sp,
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: Colors.red.shade700,
                      size: 18.sp,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: ['1D', '1W', '1M', '1Y', 'MAX'].map(_rangeChip).toList(),
          ),
          SizedBox(height: 24.h),
          Expanded(child: _chart()),
        ],
      ),
    );
  }

  Widget _rangeChip(String range) {
    final selected = _selectedRange == range;
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: GestureDetector(
        onTap: () => setState(() => _selectedRange = range),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 7.h),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.cardBackgroundDynamic(context)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: selected
                  ? Colors.grey.shade300
                  : Colors.transparent,
            ),
          ),
          child: Text(
            range,
            style: TextStyle(
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: AppColors.textPrimaryDynamic(context),
              fontSize: 13.sp,
            ),
          ),
        ),
      ),
    );
  }

  /// Placeholder chart with hardcoded sample data shaped like the
  /// design mock. Real data should come from `/trade/{uuid}/chart` —
  /// tracked in tasks/todo.md.
  Widget _chart() {
    final spots = <FlSpot>[
      const FlSpot(0, 60),
      const FlSpot(1, 64),
      const FlSpot(2, 50),
      const FlSpot(3, 55),
      const FlSpot(4, 38),
      const FlSpot(5, 50),
      const FlSpot(6, 60),
      const FlSpot(7, 52),
      const FlSpot(8, 67),
      const FlSpot(9, 50),
      const FlSpot(10, 55),
      const FlSpot(11, 60),
      const FlSpot(12, 58),
      const FlSpot(13, 40),
    ];

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: 13,
        minY: 0,
        maxY: 100,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 10,
          verticalInterval: 1,
          getDrawingHorizontalLine: (_) => FlLine(
            color: Colors.grey.shade200,
            strokeWidth: 1,
            dashArray: const [4, 4],
          ),
          getDrawingVerticalLine: (_) => FlLine(
            color: Colors.grey.shade200,
            strokeWidth: 1,
            dashArray: const [4, 4],
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 38,
              interval: 10,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: EdgeInsets.only(left: 4.w),
                  child: Text(
                    "${value.toInt()}%",
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false,
            color: AppColors.primary,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withValues(alpha: 0.20),
                  AppColors.primary.withValues(alpha: 0.02),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────── helpers ─────────────────

  String _formatThousands(double value) {
    final str = value.toStringAsFixed(0);
    final buf = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write(',');
      buf.write(str[i]);
    }
    return buf.toString();
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1).toLowerCase()}';
}
