import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../core/config/api_endpoint.dart';
import '../../core/network/dio_client.dart';
import '../model/rankings_response.dart';
import 'local_storage.dart';

/// Dio client for `/api/rankings`.
class RankingsService {
  /// GET `/api/rankings?category=…&page=…&per_page=…`.
  /// Returns the parsed envelope, or `null` on any failure — the
  /// provider distinguishes "no result" from a failure via its own
  /// loaded/error flags.
  static Future<RankingsResponse?> fetch({
    required String category,
    int page = 1,
    int perPage = 25,
  }) async {
    try {
      final token = LocalStorage.getToken();
      final response = await DioClient.instance.get(
        ApiEndpoints.rankings(
            category: category, page: page, perPage: perPage),
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        }),
      );

      if (response.statusCode != 200) {
        debugPrint(
            '❌ Rankings GET HTTP ${response.statusCode}: ${response.data}');
        return null;
      }
      final data = response.data;
      if (data is! Map || data['status'] != true) {
        debugPrint(
            '❌ Rankings GET status=false: '
            '${data is Map ? data['message'] : "non-map body"}');
        return null;
      }
      return RankingsResponse.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (e) {
      debugPrint(
          '❌ Rankings GET DioException: ${e.message}; '
          'code=${e.response?.statusCode}; response=${e.response?.data}');
      return null;
    } catch (e, stack) {
      debugPrint('❌ Rankings GET exception: $e');
      debugPrint('$stack');
      return null;
    }
  }
}
