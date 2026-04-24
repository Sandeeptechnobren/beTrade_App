// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../model/trade_model.dart';
// import 'local_storage.dart';
//
// class ExploreService {
//   static Future<List<TradeModel>> searchTrades(String query) async {
//     try {
//       String? token = LocalStorage.getToken();
//       final response = await http.get(
//         Uri.parse(
//           "https://api.easycoders.in/projects/betrade/public/api/trade/explore?search=$query",
//         ),
//         headers: {
//           "Authorization": "Bearer $token",
//           "Accept": "application/json",
//         },
//       );
//
//       print("Search Response :${response.body}");
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//
//         if (data['status'] == true) {
//           final List list = data['data']['all'];
//
//           return list.map((e) => TradeModel.fromJson(e)).toList();
//         } else {
//           throw Exception(data['message'] ?? "No data found");
//         }
//       } else {
//         throw Exception("Server error ${response.statusCode}");
//       }
//     } catch (e) {
//       print("ERROR IN SEARCH API: $e");
//       throw Exception("Failed to search trades: $e");
//     }
//   }
// }

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/trade_model.dart';
import 'local_storage.dart';

class ExploreService {
  static Future<List<TradeModel>> searchTrades(String query) async {
    try {
      String? token = LocalStorage.getToken();
      final response = await http.get(
        Uri.parse(
          "https://api.buildacademy.io/projects/betrade/public/api/trade/explore?search=$query",
        ),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );
      print("Search Response : ${response.body}");
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['status'] == true) {
          final List list = decoded['data'];
          return list
              .map((e) => TradeModel.fromJson(e))
              .toList();
        } else {
          throw Exception(decoded['message'] ?? "No data found");
        }
      } else {
        throw Exception("Server error ${response.statusCode}");
      }
    } catch (e) {
      print("ERROR IN SEARCH API: $e");
      throw Exception("Failed to search trades: $e");
    }
  }
}