import 'package:betrade/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../data/services/trade_details_service.dart';
import '../../widget/buy_bottom_sheet.dart';
import '../../widget/common_header.dart';

class TradePage extends StatefulWidget {
  final String tradeUuid;
  final ScrollController scrollController;
  const TradePage({
    super.key,
    required this.scrollController,
    required this.tradeUuid,
  });

  @override
  State<TradePage> createState() => _TradePageState();
}

class _TradePageState extends State<TradePage> {
  bool isYesSelected = true;

  TextEditingController amountController = TextEditingController();
  double amount = 0;

  Map<String, dynamic>? tradeData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTradeDetail();
  }

  void fetchTradeDetail() async {
    final data = await TradeDetailService.getTradeDetail(widget.tradeUuid);

    setState(() {
      tradeData = data;
      isLoading = false;
    });
  }

  void updateAmount(String value) {
    setState(() {
      amount = double.tryParse(value) ?? 0;
    });
  }

  void addQuickAmount(double value) {
    setState(() {
      amount += value;
      amountController.text = amount.toStringAsFixed(0);
    });
  }

  bool get isEnabled => amount > 0;

  double get price =>
      double.tryParse("${tradeData?["current_price_per_share"]}") ?? 0;

  double get shares => price > 0 ? amount / price : 0;

  double get payout => shares * price;

  double get profit => payout - amount;

  /// Show the confirm-and-buy bottom sheet for the current
  /// (outcome, amount). Refreshes trade detail on success so the
  /// price ticker, total volume etc. update with the user's own fill.
  Future<void> _openBuySheet(BuildContext context) async {
    // Capture the messenger BEFORE the await so we don't use
    // BuildContext across an async gap (lint: use_build_context_synchronously).
    final messenger = ScaffoldMessenger.of(context);

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
        marketTitle: tradeData?['title']?.toString(),
      ),
    );

    if (result == true && mounted) {
      // Refresh detail so the new price + volume reflect this fill.
      fetchTradeDetail();
      messenger.showSnackBar(
        const SnackBar(content: Text('Order filled.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (tradeData == null) {
      return const Scaffold(body: Center(child: Text("No Data Found")));
    }

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
                          onTap: () => setState(() => isYesSelected = true),
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
                          onTap: () => setState(() => isYesSelected = false),
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
                    Container(
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
                            "Market • ${tradeData?["category_name"] ?? ""}",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            "${tradeData!["description"]}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text("Amount"),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      onChanged: updateAmount,
                      decoration: InputDecoration(
                        hintText: "0.00",
                        filled: true,
                        fillColor:AppColors.inputFieldBgDynamic(context),
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
