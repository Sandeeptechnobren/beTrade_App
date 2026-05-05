import 'order_model.dart';
import 'quote_model.dart';

/// Typed wrapper around the response from `POST /trade/{uuid}/buy`.
///
/// On success: [success] is true, [order] / [quote] / [walletBalance] populated.
/// On typed backend error: [success] false, [code] holds one of:
///   `INSUFFICIENT_FUNDS`, `KYC_REQUIRED`, `MARKET_CLOSED`,
///   `BELOW_MIN_COST`, `ABOVE_MAX_COST`, `UNKNOWN_OUTCOME`.
class BuyResponse {
  final bool success;
  final String? message;
  final String? code;
  final OrderModel? order;
  final QuoteModel? quote;
  final double? walletBalance;

  BuyResponse({
    required this.success,
    this.message,
    this.code,
    this.order,
    this.quote,
    this.walletBalance,
  });

  factory BuyResponse.fromJson(Map<String, dynamic> json) {
    final dataField = json['data'];
    final data = dataField is Map
        ? Map<String, dynamic>.from(dataField as Map)
        : null;

    OrderModel? order;
    QuoteModel? quote;
    double? walletBalance;

    if (data != null) {
      if (data['order'] is Map) {
        order = OrderModel.fromJson(
          Map<String, dynamic>.from(data['order'] as Map),
        );
      }
      if (data['quote'] is Map) {
        quote = QuoteModel.fromJson(
          Map<String, dynamic>.from(data['quote'] as Map),
        );
      }
      if (data['wallet_balance'] is num) {
        walletBalance = (data['wallet_balance'] as num).toDouble();
      }
    }

    return BuyResponse(
      success: json['status'] == true,
      message: json['message']?.toString(),
      code: json['code']?.toString(),
      order: order,
      quote: quote,
      walletBalance: walletBalance,
    );
  }

  /// Build a generic failure result when the network call itself fails
  /// (no JSON body to parse).
  factory BuyResponse.networkFailure([String? message]) => BuyResponse(
        success: false,
        message: message ?? 'Buy failed. Please try again.',
      );
}
