import 'package:dio/dio.dart';

import '../../core/config/api_endpoint.dart';
import '../../core/network/dio_client.dart';
import 'local_storage.dart';
import 'trade_buy_service.dart';

/// Read-only sell quote — what the user receives for selling N shares.
/// Mirrors `QuoteModel` but for the sell direction.
class SellQuote {
  final String outcomeSlug;
  final double shares;
  final double grossReceiptGhs;
  final double feeGhs;
  final double netReceiptGhs;
  final double avgPricePerShare;
  final double newPriceAfterSell;

  const SellQuote({
    required this.outcomeSlug,
    required this.shares,
    required this.grossReceiptGhs,
    required this.feeGhs,
    required this.netReceiptGhs,
    required this.avgPricePerShare,
    required this.newPriceAfterSell,
  });

  factory SellQuote.fromJson(Map<String, dynamic> json) {
    double d(dynamic v) =>
        v is num ? v.toDouble() : (double.tryParse(v?.toString() ?? '') ?? 0.0);
    return SellQuote(
      outcomeSlug: json['outcome_slug']?.toString() ?? '',
      shares: d(json['shares']),
      grossReceiptGhs: d(json['gross_receipt_ghs']),
      feeGhs: d(json['fee_ghs']),
      netReceiptGhs: d(json['net_receipt_ghs']),
      avgPricePerShare: d(json['avg_price_per_share']),
      newPriceAfterSell: d(json['new_price_after_sell']),
    );
  }
}

/// Typed envelope for the sell call so the UI can branch on
/// `success` + `code` (INSUFFICIENT_SHARES, MARKET_CLOSED, …).
class SellResult {
  final bool success;
  final String? message;
  final String? code;
  final double? walletBalance;
  final double? realizedPnlGhs;
  final double? remainingShares;

  const SellResult({
    required this.success,
    this.message,
    this.code,
    this.walletBalance,
    this.realizedPnlGhs,
    this.remainingShares,
  });

  factory SellResult.failure({String? message, String? code}) =>
      SellResult(success: false, message: message, code: code);
}

/// Sell side of the LMSR trade engine (P0-D).
///   POST /api/trade/{uuid}/quote-sell  (read-only)
///   POST /api/trade/{uuid}/sell        (mutating, idempotent)
class TradeSellService {
  /// Read-only receipt quote. Returns null on failure.
  static Future<SellQuote?> quoteSell({
    required String marketUuid,
    required String outcomeSlug,
    required double shares,
  }) async {
    try {
      final token = LocalStorage.getToken();
      final response = await DioClient.instance.post(
        ApiEndpoints.tradeQuoteSell(marketUuid),
        data: {'outcome_slug': outcomeSlug, 'shares': shares},
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
          return SellQuote.fromJson(Map<String, dynamic>.from(body['data'] as Map));
        }
      }
      return null;
    } on DioException catch (e) {
      print('TradeSellService.quoteSell DioException: ${e.message}; '
          'response=${e.response?.data}');
      return null;
    } catch (e) {
      print('TradeSellService.quoteSell error: $e');
      return null;
    }
  }

  /// Execute the sell. Auto-generates an idempotency key (UUID v4)
  /// per call so a retry replays server-side instead of double-selling.
  static Future<SellResult> sell({
    required String marketUuid,
    required String outcomeSlug,
    required double shares,
    String? idempotencyKey,
  }) async {
    try {
      final token = LocalStorage.getToken();
      final response = await DioClient.instance.post(
        ApiEndpoints.tradeSell(marketUuid),
        data: {
          'outcome_slug': outcomeSlug,
          'shares': shares,
          'idempotency_key':
              idempotencyKey ?? TradeBuyService.generateIdempotencyKey(),
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
        final data = body['data'] is Map ? body['data'] as Map : const {};
        final position = data['position'] is Map ? data['position'] as Map : const {};
        final quote = data['quote'] is Map ? data['quote'] as Map : const {};
        double? d(dynamic v) =>
            v == null ? null : (v is num ? v.toDouble() : double.tryParse(v.toString()));
        return SellResult(
          success: true,
          message: body['message']?.toString(),
          walletBalance: d(data['wallet_balance']),
          remainingShares: d(position['shares']),
          realizedPnlGhs: d(quote['realized_pnl_ghs']),
        );
      }
      return SellResult.failure(
        message: body is Map ? body['message']?.toString() : null,
      );
    } on DioException catch (e) {
      final body = e.response?.data;
      final code = body is Map ? body['code']?.toString() : null;
      final message = body is Map ? body['message']?.toString() : null;
      print('TradeSellService.sell DioException: code=$code message=$message');
      return SellResult.failure(
        message: message ?? e.message ?? 'Could not complete the sell.',
        code: code,
      );
    } catch (e) {
      print('TradeSellService.sell error: $e');
      return SellResult.failure(message: 'Could not complete the sell.');
    }
  }
}
