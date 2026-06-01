import 'package:dio/dio.dart';

import '../config/env_config.dart';
import 'retry_interceptor.dart';

/// Single shared Dio client.
///
/// - Holds the bearer token on its default `Authorization` header.
/// - Retries transient network failures for idempotent requests and gives a
///   clear offline message via [RetryInterceptor].
/// - Reads the base URL through [EnvConfig] (validated at read time) rather
///   than touching `dotenv` directly.
///
/// Use [instance] for JSON calls and [multipartInstance] for file uploads.
class DioClient {
  static final Dio _dio = _build();

  static Dio _build() {
    final dio = Dio(
      BaseOptions(
        baseUrl: EnvConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {"Accept": "application/json"},
      ),
    );
    dio.interceptors.add(RetryInterceptor(dio));
    return dio;
  }

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
        baseUrl: EnvConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {"Accept": "application/json"},
      ),
    );
    if (_dio.options.headers.containsKey("Authorization")) {
      multipartDio.options.headers["Authorization"] =
          _dio.options.headers["Authorization"];
    }
    multipartDio.interceptors.add(RetryInterceptor(multipartDio));
    return multipartDio;
  }
}
