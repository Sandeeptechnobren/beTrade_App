import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../data/model/country_model.dart';

class CountryService {
  static const String url =
      "https://api.easycoders.in/projects/betrade/public/api/countries";

  static Future<List<CountryModel>> fetchCountries() async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final List list = data['data'];
        print(response.body);
        return list.map((e) => CountryModel.fromJson(e)).toList();
      } else {
        throw Exception("Failed to load countries");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }
}


