import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';
import '../../data/model/buy_response.dart';
import '../../data/model/quote_model.dart';
import '../../data/services/trade_buy_service.dart';
import '../../data/services/trade_quote_service.dart';

/// Confirm-and-buy bottom sheet for the trade detail screen.
///
/// Lifecycle:
///   1. Opens → immediately calls [TradeQuoteService.quote] to show
///      live LMSR pricing for the entered (outcome, costGhs).
///   2. User taps Confirm → calls [TradeBuyService.buy] with a fresh
///      UUID v4 idempotency key generated client-side.
///   3. On success → returns true via Navigator.pop so the parent can
///      refresh the trade detail + wallet balance.
///   4. On typed backend error → shows the message inline and lets the
///      user retry (or close and adjust the amount).
///
/// Returns:
///   - `true`  → buy succeeded; parent should refresh.
///   - `false` / `null` → user cancelled or buy failed.
class BuyBottomSheet extends StatefulWidget {
  final String marketUuid;
  final String outcomeSlug;
  final double costGhs;
  final String? marketTitle;

  const BuyBottomSheet({
    super.key,
    required this.marketUuid,
    required this.outcomeSlug,
    required this.costGhs,
    this.marketTitle,
  });

  @override
  State<BuyBottomSheet> createState() => _BuyBottomSheetState();
}

class _BuyBottomSheetState extends State<BuyBottomSheet> {
  QuoteModel? _quote;
  bool _isLoadingQuote = true;
  String? _quoteError;

  bool _isPlacingBuy = false;
  String? _buyError;

  @override
  void initState() {
    super.initState();
    _fetchQuote();
  }

  Future<void> _fetchQuote() async {
    setState(() {
      _isLoadingQuote = true;
      _quoteError = null;
    });

    final quote = await TradeQuoteService.quote(
      marketUuid: widget.marketUuid,
      outcomeSlug: widget.outcomeSlug,
      costGhs: widget.costGhs,
    );

    if (!mounted) return;
    setState(() {
      _quote = quote;
      _isLoadingQuote = false;
      _quoteError = quote == null ? 'Could not fetch quote.' : null;
    });
  }

  Future<void> _placeBuy() async {
    setState(() {
      _isPlacingBuy = true;
      _buyError = null;
    });

    final result = await TradeBuyService.buy(
      marketUuid: widget.marketUuid,
      outcomeSlug: widget.outcomeSlug,
      costGhs: widget.costGhs,
      idempotencyKey: TradeBuyService.generateIdempotencyKey(),
    );

    if (!mounted) return;

    if (result.success) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      _isPlacingBuy = false;
      _buyError = _formatError(result);
    });
  }

  /// Map typed backend codes to human messages.
  String _formatError(BuyResponse result) {
    final code = result.code;
    final message = result.message;
    switch (code) {
      case 'INSUFFICIENT_FUNDS':
        return 'Not enough wallet balance. Top up to continue.';
      case 'KYC_REQUIRED':
        return 'KYC verification is required before you can trade.';
      case 'MARKET_CLOSED':
        return 'This market is closed or has been resolved.';
      case 'BELOW_MIN_COST':
        return 'Trade amount is below the minimum allowed.';
      case 'ABOVE_MAX_COST':
        return 'Trade amount exceeds the maximum allowed.';
      case 'UNKNOWN_OUTCOME':
        return 'Could not match the selected outcome. Please reopen the market.';
      default:
        return message ?? 'Buy failed. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isYes = widget.outcomeSlug.toLowerCase() == 'yes';
    final accent = isYes ? const Color(0xff1B5E20) : Colors.red;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20.w,
          12.h,
          20.w,
          MediaQuery.of(context).viewInsets.bottom + 20.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),

            // Title row
            Row(
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    isYes ? 'BUY YES' : 'BUY NO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Text(
                  '${widget.costGhs.toStringAsFixed(2)} GHS',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (widget.marketTitle != null) ...[
              SizedBox(height: 8.h),
              Text(
                widget.marketTitle!,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey.shade600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            SizedBox(height: 20.h),

            // Quote panel
            _buildQuotePanel(),

            SizedBox(height: 20.h),

            // Buy error (if any)
            if (_buyError != null) ...[
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Text(
                  _buyError!,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.red.shade700,
                  ),
                ),
              ),

              SizedBox(height: 12.h),
            ],

            // Confirm button
            SizedBox(
              height: 52.h,
              child: ElevatedButton(
                onPressed: (_isLoadingQuote ||
                        _isPlacingBuy ||
                        _quoteError != null ||
                        _quote == null)
                    ? null
                    : _placeBuy,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  disabledBackgroundColor: Colors.grey.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28.r),
                  ),
                ),
                child: _isPlacingBuy
                    ? SizedBox(
                        width: 22.w,
                        height: 22.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Confirm Buy',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            SizedBox(height: 8.h),
            TextButton(
              onPressed:
                  _isPlacingBuy ? null : () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondaryDynamic(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuotePanel() {
    if (_isLoadingQuote) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h),
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_quoteError != null || _quote == null) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h),
        child: Column(
          children: [
            Text(
              _quoteError ?? 'Could not fetch quote.',
              style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade700),
            ),
            SizedBox(height: 8.h),
            TextButton(onPressed: _fetchQuote, child: const Text('Retry')),
          ],
        ),
      );
    }

    final q = _quote!;
    final shares = q.shares;
    final avgPrice = q.avgPricePerShare;
    final maxPayout = q.maxPayoutGhs;
    final profit = q.potentialProfitGhs;
    final newPrice = q.newPriceAfterFill;
    final fee = q.feeGhs;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.inputFieldBgDynamic(context),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row('Shares', shares.toStringAsFixed(2)),
          _row('Avg price / share', '${avgPrice.toStringAsFixed(4)} GHS'),
          _row('New price after fill', newPrice.toStringAsFixed(4)),
          if (fee > 0) _row('Fee', '${fee.toStringAsFixed(2)} GHS'),
          Divider(height: 18.h),
          _row(
            'If you win',
            '${maxPayout.toStringAsFixed(2)} GHS',
            emphasised: true,
          ),
          _row(
            'Potential profit',
            '+${profit.toStringAsFixed(2)} GHS',
            emphasised: true,
            color: const Color(0xff1B5E20),
          ),
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
          Text(
            value,
            style: TextStyle(
              fontSize: emphasised ? 14.sp : 13.sp,
              fontWeight: emphasised ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
