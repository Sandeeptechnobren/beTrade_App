
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get baseUrl {
    final url = dotenv.env['BASE_URL'];

    if (url == null || url.isEmpty) {
      throw Exception("BASE_URL not found in .env");
    }

    return url;
  }
}