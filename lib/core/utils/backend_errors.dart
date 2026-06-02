/// Single source of truth for backend typed-error code → user-facing
/// message. Keep this in lockstep with the codes the Laravel API throws
/// in `App\Services\*` and surfaces via `WalletController::errorFor`,
/// `BuyResponse`, etc.
///
/// Usage:
///   AppNotify.fromCode(code: result.code, fallback: 'Could not place the trade.');
///
/// or, when shaping inline text:
///   final msg = BackendErrors.messageFor(code, fallback: 'Something went wrong.');
///
/// Rules:
///   - Never surface a raw exception or backend `message` string to the
///     user. Always go through this map.
///   - The fallback is what gets shown if the code is unknown/null/empty.
///     Pick a fallback that reads correctly in the surface (e.g. "Buy
///     failed. Please try again.").
class BackendErrors {
  BackendErrors._();

  static const Map<String, String> _messages = {
    // ── Wallet (deposit / withdraw / balance) ───────────────────────
    'INSUFFICIENT_FUNDS': 'Not enough wallet balance. Top up to continue.',
    'NO_WALLET': 'No wallet on file. Please contact support.',
    'BELOW_MIN_AMOUNT': 'Amount is below the minimum allowed.',
    'ABOVE_MAX_AMOUNT': 'Amount exceeds the maximum allowed.',
    'GATEWAY_UNAVAILABLE': 'The payment gateway is temporarily unavailable. Please try again.',
    'GATEWAY_NOT_CONFIGURED': 'Payment isn\'t configured for your region yet.',
    'INVALID_METHOD': 'That payment method isn\'t available.',
    'WITHDRAWAL_NOT_PENDING': 'This withdrawal has already been processed.',
    'INVALID_WITHDRAWAL': 'Not a valid withdrawal transaction.',

    // ── Trade buy / sell ────────────────────────────────────────────
    'KYC_REQUIRED': 'Verify your account to start trading.',
    'MARKET_CLOSED': 'This market is closed or has been resolved.',
    'BELOW_MIN_COST': 'Trade amount is below the minimum allowed.',
    'ABOVE_MAX_COST': 'Trade amount exceeds the maximum allowed.',
    'UNKNOWN_OUTCOME': 'Could not match the selected outcome. Please reopen the market.',
    'INSUFFICIENT_SHARES': 'You no longer hold that many shares.',
    'BELOW_MIN_SHARES': 'That amount is too small to sell.',

    // ── OTP / auth ──────────────────────────────────────────────────
    'TOO_MANY_ATTEMPTS': 'Too many attempts. Please request a new code.',
    'INVALID_OTP': 'That code is incorrect.',
    'OTP_EXPIRED': 'That code has expired. Please request a new one.',
    'OTP_NOT_FOUND': 'Verification code not found. Please request a new one.',

    // ── Account deletion ───────────────────────────────────────────
    'USER_NOT_FOUND': 'No account was found for this number.',
    'ACCOUNT_ALREADY_DELETED': 'This account has already been deleted.',
    'REQUEST_ALREADY_PENDING': 'A deletion request is already pending for this account.',
    'REFUND_DESTINATION_REQUIRED': 'Please provide a mobile-money number to receive your refund.',
    'NO_PENDING_REQUEST': 'There is no pending deletion request to cancel.',
    'INVALID_TOKEN': 'Your verification expired. Please verify your number again.',
    'INVALID_STATE': 'This request has already been processed.',
  };

  /// Look up the user-facing message for [code]. Returns [fallback] when
  /// [code] is null/empty/unknown — never the raw code or backend string.
  static String messageFor(String? code, {required String fallback}) {
    if (code == null || code.isEmpty) return fallback;
    return _messages[code] ?? fallback;
  }

  /// Whether we have a friendly mapping for this code. Useful when the
  /// caller wants to render something custom only for known codes.
  static bool has(String? code) =>
      code != null && code.isNotEmpty && _messages.containsKey(code);
}
