import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config/api_endpoint..dart';
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
      final response = await http.get(
        Uri.parse(ApiEndpoints.tradeList(1)), //
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      print("EXPLORE API HIT: ${response.statusCode}");
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded['status'] == true) {
          final List list = decoded['data']['items'];
          return list.map((e) => TradeModel.fromJson(e)).toList();
        } else {
          throw Exception("API status false");
        }
      } else {
        throw Exception("Failed to load trades");
      }
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
      final response = await http.get(
        Uri.parse(ApiEndpoints.tradeList(1)),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );
      print("STATUS CODE: ${response.statusCode}");
      print("BODY: ${response.body}");
      print("EXPLORE API HIT: ${response.statusCode}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['status'] == true) {
          final List list = decoded['data']['items'];
          return list.map((e) => TradeModel.fromJson(e)).toList();
        } else {
          throw Exception("API status false");
        }
      } else {
        throw Exception("Failed to load trades");
      }
    } catch (e) {
      print("EXPLORE ERROR: $e");
      return [];
    }
  }
}
