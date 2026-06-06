import 'dart:async';

import 'package:flutter/foundation.dart';

import '../model/deposit_initiate_response.dart';
import '../services/wallet_service.dart';
import '../services/trade_buy_service.dart';

/// State holder for the Portfolio + wallet history + deposit / withdraw
/// flows. Single instance lives in main.dart's MultiProvider; consumed
/// via context.watch / Consumer in:
///   - portfolio_page.dart       (balance card)
///   - wallet_history.dart       (transactions list)
///   - newDeposit.dart           (deposit form submit)
///   - withdrawal.dart           (withdraw form submit)
class WalletProvider extends ChangeNotifier {
  // Balance
  double balance = 0.0;
  String currency = 'GHS';
  DateTime? lastUpdated;
  bool isLoadingBalance = false;
  String? balanceError;

  // Transactions
  List<Map<String, dynamic>> transactions = [];
  String? currentTypeFilter; // 'deposit' | 'withdraw' | 'trade' | 'payout'
  bool isLoadingTransactions = false;
  String? transactionsError;

  // Submit flows
  bool isSubmittingDeposit = false;
  bool isSubmittingWithdraw = false;
  String? lastSubmitMessage;

  // P0-A — gateway-backed initiate flow state
  bool isInitiatingDeposit = false;
  DepositInitiateResponse? lastInitiateResponse;
  String? lastInitiateMessage;
  String? lastInitiateCode; // typed: BELOW_MIN_AMOUNT, GATEWAY_UNAVAILABLE, ...

  // Balance polling — used by the deposit-waiting screen so the UI
  // can detect a webhook-driven credit without manual refresh.
  Timer? _balancePoll;
  bool isPollingBalance = false;

  bool _isDisposed = false;

  @override
  void dispose() {
    _balancePoll?.cancel();
    _balancePoll = null;
    _isDisposed = true;
    super.dispose();
  }

  void _safeNotify() {
    if (!_isDisposed) notifyListeners();
  }

  /// GET /api/wallet
  Future<void> fetchBalance() async {
    isLoadingBalance = true;
    balanceError = null;
    _safeNotify();

    final data = await WalletService.getBalance();

    if (data == null) {
      balanceError = 'Could not load wallet.';
    } else {
      balance = (data['balance_ghs'] as num?)?.toDouble() ?? 0.0;
      currency = data['currency']?.toString() ?? 'GHS';
      final updatedAt = data['updated_at']?.toString();
      lastUpdated = updatedAt != null ? DateTime.tryParse(updatedAt) : null;
    }

    isLoadingBalance = false;
    _safeNotify();
  }

  /// GET /api/wallet/transactions?type=
  /// Pass [type] = null to fetch all types.
  Future<void> fetchTransactions({String? type}) async {
    isLoadingTransactions = true;
    transactionsError = null;
    currentTypeFilter = type;
    _safeNotify();

    final list = await WalletService.getTransactions(type: type);

    transactions = list;
    isLoadingTransactions = false;
    _safeNotify();
  }

  /// POST /api/wallet/deposit
  /// Returns true on success so the calling screen can pop / show success.
  Future<bool> submitDeposit({
    required double amountGhs,
    String? method,
    String? msisdn,
    String? idempotencyKey,
  }) async {
    isSubmittingDeposit = true;
    lastSubmitMessage = null;
    _safeNotify();

    // P0-B: auto-generate a UUID v4 per call so retries replay
    // server-side instead of creating duplicate pending transactions.
    final result = await WalletService.requestDeposit(
      amountGhs: amountGhs,
      method: method,
      msisdn: msisdn,
      idempotencyKey:
          idempotencyKey ?? TradeBuyService.generateIdempotencyKey(),
    );

    isSubmittingDeposit = false;
    lastSubmitMessage = result['message']?.toString();

    if (result['success'] == true) {
      // Deposit creates a pending Transaction — no balance change yet.
      // Refresh transactions so the user sees the new pending row.
      await fetchTransactions(type: currentTypeFilter);
      return true;
    }

    _safeNotify();
    return false;
  }

  /// POST /api/wallet/withdraw
  /// Returns true on success. On failure, [lastSubmitMessage] holds a
  /// user-readable error and consumers can also branch on whether the
  /// underlying code was 'INSUFFICIENT_FUNDS' via [_lastWithdrawCode].
  String? lastWithdrawCode;

