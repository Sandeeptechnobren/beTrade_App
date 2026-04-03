// import 'dart:convert';
// import 'package:http/http.dart' as http;
//
// class TradeDetailService {
//   static Future<Map<String, dynamic>?> getTradeDetail(String uuid) async {
//     try {
//       final response = await http.get(
//         Uri.parse(
//           "https://api.easycoders.in/projects/betrade/public/api/trade/view/$uuid",
//         ),
//       );
//
//       if (response.statusCode == 200) {
//         final json = jsonDecode(response.body);
//         return json["data"];
//       } else {
//         print("API Error: ${response.statusCode}");
//       }
//     } catch (e) {
//       print("Error: $e");
//     }
//     return null;
//   }
// }

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'local_storage.dart';

class TradeDetailService {
  static Future<Map<String, dynamic>?> getTradeDetail(String uuid) async {
    try {
      String? token = LocalStorage.getToken();
      final url =
          "https://api.easycoders.in/projects/betrade/public/api/trade/view/$uuid";
      print("🔥 API HIT: $url");
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token", // ✅ FIX
          "Accept": "application/json",
        },
      );

      print("🔥 STATUS CODE: ${response.statusCode}");
      print("🔥 RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json["data"];
      } else {
        print("❌ API ERROR");
      }
    } catch (e) {
      print("❌ EXCEPTION: $e");
    }

    return null;
  }
}