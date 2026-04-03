import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/category_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/category_model.dart';
import 'local_storage.dart'; // 🔥 important

class CategoryService {
  static Future<List<CategoryModel>> getCategories() async {
    try {
      String? token = LocalStorage.getToken(); // 🔥 token le

      final response = await http.get(
        Uri.parse("https://api.easycoders.in/projects/betrade/public/api/trade/categories-list"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token", // 🔥 MOST IMPORTANT
        },
      );

      print("TOKEN: $token");
      print("STATUS CODE: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == true) {
          List list = data['data'];
          return list.map((e) => CategoryModel.fromJson(e)).toList();
        }
      } else {
        print("SERVER ERROR: ${response.statusCode}");
      }
    } catch (e) {
      print("API ERROR: $e");
    }

    return [];
  }
}