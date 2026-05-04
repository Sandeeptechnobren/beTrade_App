import 'package:dio/dio.dart';
import '../../core/config/api_endpoint.dart';
import '../../core/network/dio_client.dart';
import '../model/category_model.dart';
import 'local_storage.dart';

class CategoryService {
  static Future<List<CategoryModel>> getCategories() async {
    try {
      String? token = LocalStorage.getToken();
      final response = await DioClient.instance.get(
        ApiEndpoints.categories,
        options: Options(
          headers: {
            "Accept": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );

      print("TOKEN: $token");
      print("STATUS CODE: ${response.statusCode}");
      print("BODY: ${response.data}");

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['status'] == true) {
          List list = data['data'];
          return list.map((e) => CategoryModel.fromJson(e)).toList();
        }
      } else {
        print("SERVER ERROR: ${response.statusCode}");
      }
    } on DioException catch (e) {
      print("API DioException: ${e.message}; response=${e.response?.data}");
    } catch (e) {
      print("API ERROR: $e");
    }
    return [];
  }
}
