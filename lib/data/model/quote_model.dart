/// DTO for the `data` payload returned by `POST /trade/{uuid}/quote`
/// (also embedded inside the `quote` field of buy success responses).
///
/// Live LMSR pricing for the entered (outcome, cost). All numbers are
/// kept as `double` so callers can format/display directly.
class QuoteModel {
  final String outcomeSlug;
  final double costGhs;
  final double shares;
  final double avgPricePerShare;
  final double newPriceAfterFill;
  final double maxPayoutGhs;
  final double potentialProfitGhs;
  final double feeGhs;

  QuoteModel({
    required this.outcomeSlug,
    required this.costGhs,
    required this.shares,
    required this.avgPricePerShare,
    required this.newPriceAfterFill,
    required this.maxPayoutGhs,
    required this.potentialProfitGhs,
    required this.feeGhs,
  });

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    double n(dynamic v) => (v is num) ? v.toDouble() : 0.0;

    return QuoteModel(
      outcomeSlug: json['outcome_slug']?.toString() ?? '',
      costGhs: n(json['cost_ghs']),
      shares: n(json['shares']),
      avgPricePerShare: n(json['avg_price_per_share']),
      newPriceAfterFill: n(json['new_price_after_fill']),
      maxPayoutGhs: n(json['max_payout_ghs']),
      potentialProfitGhs: n(json['potential_profit_ghs']),
      feeGhs: n(json['fee_ghs']),
    );
  }
}
