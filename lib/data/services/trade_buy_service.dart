import 'dart:math';

import 'package:dio/dio.dart';
import '../../core/config/api_endpoint.dart';
import '../../core/network/dio_client.dart';
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
      // Response body intentionally NOT logged — contains the typed
      // error code we surface to the UI plus balance hints.
      print('TradeBuyService DioException: ${e.message}');
      if (body is Map) {
        return BuyResponse.fromJson(Map<String, dynamic>.from(body));
      }
      return BuyResponse.networkFailure(e.message);
    } catch (e) {
      print('TradeBuyService error: $e');
      return BuyResponse.networkFailure();
    }
  }

  static String generateIdempotencyKey() {
    final rng = Random.secure();
    final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    String hex(int n) => n.toRadixString(16).padLeft(2, '0');
    final s = bytes.map(hex).join();
    return '${s.substring(0, 8)}-'
        '${s.substring(8, 12)}-'
        '${s.substring(12, 16)}-'
        '${s.substring(16, 20)}-'
        '${s.substring(20, 32)}';
  }
}
