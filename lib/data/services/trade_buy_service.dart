import 'dart:math';

import 'package:dio/dio.dart';
import '../../core/config/api_endpoint.dart';
import '../../core/network/dio_client.dart';
import 'local_storage.dart';

/// Place an order against the LMSR trade engine.
///
/// Atomic on the backend: market open guard, KYC guard, wallet lock,
/// outcome locks, idempotency check — all wrapped in a DB transaction.
/// The mobile-side responsibility is just generating a fresh
/// idempotency key per "Buy" tap and mapping typed error codes from
/// the backend to user-readable messages.
class TradeBuyService {
  /// POST /api/trade/{uuid}/buy
  ///
  /// Returns a Map with at minimum:
  ///   { 'success': bool, 'message': String }
  /// Plus on success:
  ///   { 'data': { order, position, wallet_balance, quote } }
  /// Plus on typed backend error:
  ///   { 'code': 'INSUFFICIENT_FUNDS' | 'KYC_REQUIRED' | 'MARKET_CLOSED'
  ///           | 'BELOW_MIN_COST' | 'ABOVE_MAX_COST' | 'UNKNOWN_OUTCOME' }
  ///
  /// `idempotencyKey` MUST be a fresh UUID v4 per "Buy" tap. If the
  /// network drops mid-call and the user retries with the same key,
  /// the backend short-circuits to the original Order without
  /// re-charging the wallet. Use [generateIdempotencyKey] from this
  /// class.
  static Future<Map<String, dynamic>> buy({
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
      if (response.statusCode == 200 && body is Map && body['status'] == true) {
        return {
          'success': true,
          'message': body['message']?.toString() ?? 'Order filled.',
          'data': body['data'] is Map
              ? Map<String, dynamic>.from(body['data'] as Map)
              : null,
        };
      }
      return {
        'success': false,
        'message':
            (body is Map ? body['message']?.toString() : null) ?? 'Buy failed.',
      };
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
      final code = body is Map ? body['code']?.toString() : null;
      final message = body is Map ? body['message']?.toString() : null;
      print('TradeBuyService DioException: code=$code message=$message; '
          'response=$body');
      return {
        'success': false,
        'code': code,
        'message': message ?? e.message ?? 'Buy failed.',
      };
    } catch (e) {
      print('TradeBuyService error: $e');
      return {
        'success': false,
        'message': 'Buy failed. Please try again.',
      };
    }
  }

  /// Generate an RFC 4122 v4 UUID using a cryptographically secure
  /// random source. Used as the idempotency_key for /buy.
  ///
  /// We hand-roll this rather than adding the `uuid` package as a
  /// dependency for one call site — the math is 6 lines and avoids
  /// pubspec.lock churn during cross-team integration.
  static String generateIdempotencyKey() {
    final rng = Random.secure();
    final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
    // Per RFC 4122 §4.4: set version (4) and variant (10) bits.
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
