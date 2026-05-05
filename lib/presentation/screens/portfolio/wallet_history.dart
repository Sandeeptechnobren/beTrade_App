import 'package:betrade/core/theme/app_colors.dart';
import 'package:betrade/core/theme/app_text_style.dart';
import 'package:betrade/data/provider/wallet_provider.dart';
import 'package:betrade/presentation/widget/common_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class WalletHistoryPage extends StatefulWidget {
  const WalletHistoryPage({super.key});
  @override
  State<WalletHistoryPage> createState() => _WalletHistoryPageState();
}

class _WalletHistoryPageState extends State<WalletHistoryPage> {
  // UI label → backend `type` enum value. Null = no filter (all rows).
  static const Map<String, String?> _filterMap = {
    'All': null,
    'Deposits': 'deposit',
    'Withdrawals': 'withdraw',
    'Trades': 'trade',
    'Payouts': 'payout',
  };

  String selectedType = 'All';

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context
          .read<WalletProvider>()
          .fetchTransactions(type: _filterMap[selectedType]);
    });
  }

  void _onFilterChanged(String value) {
    setState(() {
      selectedType = value;
    });
    context
        .read<WalletProvider>()
        .fetchTransactions(type: _filterMap[value]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 16.w, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CommonHeader(title: 'Wallet History', showDivider: false),
                  PopupMenuButton<String>(
                    onSelected: _onFilterChanged,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    color: Colors.white,
                    elevation: 8,
                    itemBuilder: (context) => _filterMap.keys
                        .map(
                          (label) => PopupMenuItem(
                            value: label,
                            padding: EdgeInsets.zero,
                            child: _menuItem(label),
                          ),
                        )
                        .toList(),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25.r),
                        border: Border.all(color: AppColors.inputFieldBg),
                      ),
                      child: Row(
                        children: [
                          Text(selectedType, style: AppTextStyle.body),
                          SizedBox(width: 4.w),
                          Icon(Icons.keyboard_arrow_down, size: 20.sp),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: Consumer<WalletProvider>(
                builder: (context, wallet, _) {
                  if (wallet.isLoadingTransactions) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (wallet.transactionsError != null) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.w),
                        child: Text(
                          wallet.transactionsError!,
                          textAlign: TextAlign.center,
                          style: AppTextStyle.body,
                        ),
                      ),
                    );
                  }
                  if (wallet.transactions.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.w),
                        child: Text(
                          'No $selectedType yet.',
                          style: AppTextStyle.body,
                        ),
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () =>
                        wallet.fetchTransactions(type: _filterMap[selectedType]),
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 12.h),
                      itemCount: wallet.transactions.length,
                      separatorBuilder: (_, __) => SizedBox(height: 10.h),
                      itemBuilder: (context, i) =>
                          _txRow(wallet.transactions[i]),
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

  Widget _menuItem(String text) {
    final isSelected = selectedType == text;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFE9DDF5) : Colors.transparent,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(text, style: AppTextStyle.body),
    );
  }

  /// Render one Transaction row from the WalletProvider list.
  /// Backend shape:
  ///   { id, type, amount, fee, status, reference_id, created_at }
  Widget _txRow(Map<String, dynamic> tx) {
    final type = tx['type']?.toString() ?? '';
    final amountRaw = double.tryParse(tx['amount'].toString()) ?? 0.0;
    final status = tx['status']?.toString() ?? '';
    final reference = tx['reference_id']?.toString() ?? '';

    // Inflows: deposit, payout, and positive 'trade' amounts (sells).
    // Outflows: withdraw, and negative 'trade' amounts (buys).
    final isInflow = amountRaw > 0;

    final displayTitle = _titleFor(type);
    final displaySubtitle = status.isNotEmpty && reference.isNotEmpty
        ? '${status[0].toUpperCase()}${status.substring(1)} • $reference'
        : (status.isNotEmpty
            ? '${status[0].toUpperCase()}${status.substring(1)}'
            : reference);

    final sign = isInflow ? '+' : '';
    final amountStr = '$sign${amountRaw.toStringAsFixed(2)} GHS';

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.inputFieldBgDynamic(context),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          Container(
            height: 40.h,
            width: 40.w,
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: isInflow
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isInflow ? Icons.arrow_downward : Icons.arrow_upward,
              color: isInflow ? Colors.green : Colors.red,
              size: 18.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(displayTitle, style: AppTextStyle.body),
                if (displaySubtitle.isNotEmpty)
                  Text(displaySubtitle, style: AppTextStyle.small),
              ],
            ),
          ),
          Text(
            amountStr,
            style: TextStyle(
              color: isInflow ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
            ),
          ),
        ],
      ),
    );
  }

  /// Map the backend `type` enum value to a friendly title.
  String _titleFor(String type) {
    switch (type) {
      case 'deposit':
        return 'Deposit';
      case 'withdraw':
        return 'Withdrawal';
      case 'trade':
        return 'Trade';
      case 'payout':
        return 'Payout';
      default:
        return type.isEmpty ? 'Transaction' : type;
    }
  }
}
