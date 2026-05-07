/// DTO for the `order` object inside a buy success response.
/// Captures the actual fill details (different from the pre-trade quote).
class OrderModel {
  final double shares;
  final double avgFillPrice;
  final double totalCostGhs;
  final double feeGhs;

  OrderModel({
    required this.shares,
    required this.avgFillPrice,
    required this.totalCostGhs,
    required this.feeGhs,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    double n(dynamic v) => (v is num) ? v.toDouble() : 0.0;
    return OrderModel(
      shares: n(json['shares']),
      avgFillPrice: n(json['avg_fill_price']),
      totalCostGhs: n(json['total_cost_ghs']),
      feeGhs: n(json['fee_ghs']),
    );
  }
}
