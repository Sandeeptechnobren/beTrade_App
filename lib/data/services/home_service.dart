import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../../core/config/api_endpoint.dart';
import '../../core/network/dio_client.dart';
import '../model/buy_response.dart';
import '../model/quote_response.dart';
import 'local_storage.dart';

class HomeService {
  static Future<QuoteResponse> getQuote({
    required String uuid,
    required String outcome,
    required int amount,
  }) async {
    debugPrint("🔵 Quote POST → uuid=$uuid, outcome=$outcome, amount=$amount");

    try {
      final token = LocalStorage.getToken();
      if (token == null || token.isEmpty) {
        debugPrint("❌ No auth token");
        return QuoteResponse.networkFailure('Not signed in.');
      }

      final response = await DioClient.instance.post(
        ApiEndpoints.tradeQuote(uuid),
        data: {
          "outcome_slug": outcome,
          "cost_ghs": amount,
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
        ),
      );

      debugPrint("🔵 Quote response: ${response.data}");

      if (response.data is Map) {
        return QuoteResponse.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
      return QuoteResponse.networkFailure();
    } on DioException catch (e) {
      debugPrint("❌ Dio error: ${e.response?.data}");
      final body = e.response?.data;
      if (body is Map) {
        return QuoteResponse.fromJson(Map<String, dynamic>.from(body));
      }
      return QuoteResponse.networkFailure(e.message);
    } catch (e) {
      debugPrint("❌ Exception: $e");
      return QuoteResponse.networkFailure();
    }
  }

  static Future<BuyResponse> buyTrade({
    required String uuid,
    required String outcome,
    required num amount,
    required String idempotencyKey,
  }) async {
    debugPrint("🔵 Buy POST → uuid=$uuid, outcome=$outcome, amount=$amount, "
        "idempotencyKey=$idempotencyKey");

    try {
      final token = LocalStorage.getToken();
      if (token == null || token.isEmpty) {
        debugPrint("❌ No auth token");
        return BuyResponse.networkFailure('Not signed in.');
      }

      final response = await DioClient.instance.post(
        ApiEndpoints.tradeBuy(uuid),
        data: {
          "outcome_slug": outcome,
          "cost_ghs": amount,
          "idempotency_key": idempotencyKey,
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
        ),
      );

      debugPrint("🔵 Buy response: ${response.data}");

      if (response.data is Map) {
        return BuyResponse.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
      return BuyResponse.networkFailure();
    } on DioException catch (e) {
      debugPrint("❌ Buy Dio error: ${e.response?.data}");
      final data = e.response?.data;
      if (data is Map) {
        return BuyResponse.fromJson(Map<String, dynamic>.from(data));
      }
      return BuyResponse.networkFailure(e.message);
    } catch (e) {
      debugPrint("❌ Buy exception: $e");
      return BuyResponse.networkFailure();
    }
  }
}