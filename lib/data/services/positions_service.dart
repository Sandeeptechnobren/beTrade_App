import 'package:dio/dio.dart';

import '../../core/config/api_endpoint.dart';
import '../../core/network/dio_client.dart';
import '../model/position_model.dart';
import 'local_storage.dart';

/// User-facing positions API client.
///
/// Backend (mounted under `actor.user`):
///   GET /api/positions               → list of open positions
///   GET /api/positions/{market_uuid} → both sides of one market
///
/// All P&L math is computed server-side; the client is a thin
/// rendering layer.
class PositionsService {
  /// Fetches positions for the authenticated user.
  ///
  /// [status] (P0-C, 2026-05-28):
  ///   - 'open'    → active positions (shares > 0). Default.
  ///   - 'settled' → closed positions (zeroed + settled_at set).
  ///                 Returns payout_ghs + realized_pnl_ghs per row.
  ///   - 'all'     → both, active first.
  ///
  /// Returns [] on failure.
  static Future<List<PositionModel>> getAll({String status = 'open'}) async {
    try {
      final token = LocalStorage.getToken();
      final response = await DioClient.instance.get(
        ApiEndpoints.positions,
        queryParameters: {'status': status},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200 && response.data is Map) {
        final body = response.data as Map;
        if (body['status'] == true && body['data'] is List) {
          return (body['data'] as List)
              .whereType<Map>()
              .map((m) =>
                  PositionModel.fromJson(Map<String, dynamic>.from(m)))
              .toList();
        }
      }
      return [];
    } on DioException catch (e) {
      print('PositionsService.getAll DioException: ${e.message}; '
          'response=${e.response?.data}');
      return [];
    } catch (e) {
      print('PositionsService.getAll error: $e');
      return [];
    }
  }

  /// Fetches both sides (yes + no) of a single market for the
  /// authenticated user. Side(s) the user doesn't hold come back
  /// with `shares: 0`. Returns null on failure / market-not-found.
  static Future<MarketPositionsModel?> getForMarket(String marketUuid) async {
    try {
      final token = LocalStorage.getToken();
      final response = await DioClient.instance.get(
        ApiEndpoints.positionForMarket(marketUuid),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200 && response.data is Map) {
        final body = response.data as Map;
        if (body['status'] == true && body['data'] is Map) {
          return MarketPositionsModel.fromJson(
              Map<String, dynamic>.from(body['data'] as Map));
        }
      }
      return null;
    } on DioException catch (e) {
      print('PositionsService.getForMarket DioException: ${e.message}; '
          'response=${e.response?.data}');
      return null;
    } catch (e) {
      print('PositionsService.getForMarket error: $e');
      return null;
    }
  }
}
