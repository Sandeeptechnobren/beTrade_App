import 'package:dio/dio.dart';
import '../../core/config/api_endpoint.dart';
import '../../core/network/dio_client.dart';
import '../model/trade_model.dart';
import 'local_storage.dart';

class TradeService {
  static Future<List<TradeModel>> getTrades() async {
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
        ApiEndpoints.tradeList(1),
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

  static Future<List<TradeModel>> getAllTrades() async {
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
        ApiEndpoints.tradeList(1),
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
        ),
      );
      print("STATUS CODE: ${response.statusCode}");
      print("BODY: ${response.data}");
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
      print(
          "EXPLORE ERROR DioException: ${e.message}; response=${e.response?.data}");
      return [];
    } catch (e) {
      print("EXPLORE ERROR: $e");
      return [];
    }
  }
}
