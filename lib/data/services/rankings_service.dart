import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../core/config/env_config.dart';
import '../../core/network/dio_client.dart';
import '../model/ranking_entry.dart';

/// Service wrapper around `GET /api/rankings`.
///
/// The endpoint accepts:
///   - category: overall | profit | win_rate | hot_streak
///   - page: 1-based page index for the leaderboard list
///   - per_page: clamped to [10, 100], default 50
///
/// Returns null on any failure so callers can fall back to an empty
/// state without surface raw exceptions to the user.
class RankingsService {
  static Future<RankingResponse?> fetch({
    required String category,
    int page = 1,
    int perPage = 50,
  }) async {
    try {
      final response = await DioClient.instance.get(
        '${EnvConfig.baseUrl}/rankings',
        queryParameters: {
          'category': category,
          'page': page,
          'per_page': perPage,
        },
      );

      if (response.statusCode != 200) return null;
      final body = response.data;
      if (body is! Map || body['status'] != true) return null;
      final data = body['data'];
      if (data is! Map) return null;
      return RankingResponse.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (e) {
      debugPrint('RankingsService: dio error ${e.message}');
      return null;
    } catch (e) {
      debugPrint('RankingsService: unexpected $e');
      return null;
    }
  }
}
