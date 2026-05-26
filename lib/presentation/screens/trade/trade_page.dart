import 'dart:async';

import 'package:betrade/core/theme/app_colors.dart';
import 'package:betrade/presentation/screens/profile/default_settings_page.dart';
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
      return const Scaffold(body: Center(child: Text("No Data Found",textAlign: TextAlign.center,)));
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
              padding: EdgeInsets.symmetric(horizontal: 0.w,vertical: 0.h),
              child: Row(
                children: [
                  CommonHeader(title: "New Trade",showDivider: false,),
                  const Spacer(),
                  // ── Yes/No outcome toggle (matches Figma "Success" ─
                  // header). Outer pill is the unselected "track"; the
                  // selected option floats inside as a white card with a
                  // soft shadow. Animated for the transition between
                  // states.
                  Container(
                    margin: EdgeInsets.only(right: 14.w),
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: AppColors.inputFieldBgDynamic(context),
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _outcomeToggleChip(
                          label: "Yes",
                          selected: isYesSelected,
                          onTap: () => _selectOutcome(true),
                        ),
                        _outcomeToggleChip(
                          label: "No",
                          selected: !isYesSelected,
                          onTap: () => _selectOutcome(false),
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
                          // A chip is "selected" when the current amount
                          // matches its value. If the user types a custom
                          // amount, no chip is selected (correct).
                          final isSelected = amount == e.toDouble();
                          return GestureDetector(
                            onTap: () => selectQuickAmount(e.toDouble()),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 5.h,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.grey,
                                ),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                "$e GHS",
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.primary,
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
                          buildRow("Price per Share", "${price.toStringAsFixed(0)} GHS"),
                          // Highlight the "Yes"/"No" side word in purple
                          // so the user can see which outcome the shares
                          // belong to (matches Figma "Your Yes Shares" /
                          // "Your No Shares" treatment).
                          buildSharesRow(
                            outcome: isYesSelected ? "Yes" : "No",
                            shares: shares.toStringAsFixed(3),
                          ),
                          buildRow(
                            "Max Payout",
                            "${payout.toStringAsFixed(2)} GHS",
                          ),
                          buildRow(
                            "Potential Profit",
                            "+${profit.toStringAsFixed(2)} GHS",
                            isProfit: true,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h),
                    // Info banner — matches Figma. Light-purple chip with
                    // a contextual explanation of what the user is about
                    // to buy. The first sentence is dynamic (shares +
                    // price-per-share rounded as cents); the rest is
                    // static prose.
                    _buildInfoBanner(
                      shares: shares,
                      pricePerShareGhs: price,
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
              color: isProfit ? Colors.green : AppColors.textPrimaryDynamic(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// "Your Yes Shares" / "Your No Shares" row — same layout as buildRow
  /// but the side word is rendered in the brand purple so the user
  /// can tell at a glance which outcome these shares belong to.
  Widget buildSharesRow({required String outcome, required String shares}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: TextSpan(
              style: TextStyle(
                color: AppColors.textPrimaryDynamic(context),
                fontSize: 14.sp,
              ),
              children: [
                const TextSpan(text: "Your "),
                TextSpan(
                  text: outcome,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const TextSpan(text: " Shares"),
              ],
            ),
          ),
          Text(
            shares,
            style: TextStyle(
              color: AppColors.textPrimaryDynamic(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Single chip in the Yes/No outcome toggle. Selected state =
  /// elevated white pill with a soft shadow + bold dark text;
  /// unselected = transparent (so the outer grey track shows) +
  /// medium-weight muted text. Matches the Figma "Success" frame.
  Widget _outcomeToggleChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.cardBackgroundDynamic(context)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected
                ? AppColors.textPrimaryDynamic(context)
                : AppColors.textSecondaryDynamic(context),
          ),
        ),
      ),
    );
  }

  /// Light-purple "what you're buying" explanation chip shown beneath
  /// the price summary. Per Figma "New Trade — Success".
  Widget _buildInfoBanner({
    required double shares,
    required double pricePerShareGhs,
  }) {
    // Convert price-per-share (GHS) to cents-style display ("48¢").
    // Below 1 GHS price we round to the nearest cent; above we still
    // show the cents value so the sentence reads consistently.
    final cents = (pricePerShareGhs * 100).round();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.18),
          width: 0.5,
        ),
      ),
      child: Text.rich(
        TextSpan(
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.textPrimaryDynamic(context),
            height: 1.45,
          ),
          children: [
            const TextSpan(text: "You're buying "),
            TextSpan(
              text: shares.toStringAsFixed(2),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const TextSpan(text: " shares at "),
            TextSpan(
              text: "$cents¢",
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const TextSpan(
              text: " each. This market will close when the event "
                  "occurs. If you're right, payout is expected 2 hours later.",
            ),
          ],
        ),
      ),
    );
  }
}
