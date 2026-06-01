import 'package:dio/dio.dart';
import '../../core/config/api_endpoint.dart';
import '../../core/network/dio_client.dart';
import '../../core/utils/app_logger.dart';
import '../../core/utils/idempotency.dart';
import '../model/buy_response.dart';
import 'local_storage.dart';

class TradeBuyService {

  static Future<BuyResponse> buy({
    required String marketUuid,
    required String outcomeSlug,
    required double costGhs,
    required String idempotencyKey,
  }) async {
    try {
      final token = LocalStorage.getToken();
      final response = await DioClient.instance.post(
        ApiEndpoints.tradeBuy(marketUuid),
        data: {
          'outcome_slug': outcomeSlug,
          'cost_ghs': costGhs,
          'idempotency_key': idempotencyKey,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      final body = response.data;
      if (response.statusCode == 200 && body is Map) {
        return BuyResponse.fromJson(Map<String, dynamic>.from(body));
      }
      return BuyResponse.networkFailure(
        body is Map ? body['message']?.toString() : null,
      );
    } on DioException catch (e) {
      // Backend ships typed error codes in the response body for the
      // 402 / 403 / 409 / 422 paths (see TradeController::errorFor).
      // We surface code + message so the UI can react specifically:
      //   INSUFFICIENT_FUNDS → "Top up wallet" CTA
      //   KYC_REQUIRED       → push KYC screen
      //   MARKET_CLOSED      → close sheet + refresh detail
      //   BELOW/ABOVE_*COST  → in-line cost validation hint
      //   UNKNOWN_OUTCOME    → developer bug; show generic
      final body = e.response?.data;
      AppLogger.e('TradeBuyService.buy', 'buy failed', error: e);
      if (body is Map) {
        return BuyResponse.fromJson(Map<String, dynamic>.from(body));
      }
      return BuyResponse.networkFailure(e.message);
    } catch (e) {
      AppLogger.e('TradeBuyService.buy', 'unexpected error', error: e);
      return BuyResponse.networkFailure();
    }
  }

  /// Delegates to [Idempotency.newKey]. Kept for existing callers; new code
  /// should call [Idempotency.newKey] directly.
  static String generateIdempotencyKey() => Idempotency.newKey();
}
