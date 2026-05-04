import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/model/position_model.dart';
import '../../../data/provider/positions_provider.dart';
import '../../widget/common_bottom_sheet.dart';
import '../../widget/common_header.dart';
import '../trade/trade_page.dart';

/// Detail screen for a single position. Shows BOTH outcomes (yes + no)
/// of the market — the user might hold one side or both. A side the
/// user doesn't hold appears with `shares: 0` so they can see context
/// pricing.
///
/// Reachable from:
///   - portfolio_page.dart → tap a row in the Open Positions list
class PositionDetailPage extends StatefulWidget {
  final String marketUuid;
  final String? marketTitleHint; // shown while the API call is in flight

  const PositionDetailPage({
    super.key,
    required this.marketUuid,
    this.marketTitleHint,
  });

  @override
  State<PositionDetailPage> createState() => _PositionDetailPageState();
}

class _PositionDetailPageState extends State<PositionDetailPage> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context
          .read<PositionsProvider>()
          .fetchMarketDetail(widget.marketUuid, forceRefresh: true);
    });
  }

  Future<void> _refresh() async {
    await context
        .read<PositionsProvider>()
        .fetchMarketDetail(widget.marketUuid, forceRefresh: true);
  }

  void _openMarketSheet() {
    CommonBottomSheet.open(
      context: context,
      builder: (controller) => TradePage(
        scrollController: controller,
        tradeUuid: widget.marketUuid,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonHeader(title: 'Position Detail', showDivider: true),
            Expanded(
              child: Consumer<PositionsProvider>(
                builder: (context, provider, _) {
                  final detail = provider.cachedDetail(widget.marketUuid);

                  if (provider.isLoadingDetail && detail == null) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (detail == null) {
                    return _errorState(provider.detailError);
                  }
                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 12.h),
                      children: [
                        _marketHeader(detail),
                        SizedBox(height: 16.h),
                        ...detail.sides.map((side) => _sideCard(side)),
                        SizedBox(height: 24.h),
                        _viewMarketButton(),
                        SizedBox(height: 16.h),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _marketHeader(MarketPositionsModel detail) {
    final title = detail.description.isNotEmpty
        ? detail.description
        : (widget.marketTitleHint ?? 'Market');

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.inputFieldBgDynamic(context),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Market UUID: ${detail.marketUuid}',
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey.shade600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// One outcome card (yes or no). If the user doesn't hold this side,
  /// `shares` is 0 — we still render the row so they see the price
  /// context, but with a muted style.
  Widget _sideCard(PositionModel side) {
    final hasShares = side.shares > 0;
    final accent = side.isYes ? const Color(0xff1B5E20) : Colors.red;
    final pnlColor = side.unrealisedPnlGhs >= 0
        ? const Color(0xff1B5E20)
        : Colors.red;

    return Container(
      margin: EdgeInsets.only(top: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.inputFieldBgDynamic(context),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: hasShares ? accent : Colors.grey.shade300,
          width: hasShares ? 1.5 : 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: outcome label + current price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  side.outcomeLabel.isNotEmpty
                      ? side.outcomeLabel.toUpperCase()
                      : side.outcomeSlug.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                'Now ${side.currentPrice.toStringAsFixed(4)}',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          if (!hasShares) ...[
            Text(
              'You do not hold this side.',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey.shade600,
              ),
            ),
          ] else ...[
            _row('Shares', side.shares.toStringAsFixed(2)),
            _row('Avg cost', '${side.avgCostGhs.toStringAsFixed(4)} GHS'),
            _row('Cost basis',
                '${side.costBasisGhs.toStringAsFixed(2)} GHS'),
            Divider(height: 18.h),
            _row(
              'Current value',
              '${side.marketValueGhs.toStringAsFixed(2)} GHS',
              emphasised: true,
            ),
            _row(
              'Unrealised P&L',
              '${side.unrealisedPnlGhs >= 0 ? '+' : ''}'
                  '${side.unrealisedPnlGhs.toStringAsFixed(2)} GHS '
                  '(${side.unrealisedPnlPct >= 0 ? '+' : ''}'
                  '${side.unrealisedPnlPct.toStringAsFixed(1)}%)',
              emphasised: true,
              color: pnlColor,
            ),
            Divider(height: 18.h),
            _row(
              'Max payout if this side wins',
              '${side.maxPayoutGhs.toStringAsFixed(2)} GHS',
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(String label, String value,
      {bool emphasised = false, Color? color}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey.shade700,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: emphasised ? 14.sp : 13.sp,
                fontWeight: emphasised ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _viewMarketButton() {
    return SizedBox(
      height: 50.h,
      child: ElevatedButton(
        onPressed: _openMarketSheet,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28.r),
          ),
        ),
        child: Text(
          'View Market',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _errorState(String? msg) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              msg ?? 'Could not load this position.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.sp),
            ),
            SizedBox(height: 12.h),
            TextButton(onPressed: _refresh, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
