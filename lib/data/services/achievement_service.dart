import 'package:dio/dio.dart';
import '../../core/config/api_endpoint.dart';
import '../../core/network/dio_client.dart';
import '../model/achievement_model.dart';
import 'local_storage.dart';

/// Fetches the per-user achievement board from GET /achievement-levels.
class AchievementService {
  static Future<List<AchievementModel>> getAchievements() async {
    try {
      final token = LocalStorage.getToken();
      final res = await DioClient.instance.get(
        ApiEndpoints.achievementLevels,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
        ),
      );

      if (res.statusCode == 200 &&
          res.data is Map &&
          res.data['status'] == true) {
        final List list = (res.data['data'] as List?) ?? const [];
        return list
            .whereType<Map>()
            .map((e) => AchievementModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}
