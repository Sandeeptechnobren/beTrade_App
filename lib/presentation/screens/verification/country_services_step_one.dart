// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../../../data/model/country_model.dart';
//
// class CountryService {
//   static const String url =
//       "https://api.easycoders.in/projects/betrade/public/api/countries";
//
//   static Future<List<CountryModel>> fetchCountries() async {
//     try {
//       final response = await http.get(Uri.parse(url));
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//
//         final List list = data['data'];
//         print(response.body);
//         return list.map((e) => CountryModel.fromJson(e)).toList();
//       } else {
//         throw Exception("Failed to load countries");
//       }
//     } catch (e) {
//       throw Exception("Error: $e");
//     }
//   }
// }
//
//


import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/network/dio_client.dart';
import '../../../data/model/country_model.dart';

class CountryService {
  static const String url =
      "https://api.buildacademy.io/projects/betrade/public/api/countries";

  static Future<List<CountryModel>> fetchCountries() async {
    try {
      final response = await DioClient.instance.get(
        url,
        options: Options(
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode != 200) {
        debugPrint(" API Error: ${response.statusCode}");
        return [];
      }

      final dynamic data = response.data;
      if (data == null) {
        debugPrint("Response data is null");
        return [];
      }

      final List<CountryModel> countries = _safeParseCountries(data);

      debugPrint(" Loaded ${countries.length} countries");
      return countries;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        debugPrint("Connection timeout. Please check your internet.");
      } else {
        debugPrint(
            "fetchCountries DioException: ${e.message}; response=${e.response?.data}");
      }
      return [];
    } catch (e, stackTrace) {
      debugPrint("fetchCountries error: $e");
      debugPrint("StackTrace: $stackTrace");
      return [];
    }
  }

  static List<CountryModel> _safeParseCountries(dynamic data) {
    try {
      if (data is! Map) {
        debugPrint(" Response is not a Map");
        return [];
      }

      // Get data['data']
      final dataList = data['data'];
      if (dataList == null) {
        debugPrint("data['data'] is null");
        return [];
      }
      if (dataList is! List) {
        debugPrint("data['data'] is not a List");
        return [];
      }
      final List<CountryModel> countries = [];
      for (final item in dataList) {
        final country = _safeParseCountry(item);
        if (country != null) {
          countries.add(country);
        }
      }

      return countries;
    } catch (e) {
      debugPrint(" Parse countries error: $e");
      return [];
    }
  }

  static CountryModel? _safeParseCountry(dynamic item) {
    try {
      if (item is! Map<String, dynamic>) {
        debugPrint("Country item is not a Map");
        return null;
      }
      return CountryModel.fromJson(item);
    } catch (e) {
      debugPrint("Parse country error: $e");
      return null;
    }
  }
}
