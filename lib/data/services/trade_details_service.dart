import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import 'local_storage.dart';

class TradeDetailService {
  static Future<Map<String, dynamic>?> getTradeDetail(String uuid) async {
    try {
      String? token = LocalStorage.getToken();
      final url =
          "https://api.buildacademy.io/projects/betrade/public/api/trade/view/$uuid";
      print(" API HIT: $url");
      final response = await DioClient.instance.get(
        url,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
        ),
      );

      print("STATUS CODE: ${response.statusCode}");
      print(" RESPONSE: ${response.data}");

      if (response.statusCode == 200) {
        final json = response.data;
        if (json is Map && json["data"] is Map) {
          return Map<String, dynamic>.from(json["data"] as Map);
        }
      } else {
        print(" API ERROR");
      }
    } on DioException catch (e) {
      print(" DioException: ${e.message}; response=${e.response?.data}");
    } catch (e) {
      print(" EXCEPTION: $e");
    }

    return null;
  }
}
