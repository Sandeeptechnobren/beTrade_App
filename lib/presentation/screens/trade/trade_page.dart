import 'dart:async';

import 'package:betrade/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../data/model/quote_model.dart';
import '../../../data/provider/default_amount_provider.dart';
import '../../../data/provider/trade_detail_provider.dart';
import '../../../data/services/trade_quote_service.dart';
import '../../widget/buy_bottom_sheet.dart';
import '../../widget/common_bottom_sheet.dart';
import '../../widget/common_header.dart';
import 'trade_details_page.dart';

class TradePage extends StatefulWidget {
  final String tradeUuid;
  final ScrollController scrollController;

  /// Pre-selects the YES/NO toggle when this page is opened from a
  /// home-card swipe. Accepts `'yes'` (default) or `'no'`.
  final String initialOutcome;

  /// Swipe-path quick-trade mode: pre-fill the cost from
  /// `DefaultAmountProvider.defaultAmount` and replace the editable
  /// amount field + quick-amount chips with a read-only display so the
  /// user can confirm-and-buy in one tap. Tap-path callers leave this
  /// `false` to keep the manual entry UX.
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
  Timer? _quoteDebounce;
  int _quoteRequestId = 0;

  @override
  void initState() {
    super.initState();
    isYesSelected = widget.initialOutcome.toLowerCase() != 'no';

    // Swipe-path: pre-fill the cost with the user's default amount and
    // schedule the first server quote so the figures populate without
    // any further tap. Tap-path leaves amount = 0 so the user types it.
    if (widget.useDefaultAmount) {
      final defaultAmt = context.read<DefaultAmountProvider>().defaultAmount;
      amount = defaultAmt.toDouble();
      amountController.text = defaultAmt.toString();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _scheduleQuoteFetch();
      });
    }

    // Kick off fetch synchronously so the first build sees
    // provider.isLoading == true and shows the spinner instead of
    // flashing "No Data Found" for one frame.
    context.read<TradeDetailProvider>().fetch(widget.tradeUuid);
  }

  /// Opens the Details page as a bottom sheet stacked on top of this
  /// `TradePage` sheet. Tapping back inside the Details sheet pops it
  /// and returns the user here with their amount intact — same pattern
  /// the rest of the app uses for nested sheets.
  void _openDetails() {
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
    _quoteDebounce?.cancel();
    amountController.dispose();
    super.dispose();
  }

  void updateAmount(String value) {
    setState(() {
      amount = double.tryParse(value) ?? 0;
    });
    _scheduleQuoteFetch();
  }

  void addQuickAmount(double value) {
    setState(() {
      amount += value;
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
    _quoteDebounce?.cancel();
    if (amount <= 0) {
      setState(() => _serverQuote = null);
      return;
    }
    _quoteDebounce = Timer(const Duration(milliseconds: 400), _fetchQuote);
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

  bool get isEnabled => amount > 0;

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
      return const Scaffold(body: Center(child: Text("No Data Found")));
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
          16.w,
          0,
          16.w,
          MediaQuery.of(context).viewInsets.bottom + 16.h,
        ),
        child: SizedBox(
          height: 55.h,
          child: ElevatedButton(
            onPressed: isEnabled ? () => _openBuySheet(context) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isEnabled
                  ? (isYesSelected ? const Color(0xff1B5E20) : Colors.red)
                  : Colors.grey.shade400,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.r),
              ),
            ),
            child: Text(
              isYesSelected ? "Buy Yes" : "Buy No",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15.sp,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal:0.w, vertical:0.h),
              child: Row(
                children: [
                  CommonHeader(title: "New Trade",showDivider: false,),
                  const Spacer(),
                  Container(
                    height: 36.h,
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                        color: AppColors.inputFieldBgDynamic(context),
                      borderRadius: BorderRadius.circular(25.r),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => _selectOutcome(true),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: isYesSelected
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text("Yes"),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _selectOutcome(false),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: !isYesSelected
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text("No"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: _openDetails,
                      child: Container(
                        width: double.infinity,
                        height: 96.h,
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.r),
                          image: DecorationImage(
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
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              detail.description,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text("Amount"),
                    SizedBox(height: 8.h),
                    if (widget.useDefaultAmount) ...[
                      // Read-only amount display — swipe-path uses the
                      // user's default amount; the manual input field
                      // and quick chips are intentionally hidden so
                      // this is a confirm-and-buy interaction.
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 14.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.inputFieldBgDynamic(context),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: [
                            Text(
                              "${amount.toStringAsFixed(0)} GHS",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color:
                                    AppColors.textPrimaryDynamic(context),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              "Default amount",
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        onChanged: updateAmount,
                        decoration: InputDecoration(
                          hintText: "0.00",
                          filled: true,
                          fillColor:
                              AppColors.inputFieldBgDynamic(context),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 14.h,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [10, 20, 50, 100].map((e) {
                          return GestureDetector(
                            onTap: () => addQuickAmount(e.toDouble()),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 5.h,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                "$e GHS",
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16.sp,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],

                    SizedBox(height: 20.h),
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: AppColors.inputFieldBgDynamic(context),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Column(
                        children: [
                          buildRow("Shares", shares.toStringAsFixed(2)),
                          buildRow("Price per Share", "₹$price"),
                          buildRow(
                            "Max Payout",
                            "₹${payout.toStringAsFixed(2)}",
                          ),
                          buildRow(
                            "Potential Profit",
                            "₹${profit.toStringAsFixed(2)}",
                            isProfit: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
              color: isProfit ? Colors.green : Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
