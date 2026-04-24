import 'dart:convert';
import 'package:http/http.dart' as http;
import 'local_storage.dart';

class TradeDetailService {
  static Future<Map<String, dynamic>?> getTradeDetail(String uuid) async {
    try {
      String? token = LocalStorage.getToken();
      final url =
          "https://api.buildacademy.io/projects/betrade/public/api/trade/view/$uuid";
      print(" API HIT: $url");
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      print("STATUS CODE: ${response.statusCode}");
      print(" RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json["data"];
      } else {
        print(" API ERROR");
      }
    } catch (e) {
      print(" EXCEPTION: $e");
    }

    return null;
  }
}
