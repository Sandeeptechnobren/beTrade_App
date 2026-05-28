import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../data/model/deposit_initiate_response.dart';
import '../../../../data/provider/wallet_provider.dart';

/// Post-initiate "awaiting payment" screen.
///
/// Renders one of three method-specific bodies driven by
/// [response.method]:
///   - card         → checkout-URL display + Copy to Clipboard.
///                    (When real Flutterwave is live, replace with a
///                    WebView. For now the URL is shown so the user /
///                    QA can verify the contract end-to-end.)
///   - mobile_money → STK-push instructions + expires_at countdown.
///                    User approves on phone.
///   - bank_account → virtual-account number + reference code, each
///                    with Copy to Clipboard.
///
/// All three bodies share the same footer behavior:
///   - WalletProvider.startBalancePolling() runs every 5 s. The
///     moment a webhook credits the wallet on the backend, the
///     balance pings up and we navigate to the success modal.
///   - A "Cancel" button lets the user back out (transaction stays
///     pending on the backend; admin can ignore/expire it).
class DepositWaitingScreen extends StatefulWidget {
  final DepositInitiateResponse response;

  const DepositWaitingScreen({super.key, required this.response});

  @override
  State<DepositWaitingScreen> createState() => _DepositWaitingScreenState();
}

class _DepositWaitingScreenState extends State<DepositWaitingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final wallet = context.read<WalletProvider>();
      wallet.startBalancePolling(
        interval: const Duration(seconds: 5),
        onBalanceIncrease: (newBalance) {
          if (!mounted) return;
          // Pop the waiting screen + bounce up to the form which will
          // close itself and show the success modal.
          Navigator.of(context).pop(true);
        },
      );
    });
  }

  @override
  void dispose() {
    // Stop polling if user backs out manually.
    final wallet = context.read<WalletProvider>();
    wallet.stopBalancePolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.response;
    return Scaffold(
      backgroundColor: AppColors.whiteDynamic(context),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: Text(
          'Awaiting Payment',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _amountHeader(r),
            SizedBox(height: 24.h),
            Expanded(child: _methodBody(r)),
            _pollingHint(),
            SizedBox(height: 10.h),
            _cancelButton(),
          ],
        ),
      ),
    );
  }

  Widget _amountHeader(DepositInitiateResponse r) {
    return Column(
      children: [
        Text(
          'Depositing',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          '${r.amountGhs.toStringAsFixed(2)} GHS',
          style: TextStyle(
            color: Colors.black,
            fontSize: 28.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          'Ref: ${r.ourReference}',
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 11.sp,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Widget _methodBody(DepositInitiateResponse r) {
    switch (r.method) {
      case 'card':
        return _cardBody(r);
      case 'mobile_money':
        return _momoBody(r);
      case 'bank_account':
        return _bankBody(r);
      default:
        return _unknownBody(r);
    }
  }

  // ── CARD ──────────────────────────────────────────────────────────
  Widget _cardBody(DepositInitiateResponse r) {
    final url = r.checkoutUrl ?? '';
    return _card(
      icon: Icons.credit_card,
      title: 'Complete payment in browser',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Open the secure checkout link below to enter your card '
            'details. Your card information stays with the payment '
            'gateway — BeTrade never sees it.',
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 16.h),
          _copyableField(label: 'Checkout link', value: url),
        ],
      ),
    );
  }

  // ── MOBILE MONEY ──────────────────────────────────────────────────
  Widget _momoBody(DepositInitiateResponse r) {
    final stk = r.stkPush;
    final expiresIn = _formatTimeUntil(stk?.expiresAt);
    return _card(
      icon: Icons.phone_iphone,
      title: 'Approve on your phone',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stk?.instructions ??
                'Approve the prompt on your phone within 5 minutes.',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade800,
              height: 1.4,
            ),
          ),
          if (expiresIn != null) ...[
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(Icons.timer_outlined,
                    size: 16.sp, color: Colors.grey.shade600),
                SizedBox(width: 6.w),
                Text(
                  'Expires $expiresIn',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── BANK ACCOUNT ──────────────────────────────────────────────────
  Widget _bankBody(DepositInitiateResponse r) {
    final va = r.virtualAccount;
    if (va == null) return _unknownBody(r);
    return _card(
      icon: Icons.account_balance,
      title: 'Transfer to this account',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Open your bank app and transfer the exact amount to the '
            'one-time account below. The deposit will be detected and '
            'credited automatically.',
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 16.h),
          _copyableField(label: 'Bank', value: va.bankName, copy: false),
          SizedBox(height: 12.h),
          _copyableField(label: 'Account number', value: va.accountNumber),
          SizedBox(height: 12.h),
          _copyableField(label: 'Reference', value: va.referenceCode),
          SizedBox(height: 12.h),
          _copyableField(label: 'Account name', value: va.accountName, copy: false),
        ],
      ),
    );
  }

  Widget _unknownBody(DepositInitiateResponse r) {
    return _card(
      icon: Icons.help_outline,
      title: 'Unknown method',
      body: Text(
        'The payment method "${r.method}" is not recognised by this '
        'build. Update the app and try again.',
        style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade700),
      ),
    );
  }

  // ── Reusable card ─────────────────────────────────────────────────
  Widget _card({
    required IconData icon,
    required String title,
    required Widget body,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.inputFieldBgDynamic(context),
        border: Border.all(color: Colors.grey.shade300, width: 0.5),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 22.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          body,
        ],
      ),
    );
  }

  Widget _copyableField({
    required String label,
    required String value,
    bool copy = true,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300, width: 0.5),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value.isEmpty ? '—' : value,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (copy && value.isNotEmpty)
            IconButton(
              icon: Icon(Icons.copy, size: 18.sp, color: AppColors.primary),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: value));
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$label copied'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _pollingHint() {
    return Consumer<WalletProvider>(
      builder: (context, wallet, _) {
        final polling = wallet.isPollingBalance;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 14.w,
              height: 14.w,
              child: polling
                  ? CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    )
                  : const SizedBox.shrink(),
            ),
            SizedBox(width: 8.w),
            Text(
              polling
                  ? 'Waiting for confirmation…'
                  : 'Polling paused',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _cancelButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () => Navigator.of(context).pop(false),
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.r),
          ),
        ),
        child: Text(
          'Cancel',
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Format an ISO timestamp into "in 4m 23s" relative to now.
  /// Returns null if [iso] is empty or unparseable.
  String? _formatTimeUntil(String? iso) {
    if (iso == null || iso.isEmpty) return null;
    final dt = DateTime.tryParse(iso);
    if (dt == null) return null;
    final remaining = dt.difference(DateTime.now().toUtc());
    if (remaining.isNegative) return 'expired';
    final m = remaining.inMinutes;
    final s = remaining.inSeconds - m * 60;
    return 'in ${m}m ${s}s';
  }
}
