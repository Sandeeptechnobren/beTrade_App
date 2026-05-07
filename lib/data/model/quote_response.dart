import 'quote_model.dart';

/// Typed wrapper for the `POST /trade/{uuid}/quote` response when the
/// caller needs status/code/message in addition to the quote payload
/// (e.g. the Home swipe path that maps `MARKET_CLOSED` to a specific
/// snackbar). The detail-screen [BuyBottomSheet] uses
/// [TradeQuoteService.quote] which returns a bare [QuoteModel] — no
/// wrapper needed there.
class QuoteResponse {
  final bool success;
  final String? message;
  final String? code;
  final QuoteModel? quote;

  QuoteResponse({
    required this.success,
    this.message,
    this.code,
    this.quote,
  });

  factory QuoteResponse.fromJson(Map<String, dynamic> json) {
    QuoteModel? quote;
    if (json['data'] is Map) {
      quote = QuoteModel.fromJson(
        Map<String, dynamic>.from(json['data'] as Map),
      );
    }
    return QuoteResponse(
      success: json['status'] == true,
      message: json['message']?.toString(),
      code: json['code']?.toString(),
      quote: quote,
    );
  }

  factory QuoteResponse.networkFailure([String? message]) => QuoteResponse(
        success: false,
        message: message ?? 'Could not fetch quote.',
      );
}
