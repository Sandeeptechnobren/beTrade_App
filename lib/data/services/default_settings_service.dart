import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../core/config/api_endpoint..dart';
import '../../core/network/dio_client.dart';
import '../model/default_settings_model.dart';
import 'local_storage.dart';

/// Dio client for `/userDefaultSettings/*`.
class DefaultSettingsService {
  /// GET `/userDefaultSettings/list`.
  /// Returns the parsed model, or `null` on any failure.
  /// This function is a static method in Dart that returns a Future containing a DefaultSettingsModel
  /// or null.
  static Future<DefaultSettingsModel?> getSettings() async {
    try {
      final token = LocalStorage.getToken();
      final response = await DioClient.instance.get(
        ApiEndpoints.userDefaultSettingsList,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
        ),
      );

      debugPrint(
          "🔵 DefaultSettings GET status=${response.statusCode}; body=${response.data}");

      if (response.statusCode == 200) {
        final decoded = response.data;
        if (decoded is Map && decoded['status'] == true) {
          final data = decoded['data'];
          if (data is Map) {
            final parsed = DefaultSettingsModel.fromJson(
              Map<String, dynamic>.from(data),
            );
            debugPrint(
                "✅ DefaultSettings GET success: min=${parsed.minDefaultAmount}, max=${parsed.maxDefaultAmount}");
            return parsed;
          }
          debugPrint("❌ DefaultSettings GET: 'data' is not a Map: $data");
          return null;
        }
        final msg = (decoded is Map ? decoded['message'] : null) ??
            "unknown server error";
        debugPrint("❌ DefaultSettings GET (server status=false): $msg");
        return null;
      }

      debugPrint(
          "❌ DefaultSettings GET failed (HTTP ${response.statusCode}): ${response.data}");
      return null;
    } on DioException catch (e) {
      debugPrint("❌ DefaultSettings GET DioException: ${e.message}; "
          "code=${e.response?.statusCode}; response=${e.response?.data}");
      return null;
    } catch (e, stack) {
      debugPrint("❌ DefaultSettings GET exception: $e");
      debugPrint("$stack");
      return null;
    }
  }

  /// PUT `/userDefaultSettings/list` with `{min_default_amount: <int>}`
  /// to save the user-controlled default amount. Max amount is
  /// admin-controlled and cannot be sent by the client.
  /// Returns true on `status: true` from the backend.
  static Future<bool> updateDefaultAmount(int amount) async {
    debugPrint("🔵 DefaultSettings PUT → min_default_amount=$amount");

    try {
      final token = LocalStorage.getToken();
      if (token == null || token.isEmpty) {
        debugPrint("❌ DefaultSettings PUT aborted: no auth token");
        return false;
      }

      final response = await DioClient.instance.put(
        ApiEndpoints.userDefaultSettingsList,
        data: {
          "min_default_amount": amount,
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
        ),
      );

      debugPrint(
          "🔵 DefaultSettings PUT response: code=${response.statusCode}; body=${response.data}");

      if (response.statusCode == 200) {
        final decoded = response.data;
        if (decoded is Map && decoded['status'] == true) {
          debugPrint("✅ DefaultSettings PUT success: min=$amount");
          return true;
        }
        final msg = (decoded is Map ? decoded['message'] : null) ??
            "unknown server error";
        debugPrint(
            "❌ DefaultSettings PUT failed (server status=false): $msg");
        return false;
      }

      debugPrint(
          "❌ DefaultSettings PUT failed (HTTP ${response.statusCode}): ${response.data}");
      return false;
    } on DioException catch (e) {
      debugPrint(
          "❌ DefaultSettings PUT DioException: ${e.message}; "
          "code=${e.response?.statusCode}; response=${e.response?.data}");
      return false;
    } catch (e, stack) {
      debugPrint("❌ DefaultSettings PUT exception: $e");
      debugPrint("$stack");
      return false;
    }
  }
}
