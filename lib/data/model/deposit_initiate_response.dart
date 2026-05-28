/// Response envelope for `POST /api/wallet/deposit/initiate`.
///
/// Backend always returns this shape (200 on idempotency replay, 201 on
/// fresh insert). Exactly one of `checkoutUrl` / `stkPush` /
/// `virtualAccount` is populated, based on `method`.
///
/// Field source-of-truth: tasks/portfolio_deposit_flutter_bind_points.md §3.
class DepositInitiateResponse {
  final int pspTransactionId;
  final String ourReference;
  final String status;            // 'pending' | 'success' | 'failed' | 'expired'
  final bool replayed;
  final double amountGhs;
  final String method;            // 'card' | 'mobile_money' | 'bank_account'

  // Card path
  final String? checkoutUrl;

  // Mobile money path
  final StkPushInfo? stkPush;

  // Bank account path
  final VirtualAccountInfo? virtualAccount;

  const DepositInitiateResponse({
    required this.pspTransactionId,
    required this.ourReference,
    required this.status,
    required this.replayed,
    required this.amountGhs,
    required this.method,
    this.checkoutUrl,
    this.stkPush,
    this.virtualAccount,
  });

  factory DepositInitiateResponse.fromJson(Map<String, dynamic> json) {
    return DepositInitiateResponse(
      pspTransactionId:
          (json['psp_transaction_id'] as num?)?.toInt() ?? 0,
      ourReference: json['our_reference']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      replayed: json['replayed'] == true,
      amountGhs: (json['amount_ghs'] as num?)?.toDouble() ?? 0.0,
      method: json['method']?.toString() ?? '',
      checkoutUrl: json['checkout_url']?.toString(),
      stkPush: json['stk_push'] is Map
          ? StkPushInfo.fromJson(
              Map<String, dynamic>.from(json['stk_push'] as Map))
          : null,
      virtualAccount: json['virtual_account'] is Map
          ? VirtualAccountInfo.fromJson(
              Map<String, dynamic>.from(json['virtual_account'] as Map))
          : null,
    );
  }
}

/// Mobile-money STK-push payload.
class StkPushInfo {
  final String instructions;
  final String expiresAt;

  const StkPushInfo({required this.instructions, required this.expiresAt});

  factory StkPushInfo.fromJson(Map<String, dynamic> json) => StkPushInfo(
        instructions: json['instructions']?.toString() ?? '',
        expiresAt: json['expires_at']?.toString() ?? '',
      );
}

/// Bank-account virtual-account payload.
class VirtualAccountInfo {
  final String bankName;
  final String accountNumber;
  final String accountName;
  final String referenceCode;
  final String expiresAt;

  const VirtualAccountInfo({
    required this.bankName,
    required this.accountNumber,
    required this.accountName,
    required this.referenceCode,
    required this.expiresAt,
  });

  factory VirtualAccountInfo.fromJson(Map<String, dynamic> json) =>
      VirtualAccountInfo(
        bankName: json['bank_name']?.toString() ?? '',
        accountNumber: json['account_number']?.toString() ?? '',
        accountName: json['account_name']?.toString() ?? '',
        referenceCode: json['reference_code']?.toString() ?? '',
        expiresAt: json['expires_at']?.toString() ?? '',
      );
}
