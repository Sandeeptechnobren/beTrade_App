import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../../core/config/api_endpoint..dart';
import '../../core/network/dio_client.dart';
import 'local_storage.dart';

class HomeService {
  static Future<Map<String, dynamic>?> getQuote({
    required String uuid,
    required String outcome,
    required int amount,
  }) async {
    debugPrint("🔵 Quote POST → uuid=$uuid, outcome=$outcome, amount=$amount");

    try {
      final token = LocalStorage.getToken();
      if (token == null || token.isEmpty) {
        debugPrint("❌ No auth token");
        return null;
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

      if (response.statusCode == 200 &&
          response.data['status'] == true) {
        return response.data; // ✅ RETURN FULL DATA
      }

      return response.data;
    } on DioException catch (e) {
      debugPrint("❌ Dio error: ${e.response?.data}");
      return e.response?.data;
    } catch (e) {
      debugPrint("❌ Exception: $e");
      return null;
    }
  }
}