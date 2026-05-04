import 'package:dio/dio.dart';
import '../../core/config/api_endpoint.dart';
import '../../core/network/dio_client.dart';
import 'local_storage.dart';

/// Read-only LMSR pricing for the trade detail screen.
/// Powers the live "you'll receive X shares" calc as the user types
/// in the cost field. Backend throttles this at 60/min so debounce
/// in the UI before calling.
class TradeQuoteService {
  /// POST /api/trade/{uuid}/quote
  /// Returns the `data` map from the response, or null on failure.
  ///
  /// The shape on success:
  /// {
  ///   outcome_slug, cost_ghs, shares, avg_price_per_share,
  ///   new_price_after_fill, max_payout_ghs, potential_profit_ghs, fee_ghs
  /// }
  static Future<Map<String, dynamic>?> quote({
    required String marketUuid,
    required String outcomeSlug,
    required double costGhs,
  }) async {
    try {
      final token = LocalStorage.getToken();
      final response = await DioClient.instance.post(
        ApiEndpoints.tradeQuote(marketUuid),
        data: {
          'outcome_slug': outcomeSlug,
          'cost_ghs': costGhs,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data is Map) {
        final body = response.data as Map;
        if (body['status'] == true && body['data'] is Map) {
          return Map<String, dynamic>.from(body['data'] as Map);
        }
      }
      return null;
    } on DioException catch (e) {
      // Typed error codes from the backend (INSUFFICIENT_FUNDS,
      // MARKET_CLOSED, KYC_REQUIRED, BELOW_MIN_COST, ABOVE_MAX_COST,
      // UNKNOWN_OUTCOME) live in e.response.data — propagating those
      // belongs in the next PR (the Buy bottom sheet that consumes
      // them). Quote-only callers don't need them.
      print('TradeQuoteService DioException: ${e.message}; '
          'response=${e.response?.data}');
      return null;
    } catch (e) {
      print('TradeQuoteService error: $e');
      return null;
    }
  }
}
