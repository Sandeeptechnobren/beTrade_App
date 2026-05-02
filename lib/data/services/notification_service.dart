import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../core/config/api_endpoint..dart';
import '../../core/network/dio_client.dart';
import '../model/notification_preferences_model.dart';
import 'local_storage.dart';

/// Dio client for `/notificationPreferences`.
class NotificationService {
  /// GET `/notificationPreferences`.
  /// Returns parsed sections, or `[]` on any failure.
  static Future<List<NotificationSection>> getPreferences() async {
    try {
      final token = LocalStorage.getToken();
      final response = await DioClient.instance.get(
        ApiEndpoints.notificationPreferences,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
        ),
      );

      debugPrint(
          "NotificationPreferences GET status=${response.statusCode}; body=${response.data}");

      if (response.statusCode == 200) {
        final decoded = response.data;
        if (decoded is Map && decoded['status'] == true) {
          final list = (decoded['data'] as List?) ?? const [];
          return list
              .whereType<Map>()
              .map((e) =>
                  NotificationSection.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      }
      return [];
    } on DioException catch (e) {
      debugPrint(
          "❌ NotificationPreferences GET DioException: ${e.message}; response=${e.response?.data}");
      return [];
    } catch (e) {
      debugPrint("❌ NotificationPreferences GET error: $e");
      return [];
    }
  }

  /// PUT `/notificationPreferences` with `{title, status}` to flip a single
  /// preference on or off. Returns true on `status: true` from the backend.
  static Future<bool> updatePreference({
    required String title,
    required bool isActive,
  }) async {
    final statusValue = isActive ? "active" : "inactive";
    debugPrint(
        "🔵 NotificationPreferences PUT → title=\"$title\", status=$statusValue");

    try {
      final token = LocalStorage.getToken();
      if (token == null || token.isEmpty) {
        debugPrint("❌ NotificationPreferences PUT aborted: no auth token");
        return false;
      }

      final response = await DioClient.instance.put(
        ApiEndpoints.notificationPreferences,
        data: {
          "title": title,
          "status": statusValue,
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
        ),
      );

      debugPrint(
          "🔵 NotificationPreferences PUT response: code=${response.statusCode}, body=${response.data}");

      if (response.statusCode == 200) {
        final decoded = response.data;
        if (decoded is Map && decoded['status'] == true) {
          debugPrint(
              "✅ NotificationPreferences PUT success: \"$title\" → $statusValue");
          return true;
        }
        final msg = (decoded is Map ? decoded['message'] : null) ??
            "unknown server error";
        debugPrint(
            "❌ NotificationPreferences PUT failed (server status=false): $msg");
        return false;
      }

      debugPrint(
          "❌ NotificationPreferences PUT failed (HTTP ${response.statusCode}): ${response.data}");
      return false;
    } on DioException catch (e) {
      debugPrint(
          "❌ NotificationPreferences PUT DioException: ${e.message}; "
          "code=${e.response?.statusCode}; response=${e.response?.data}");
      return false;
    } catch (e, stack) {
      debugPrint("❌ NotificationPreferences PUT exception: $e");
      debugPrint("$stack");
      return false;
    }
  }
}
