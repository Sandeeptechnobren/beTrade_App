import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/idempotency.dart';
import '../../../data/model/position_model.dart';
import '../../../data/provider/positions_provider.dart';
import '../../../data/provider/wallet_provider.dart';
import '../../../data/services/trade_sell_service.dart';

/// Bottom sheet to close (sell) all or part of an open position.
///
/// Flow:
///   1. Opens defaulted to selling the FULL position.
///   2. Debounced quote-sell shows the net GHS receipt the user gets.
///   3. Confirm → POST /sell → on success refresh wallet + positions
///      and pop with `true` so the caller can show a confirmation.
///
/// The slider lets the user sell a fraction; quote re-fetches on
/// release (debounced) to avoid hammering the 60/min quote-sell limit.
class SellPositionSheet extends StatefulWidget {
  final PositionModel position;

  const SellPositionSheet({super.key, required this.position});

  /// Convenience opener — returns true if a sell completed.
  static Future<bool?> open(BuildContext context, PositionModel position) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SellPositionSheet(position: position),
    );
  }

  @override
  State<SellPositionSheet> createState() => _SellPositionSheetState();
}

class _SellPositionSheetState extends State<SellPositionSheet> {
  late double _sharesToSell;
  SellQuote? _quote;
  bool _loadingQuote = false;
  bool _submitting = false;
  String? _error;
  Timer? _debounce;

  /// One idempotency key per confirmed sell. Reset whenever the share amount
  /// changes (= a new logical order) so a retry after a timeout can't sell
  /// the position twice.
  String? _idempotencyKey;

  double get _maxShares => widget.position.shares;

  @override
  void initState() {
    super.initState();
    // Default to selling the whole position.
    _sharesToSell = _maxShares;
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchQuote());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSliderChanged(double v) {
    _idempotencyKey = null; // amount changed → new logical order
    setState(() => _sharesToSell = v);
  }

  void _onSliderSettled(double v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _fetchQuote);
  }

  Future<void> _fetchQuote() async {
    if (widget.position.marketUuid == null) return;
    if (_sharesToSell <= 0) return;
    setState(() {
      _loadingQuote = true;
      _error = null;
    });
    final q = await TradeSellService.quoteSell(
      marketUuid: widget.position.marketUuid!,
      outcomeSlug: widget.position.outcomeSlug,
      shares: _sharesToSell,
    );
    if (!mounted) return;
    setState(() {
      _quote = q;
      _loadingQuote = false;
      if (q == null) _error = 'Could not fetch a quote. Try again.';
    });
  }

  Future<void> _confirmSell() async {
    if (widget.position.marketUuid == null) return;
    setState(() {
      _submitting = true;
      _error = null;
    });

    _idempotencyKey ??= Idempotency.newKey();
    final result = await TradeSellService.sell(
      marketUuid: widget.position.marketUuid!,
      outcomeSlug: widget.position.outcomeSlug,
      shares: _sharesToSell,
      idempotencyKey: _idempotencyKey,
    );

    if (!mounted) return;

    if (result.success) {
      // Refresh wallet + both position lists so the Portfolio reflects
      // the new balance and the (now smaller / closed) position.
      final wallet = context.read<WalletProvider>();
      final positions = context.read<PositionsProvider>();
      await wallet.fetchBalance();
      await positions.fetchOpenPositions();
      await positions.fetchSettledPositions();
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _submitting = false;
        _error = _friendlyError(result.code, result.message);
      });
    }
  }

  String _friendlyError(String? code, String? message) {
    switch (code) {
      case 'INSUFFICIENT_SHARES':
        return 'You no longer hold that many shares.';
      case 'MARKET_CLOSED':
        return 'This market has closed — you can\'t sell now.';
      case 'BELOW_MIN_SHARES':
        return 'That amount is too small to sell.';
      case 'KYC_REQUIRED':
        return 'Verify your account to trade.';
      default:
        return message ?? 'Could not complete the sell.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.position;
    final isYes = p.isYes;
    final prediction = isYes
        ? 'YES'
        : (p.outcomeLabel.isNotEmpty ? p.outcomeLabel.toUpperCase() : 'NO');

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
        decoration: BoxDecoration(
          color: AppColors.whiteDynamic(context),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            Text(
              'Close Position',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimaryDynamic(context),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              p.marketDescription ?? 'Market',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.textSecondaryDynamic(context),
              ),
            ),
            SizedBox(height: 16.h),

            // Shares-to-sell control
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Shares to sell ($prediction)',
                    style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade700)),
                Text(
                  _sharesToSell.toStringAsFixed(
                      _sharesToSell == _sharesToSell.roundToDouble() ? 0 : 2),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryDynamic(context),
                  ),
                ),
              ],
            ),
            Slider(
              value: _sharesToSell.clamp(0, _maxShares),
              min: 0,
              max: _maxShares,
              activeColor: AppColors.primary,
              onChanged: _submitting ? null : _onSliderChanged,
              onChangeEnd: _submitting ? null : _onSliderSettled,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('0', style: TextStyle(fontSize: 11.sp, color: Colors.grey)),
                TextButton(
                  onPressed: _submitting
                      ? null
                      : () {
                          _idempotencyKey = null;
                          setState(() => _sharesToSell = _maxShares);
                          _fetchQuote();
                        },
                  child: Text('Max (${_maxShares.toStringAsFixed(_maxShares == _maxShares.roundToDouble() ? 0 : 2)})'),
                ),
              ],
            ),
            SizedBox(height: 8.h),

            // Receipt panel
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: AppColors.inputFieldBgDynamic(context),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: _loadingQuote
                  ? Row(
                      children: [
                        SizedBox(
                          width: 16.w,
                          height: 16.w,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.primary),
                        ),
                        SizedBox(width: 10.w),
                        Text('Fetching quote…',
                            style: TextStyle(
                                fontSize: 13.sp, color: Colors.grey.shade700)),
                      ],
                    )
                  : Column(
                      children: [
                        _receiptRow('Gross receipt',
                            '${(_quote?.grossReceiptGhs ?? 0).toStringAsFixed(2)} GHS'),
                        SizedBox(height: 6.h),
                        _receiptRow('Fee',
                            '${(_quote?.feeGhs ?? 0).toStringAsFixed(2)} GHS'),
                        SizedBox(height: 6.h),
                        _receiptRow(
                          'You receive',
                          '${(_quote?.netReceiptGhs ?? 0).toStringAsFixed(2)} GHS',
                          bold: true,
                        ),
                      ],
                    ),
            ),

            if (_error != null) ...[
              SizedBox(height: 10.h),
              Text(_error!,
                  style: TextStyle(fontSize: 12.sp, color: Colors.red.shade600)),
            ],

            SizedBox(height: 18.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_submitting || _loadingQuote || _sharesToSell <= 0)
                    ? null
                    : _confirmSell,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                ),
                child: _submitting
                    ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: const CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        'Confirm Sell',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _receiptRow(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
              fontSize: bold ? 14.sp : 13.sp,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
              color: bold
                  ? AppColors.textPrimaryDynamic(context)
                  : Colors.grey.shade700,
            )),
        Text(value,
            style: TextStyle(
              fontSize: bold ? 14.sp : 13.sp,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: bold
                  ? AppColors.primary
                  : AppColors.textPrimaryDynamic(context),
            )),
      ],
    );
  }
}