  Future<bool> submitWithdraw({
    required double amountGhs,
    required String destination,
    String? msisdn,
    String? idempotencyKey,
  }) async {
    isSubmittingWithdraw = true;
    lastSubmitMessage = null;
    lastWithdrawCode = null;
    _safeNotify();

    // P0-B: auto-generate a UUID v4 per Confirm tap so a network
    // retry never debits the wallet twice. Backend (`/api/wallet/withdraw`)
    // is idempotent on `(user_id, idempotency_key)`.
    final result = await WalletService.requestWithdraw(
      amountGhs: amountGhs,
      destination: destination,
      msisdn: msisdn,
      idempotencyKey:
          idempotencyKey ?? TradeBuyService.generateIdempotencyKey(),
    );

    isSubmittingWithdraw = false;
    lastSubmitMessage = result['message']?.toString();
    lastWithdrawCode = result['code']?.toString();

    if (result['success'] == true) {
      // Withdraw debits the wallet immediately — refresh both views.
      await fetchBalance();
      await fetchTransactions(type: currentTypeFilter);
      return true;
    }

    _safeNotify();
    return false;
  }

  /// Convenience for screens that show a snackbar + reset.
  void clearSubmitMessage() {
    lastSubmitMessage = null;
    lastWithdrawCode = null;
    _safeNotify();
  }

  // ─── P0-A — gateway-backed deposit ────────────────────────────────

  /// POST /api/wallet/deposit/initiate
  ///
  /// Returns the parsed `DepositInitiateResponse` on success so the
  /// caller can navigate to the right waiting screen based on `method`
  /// (card → WebView/checkout_url, mobile_money → STK push waiting,
  /// bank_account → virtual-account display).
  ///
  /// Returns null on failure; check [lastInitiateCode] and
  /// [lastInitiateMessage] for the typed error code + user-readable
  /// message.
  ///
  /// [idempotencyKey] is auto-generated via `TradeBuyService.generateIdempotencyKey()`
  /// if not supplied — same UUID-v4 pattern used by the trade-buy flow.
  Future<DepositInitiateResponse?> submitDepositInitiate({
    required double amountGhs,
    required String method, // 'card' | 'mobile_money' | 'bank_account'
    required Map<String, dynamic> methodPayload,
    bool savePaymentMethod = false,
    String? idempotencyKey,
  }) async {
    isInitiatingDeposit = true;
    lastInitiateMessage = null;
    lastInitiateCode = null;
    lastInitiateResponse = null;
    _safeNotify();

    final result = await WalletService.initiateDeposit(
      amountGhs: amountGhs,
      method: method,
      methodPayload: methodPayload,
      idempotencyKey:
          idempotencyKey ?? TradeBuyService.generateIdempotencyKey(),
      savePaymentMethod: savePaymentMethod,
    );

    isInitiatingDeposit = false;
    lastInitiateMessage = result.message;
    lastInitiateCode = result.code;
    lastInitiateResponse = result.data;
    _safeNotify();

    return result.success ? result.data : null;
  }

  /// Start polling `GET /api/wallet` at the given interval so the
  /// deposit-waiting screen can detect a webhook-driven credit
  /// without the user having to pull-to-refresh.
  ///
  /// Caller MUST eventually call [stopBalancePolling] (typically in
  /// the waiting screen's dispose or once the balance moves).
  ///
  /// [onBalanceIncrease] fires once with the new balance the moment
  /// the polled value rises above the value at start time.
  void startBalancePolling({
    Duration interval = const Duration(seconds: 5),
    void Function(double newBalance)? onBalanceIncrease,
  }) {
    if (isPollingBalance) return;
    isPollingBalance = true;
    _balancePoll?.cancel();
    _balancePoll = Timer.periodic(interval, (_) async {
      final before = balance;
      await fetchBalance();
      if (_isDisposed) return;
      if (balance > before) {
        // Credited — fire callback once, stop polling.
        onBalanceIncrease?.call(balance);
        stopBalancePolling();
      }
    });
  }

  void stopBalancePolling() {
    _balancePoll?.cancel();
    _balancePoll = null;
    isPollingBalance = false;
    _safeNotify();
  }
}
