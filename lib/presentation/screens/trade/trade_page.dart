import 'dart:async';

import 'package:betrade/core/theme/app_colors.dart';
import 'package:betrade/core/theme/app_text_style.dart';
import 'package:betrade/presentation/screens/profile/default_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../data/model/quote_model.dart';
import '../../../core/utils/money.dart';
import '../../../data/provider/default_amount_provider.dart';
import '../../../data/provider/trade_detail_provider.dart';
import '../../../data/services/trade_quote_service.dart';
import '../../widget/buy_bottom_sheet.dart';
import '../../widget/common_bottom_sheet.dart';
import '../../widget/common_header.dart';
import '../../widget/customSnackBar.dart';
import 'trade_details_page.dart';

class TradePage extends StatefulWidget {
  final String tradeUuid;
  final ScrollController scrollController;
  final String initialOutcome;
  final bool useDefaultAmount;

  const TradePage({
    super.key,
    required this.scrollController,
    required this.tradeUuid,
    this.initialOutcome = 'yes',
    this.useDefaultAmount = false,
  });

  @override
  State<TradePage> createState() => _TradePageState();
}

class _TradePageState extends State<TradePage> {
  late bool isYesSelected;

  TextEditingController amountController = TextEditingController();
  double amount = 0;

  // Server-quoted values (LMSR). Null until the first successful fetch
  // for the current (amount, outcome). When null the UI falls back to
  // a naive local approximation so the user sees something while typing.
  QuoteModel? _serverQuote;
  // Timer? _quoteDebounce;
  int _quoteRequestId = 0;

  // @override
  // void initState() {
  //   super.initState();
  //   isYesSelected = widget.initialOutcome.toLowerCase() != 'no';
  //
  //   // Swipe-path: pre-fill the cost with the user's default amount and
  //   // schedule the first server quote so the figures populate without
  //   // any further tap. Tap-path leaves amount = 0 so the user types it.
  //   if (widget.useDefaultAmount) {
  //     final defaultAmt = context.read<DefaultAmountProvider>().defaultAmount;
  //     amount = defaultAmt!.toDouble();
  //     amountController.text = defaultAmt.toString();
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       if (mounted) _scheduleQuoteFetch();
  //     });
  //   }
  //
  //   // Kick off fetch synchronously so the first build sees
  //   // provider.isLoading == true and shows the spinner instead of
  //   // flashing "No Data Found" for one frame.
  //
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     // context.read<TradeDetailProvider>().fetch();
  //     context.read<TradeDetailProvider>().fetch(widget.tradeUuid);
  //   });
  // }


  @override
  void initState() {
    super.initState();

    isYesSelected = widget.initialOutcome.toLowerCase() != 'no';

    if (widget.useDefaultAmount) {
      final defaultAmt =
          context.read<DefaultAmountProvider>().defaultAmount;

      if (defaultAmt == null || defaultAmt <= 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          CustomSnackBar.showError(
            context,
            message: "Please set a valid default amount first",
            duration: const Duration(seconds: 3),
          );
          Navigator.pop(context);
          CommonBottomSheet.open(
            context: context,
            builder: (controller) =>
                DefaultSettingsPage(scrollController: controller),
          );
          });
        return;
      }

