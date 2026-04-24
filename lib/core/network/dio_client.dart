// import 'package:dio/dio.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
//
// class DioClient {
//   static final Dio _dio = Dio(
//     BaseOptions(
//       baseUrl: dotenv.env['BASE_URL'] ?? "",
//       connectTimeout: const Duration(seconds: 15),
//       receiveTimeout: const Duration(seconds: 15),
//       headers: {
//         "Accept": "application/json",
//       },
//     ),
//   );
//
//   static Dio get instance => _dio;
//   static void setToken(String token) {
//     _dio.options.headers["Authorization"] = "Bearer $token";
//   }
// }
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DioClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: dotenv.env['BASE_URL'] ?? "",
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        "Accept": "application/json",
      },
    ),
  );

  static Dio get instance => _dio;
  static void setToken(String token) {
    _dio.options.headers["Authorization"] = "Bearer $token";
  }

  static void removeToken() {
    _dio.options.headers.remove("Authorization");
  }

  static Dio get multipartInstance {
    final multipartDio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['BASE_URL'] ?? "",
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          "Accept": "application/json",
        },
      ),
    );
    if (_dio.options.headers.containsKey("Authorization")) {
      multipartDio.options.headers["Authorization"] = _dio.options.headers["Authorization"];
    }
    return multipartDio;
  }
}