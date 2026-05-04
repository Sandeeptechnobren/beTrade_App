import 'package:flutter/foundation.dart';

import '../services/wallet_service.dart';

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

  bool _isDisposed = false;

  @override
  void dispose() {
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
  }) async {
    isSubmittingDeposit = true;
    lastSubmitMessage = null;
    _safeNotify();

    final result = await WalletService.requestDeposit(
      amountGhs: amountGhs,
      method: method,
      msisdn: msisdn,
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
  }) async {
    isSubmittingWithdraw = true;
    lastSubmitMessage = null;
    lastWithdrawCode = null;
    _safeNotify();

    final result = await WalletService.requestWithdraw(
      amountGhs: amountGhs,
      destination: destination,
      msisdn: msisdn,
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
}
