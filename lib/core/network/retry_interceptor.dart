import 'dart:async';

import 'package:dio/dio.dart';

import '../utils/app_logger.dart';
import 'connectivity_service.dart';

class RetryInterceptor extends Interceptor {
  RetryInterceptor(this._dio, {this.maxRetries = 2});

  final Dio _dio;
  final int maxRetries;

  static const Set<String> _retriableMethods = {'GET', 'HEAD'};

  bool _isTransient(DioException e) =>
      e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.sendTimeout ||
      e.type == DioExceptionType.connectionError;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!_isTransient(err)) return handler.next(err);
    final online = await ConnectivityService.isOnline();
    if (!online) {
      AppLogger.w('Network', 'Request while offline: ${err.requestOptions.path}');
      return handler.next(
        DioException(
          requestOptions: err.requestOptions,
          type: err.type,
          error: err.error,
          message:
              'No internet connection. Please check your network and try again.',
        ),
      );
    }

    final method = err.requestOptions.method.toUpperCase();
    final attempt = (err.requestOptions.extra['retry_attempt'] as int?) ?? 0;

    if (_retriableMethods.contains(method) && attempt < maxRetries) {
      final next = attempt + 1;
      AppLogger.w(
        'Network',
        'Retry $next/$maxRetries ${err.requestOptions.path} (${err.type.name})',
      );
      await Future<void>.delayed(Duration(milliseconds: 400 * next));
      try {
        final options = err.requestOptions..extra['retry_attempt'] = next;
        final response = await _dio.fetch<dynamic>(options);
        return handler.resolve(response);
      } on DioException catch (e) {
        return handler.next(e);
      }
    }

    return handler.next(err);
  }
}
