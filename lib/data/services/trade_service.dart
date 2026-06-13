import 'package:dio/dio.dart';
import '../../core/config/api_endpoint.dart';
import '../../core/network/dio_client.dart';
import '../model/trade_model.dart';
import 'local_storage.dart';

/// One page of Explore results plus the pagination cursor, so the
/// provider knows whether a "load more" page exists.
class ExploreResult {
  final List<TradeModel> items;
  final int currentPage;
  final int lastPage;

  ExploreResult({
    required this.items,
    required this.currentPage,
    required this.lastPage,
  });

  bool get hasMore => currentPage < lastPage;
}

class TradeService {
  static Future<List<TradeModel>> getTrades({int page = 1}) async {
    try {
      String? token = LocalStorage.getToken();
      // final response = await http.get(
      //   Uri.parse(
      //     "https://api.easycoders.in/projects/betrade/public/api/trade/list?page=1",
      //   ),
      //   headers: {
      //     "Authorization": "Bearer $token",
      //     "Accept": "application/json",
      //   },
      // );
      final response = await DioClient.instance.get(
        ApiEndpoints.tradeList(page),
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
        ),
      );

      print("EXPLORE API HIT: ${response.statusCode}");
      if (response.statusCode == 200) {
        final decoded = response.data;

        if (decoded is Map && decoded['status'] == true) {
          final List list = decoded['data']['items'];
          return list.map((e) => TradeModel.fromJson(e)).toList();
        } else {
          throw Exception("API status false");
        }
      } else {
        throw Exception("Failed to load trades");
      }
    } on DioException catch (e) {
      print("ERROR DioException: ${e.message}; response=${e.response?.data}");
      return [];
    } catch (e) {
      print("ERROR: $e");
      return [];
    }
  }

  /// Canonical Explore fetch — base list + search + category filter +
  /// pagination, all via GET /trade/list. Throws on transport/parse
  /// failure so the provider can surface a friendly error state (the
  /// older sentinel-[] methods above couldn't distinguish error from
  /// genuinely-empty).
  static Future<ExploreResult> fetchExplore({
    int page = 1,
    String? search,
    String? categoryUuid,
    String? sort,
  }) async {
    final token = LocalStorage.getToken();
    final response = await DioClient.instance.get(
      ApiEndpoints.tradeExplore(
        page: page,
        search: search,
        categoryUuid: categoryUuid,
        sort: sort,
      ),
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      ),
    );

    if (response.statusCode == 200 &&
        response.data is Map &&
        response.data['status'] == true) {
      final data = (response.data['data'] as Map?) ?? const {};
      final List list = (data['items'] as List?) ?? const [];
      final pag = (data['pagination'] as Map?) ?? const {};
      return ExploreResult(
        items: list
            .whereType<Map>()
            .map((e) => TradeModel.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        currentPage: (pag['current_page'] as int?) ?? page,
        lastPage: (pag['last_page'] as int?) ?? page,
      );
    }

    throw Exception("Failed to load markets (HTTP ${response.statusCode}).");
  }
}