      amount = defaultAmt.toDouble();
      amountController.text = defaultAmt.toString();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _scheduleQuoteFetch();
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TradeDetailProvider>().fetch(widget.tradeUuid);
    });
  }

  void _openDetails() {
    Navigator.pop(context);
    CommonBottomSheet.open(
      context: context,
      builder: (controller) => TradeDetailsPage(
        tradeUuid: widget.tradeUuid,
        scrollController: controller,
      ),
    );
  }

  @override
  void dispose() {
    // _quoteDebounce?.cancel();
    amountController.dispose();
    super.dispose();
  }

  void updateAmount(String value) {
    setState(() {
      amount = double.tryParse(value) ?? 0;
    });
    _scheduleQuoteFetch();
  }

  /// Quick-amount chip tap: REPLACES the current amount with the chip's
  /// value (10 / 20 / 50 / 100 GHS). Previously this incremented (`+=`),
  /// which produced wrong order amounts when the user tapped multiple
  /// chips in sequence — e.g. tap 10 then 20 gave 30 GHS instead of 20.
  void selectQuickAmount(double value) {
    setState(() {
      amount = value;
      amountController.text = amount.toStringAsFixed(0);
    });
    _scheduleQuoteFetch();
  }

  void _selectOutcome(bool yes) {
    if (isYesSelected == yes) return;
    setState(() => isYesSelected = yes);
    _scheduleQuoteFetch();
  }

  /// Debounce 400ms after the latest amount/outcome change before
  /// hitting the server quote endpoint. Backend throttles at 60/min so
  /// we keep the cadence well under that.
  void _scheduleQuoteFetch() {

    if (amount <= 0) {

      setState(() {

        _serverQuote = null;
      });

      return;
    }

    _fetchQuote();
  }

  Future<void> _fetchQuote() async {
    if (!mounted || amount <= 0) return;
    final myRequestId = ++_quoteRequestId;

    final result = await TradeQuoteService.quote(
      marketUuid: widget.tradeUuid,
      outcomeSlug: isYesSelected ? 'yes' : 'no',
      costGhs: amount,
    );

    // Drop stale result if the user has changed inputs since this call
    // started — the latest request will land its own setState.
    if (!mounted || _quoteRequestId != myRequestId) return;

    setState(() => _serverQuote = result);
  }

  // Buy is enabled only for a valid amount (> 0, at most 2 decimal places).
  // Min/max bounds are enforced by the backend (BELOW_MIN_COST / ABOVE_MAX_COST).
  bool get isEnabled => Money.validateAmount(amountController.text) == null;

  /// Show the confirm-and-buy bottom sheet for the current
  /// (outcome, amount). Refreshes trade detail on success so the
  /// price ticker, total volume etc. update with the user's own fill.
  Future<void> _openBuySheet(BuildContext context) async {
    // Capture context-dependent objects BEFORE the await so we don't
    // touch BuildContext across an async gap.
    final messenger = ScaffoldMessenger.of(context);
    final detailProvider = context.read<TradeDetailProvider>();

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (_) => BuyBottomSheet(
        marketUuid: widget.tradeUuid,
        outcomeSlug: isYesSelected ? 'yes' : 'no',
        costGhs: amount,
        marketTitle: detailProvider.detail?.title,
      ),
    );

    if (result == true && mounted) {
      // Refresh detail so the new price + volume reflect this fill.
      detailProvider.fetch(widget.tradeUuid);
      messenger.showSnackBar(
        const SnackBar(content: Text('Order filled.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TradeDetailProvider>();
    if (provider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final detail = provider.detail;
    if (detail == null) {
      return Scaffold(
        body: Center(
          child: Text(
            "No Data Found",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTextStyle.fontFamily,
              color: AppColors.textPrimaryDynamic(context),
            ),
          ),
        ),
      );
    }

    // Prefer server quote (LMSR-aware, includes slippage + fees);
    // fall back to a naive local estimate while the quote is in
    // flight or before the user has typed an amount.
    final localPrice = detail.currentPricePerShare;
    final localShares = localPrice > 0 ? amount / localPrice : 0.0;
    final price = _serverQuote?.avgPricePerShare ?? localPrice;
    final shares = _serverQuote?.shares ?? localShares;
    final payout = _serverQuote?.maxPayoutGhs ?? (localShares * localPrice);
    final profit = _serverQuote?.potentialProfitGhs ?? (payout - amount);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
          20.w,
          0,
          20.w,
          MediaQuery.of(context).viewInsets.bottom + 20.h,
        ),
        // Figma "Button" — 60 tall pill, radius 32, dark green for Yes
        // (#166534) / red (#DC2626) for No, label 15.6/700 white.
        child: SizedBox(
          height: 60.h,
          child: ElevatedButton(
            onPressed: isEnabled ? () => _openBuySheet(context) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isEnabled
                  ? (isYesSelected
                      ? const Color(0xFF166534)
                      : const Color(0xFFDC2626))
                  : AppColors.borderDynamic(context),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32.r),
              ),
            ),
            child: Text(
              isYesSelected ? "Buy Yes" : "Buy No",
              style: TextStyle(
                fontFamily: AppTextStyle.fontFamily,
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15.6.sp,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Figma header — common back chip + title on left, Yes/No
            // segmented pill (#F4F4F5 outer, white selected segment) on
            // the right. Bottom hairline matches the deposit sheet.
            Row(
              children: [
                Expanded(
                  child: CommonHeader(
                    title: "New Trade",
                    showDivider: false,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 20.w),
                  child: _yesNoToggle(),
                ),
              ],
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: AppColors.borderDynamic(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: widget.scrollController,
                padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _marketCard(
                      categoryName: detail.categoryName,
                      description: detail.description,
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'Amount',
                      style: TextStyle(
                        fontFamily: AppTextStyle.fontFamily,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryDynamic(context),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    if (widget.useDefaultAmount) ...[
                      // Read-only amount display — swipe-path uses the
                      // user's default amount; manual input + quick
                      // chips are intentionally hidden.
                      Container(
                        width: double.infinity,
                        height: 62.h,
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 20.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.iconContainerDynamic(context),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '${amount.toStringAsFixed(0)} GHS',
                              style: TextStyle(
                                fontFamily: AppTextStyle.fontFamily,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimaryDynamic(context),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Default amount',
                              style: TextStyle(
                                fontFamily: AppTextStyle.fontFamily,
                                fontSize: 12.sp,
                                color: AppColors.textSecondaryDynamic(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      _figmaAmountInput(),
                      SizedBox(height: 12.h),
                      Row(
                        children: const [10, 20, 50, 100]
                            .map((e) => _figmaAmountChip(e))
                            .toList(growable: false),
                      ),
                    ],
                    SizedBox(height: 24.h),
                    // The quote summary + info banner only make sense once
                    // the user has typed an amount. Rendering them at
                    // amount == 0 used to show "0 GHS / 0.00 / 0.00 GHS /
                    // +0.00 GHS" (price rounds to 0 via toStringAsFixed(0))
                    // — visually identical to a broken quote.
                    if (amount > 0) ...[
                      _quoteSummary(
                        price: price,
                        shares: shares,
                        payout: payout,
                        profit: profit,
                      ),
                      SizedBox(height: 8.h),
                      _infoBanner(shares: shares, price: price),
                    ] else
                      _quotePlaceholder(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Figma atoms ────────────────────────────────────────────────

  /// Yes/No segmented pill — outer #F4F4F5 / 9999 radius / 4 padding,
  /// selected segment white / 99999 radius / 6×16 padding. Matches the
  /// Figma "Frame 2609802" toggle.
  Widget _yesNoToggle() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.iconContainerDynamic(context),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _yesNoSegment('Yes', selected: isYesSelected, onTap: () => _selectOutcome(true)),
          _yesNoSegment('No', selected: !isYesSelected, onTap: () => _selectOutcome(false)),
        ],
      ),
    );
  }

  Widget _yesNoSegment(String label,
      {required bool selected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.cardBackgroundDynamic(context)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(99999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppTextStyle.fontFamily,
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimaryDynamic(context),
          ),
        ),
      ),
    );
  }

  /// Solid dark-purple market summary card (#160128) — Figma `Input`
  /// in step 1 of New Trade. Tappable to open the chart/detail page.
  Widget _marketCard({
    required String categoryName,
    required String description,
  }) {
    return GestureDetector(
      onTap: _openDetails,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          // Brand identity color — intentionally dark in both modes.
          color: const Color(0xFF160128),
          border: Border.all(color: AppColors.borderDynamic(context), width: 1),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // "Market • Category"
            Row(
              children: [
                Text(
                  'Market',
                  style: TextStyle(
                    fontFamily: AppTextStyle.fontFamily,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFFAFAFA),
                  ),
                ),
                SizedBox(width: 6.w),
                Container(
                  width: 4.w,
                  height: 4.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFAFAFA),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 6.w),
                Flexible(
                  child: Text(
                    categoryName,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTextStyle.fontFamily,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFB35DFF),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              description,
              style: TextStyle(
                fontFamily: AppTextStyle.fontFamily,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 62-tall amount input — bg #F4F4F5, radius 16, padding 20/24,
  /// text 16/500/#09090B.
  Widget _figmaAmountInput() {
    return Container(
      height: 62.h,
      decoration: BoxDecoration(
        color: AppColors.iconContainerDynamic(context),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: TextField(
        controller: amountController,
        keyboardType: TextInputType.number,
        onChanged: updateAmount,
        style: TextStyle(
          fontFamily: AppTextStyle.fontFamily,
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimaryDynamic(context),
        ),
        decoration: InputDecoration(
          isCollapsed: true,
          border: InputBorder.none,
          hintText: '0.00',
          hintStyle: TextStyle(
            fontFamily: AppTextStyle.fontFamily,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondaryDynamic(context),
          ),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        ),
      ),
    );
  }

  /// Outlined amount chip — white bg, 1px #E4E4E7, 12 radius, padding
  /// 8/12, text 16/500/#5A1192 (dark purple). Tap replaces the amount.
  Widget _figmaAmountChip(int value) {
    // Brand purple used for the active chip fill + the resting label.
    const purple = Color(0xFF5A1192);
    // A chip is "selected" when the current amount equals its value —
    // tapping 10/20/50/100 (or typing the same number) highlights it.
    final selected = amount == value.toDouble();
    return Expanded(
      child: GestureDetector(
        onTap: () => selectQuickAmount(value.toDouble()),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: EdgeInsets.symmetric(horizontal: 2.w),
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: selected
                ? purple
                : AppColors.cardBackgroundDynamic(context),
            border: Border.all(
              color: selected ? purple : AppColors.borderDynamic(context),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12.r),
          ),
          alignment: Alignment.center,
          child: Text(
            '$value GHS',
            style: TextStyle(
              fontFamily: AppTextStyle.fontFamily,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              // White on the purple fill when selected; brand purple at rest.
              color: selected ? Colors.white : purple,
            ),
          ),
        ),
      ),
    );
  }

  /// Outlined quote summary — labels 16/500/#71717A, values
  /// 16/600/#3F3F46. Profit row flips to #22C55E green for positive,
  /// red for negative. Matches Figma's "Input" stat panel.
  /// Shown in place of the quote summary while the user hasn't entered
  /// an amount yet. Same card chrome as the real summary so the layout
  /// stays stable when they start typing.
  Widget _quotePlaceholder() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundDynamic(context),
        border: Border.all(color: AppColors.borderDynamic(context), width: 1),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Center(
        child: Text(
          'Enter an amount to see your quote',
          style: TextStyle(
            fontFamily: AppTextStyle.fontFamily,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondaryDynamic(context),
          ),
        ),
      ),
    );
  }

  Widget _quoteSummary({
    required double price,
    required double shares,
    required double payout,
    required double profit,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundDynamic(context),
        border: Border.all(color: AppColors.borderDynamic(context), width: 1),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          // LMSR Yes/No prices live in (0, 1) GHS — must show 2 decimals,
          // not 0, or 0.50 GHS renders as "0 GHS" and looks broken.
          _summaryRow('Price per Share', '${price.toStringAsFixed(2)} GHS'),
          SizedBox(height: 16.h),
          _summaryRow(
            'Your ${isYesSelected ? 'Yes' : 'No'} Shares',
            shares.toStringAsFixed(2),
          ),
          SizedBox(height: 16.h),
          _summaryRow('Max Payout', '${payout.toStringAsFixed(2)} GHS'),
          SizedBox(height: 16.h),
          _summaryRow(
            'Potential Profit',
            '${profit >= 0 ? '+' : ''}${profit.toStringAsFixed(2)} GHS',
            valueColor: profit >= 0
                ? const Color(0xFF22C55E)
                : const Color(0xFFDC2626),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTextStyle.fontFamily,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondaryDynamic(context),
            height: 1.4,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: AppTextStyle.fontFamily,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimaryDynamic(context),
          ),
        ),
      ],
    );
  }

  /// Light-purple info banner — #F3E6FF bg, radius 16, padding 12/16,
  /// body text 10/300/#3D006D. Renders the buying-summary blurb under
  /// the quote panel.
  Widget _infoBanner({required double shares, required double price}) {
    final cents = (price * 100).round();
    final text = "You're buying ${shares.toStringAsFixed(2)} shares at "
        "$cents¢ each. This market will close when the event occurs. "
        "If you're right, payout is expected 2 hours later.";
    // Tinted purple banner — invert tones for dark mode so the text
    // stays legible on a darker surface.
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bannerBg =
        isDark ? const Color(0xFF2C1147) : const Color(0xFFF3E6FF);
    final bannerText =
        isDark ? const Color(0xFFD4B5FD) : const Color(0xFF3D006D);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: bannerBg,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: AppTextStyle.fontFamily,
          fontSize: 10.sp,
          fontWeight: FontWeight.w300,
          color: bannerText,
          height: 1.4,
        ),
      ),
    );
  }

  Widget buildRow(String title, String value, {bool isProfit = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(
            value,
            style: TextStyle(
              color: isProfit ? Colors.green : AppColors.textSecondaryDynamic(context),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
