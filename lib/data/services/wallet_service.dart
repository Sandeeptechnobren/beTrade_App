import 'package:dio/dio.dart';
import '../../core/config/api_endpoint.dart';
import '../../core/network/dio_client.dart';
import 'local_storage.dart';


class WalletService {
  static Future<Map<String, dynamic>?> getBalance() async {
    try {
      final token = LocalStorage.getToken();
      final response = await DioClient.instance.get(
        ApiEndpoints.wallet,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200 && response.data is Map) {
        final body = response.data as Map;
        if (body['status'] == true && body['data'] is Map) {
          print(response.data);
          return Map<String, dynamic>.from(body['data'] as Map);
        }
      }

      return null;
    } on DioException catch (e) {
      print('WalletService.getBalance DioException: ${e.message}; '
          'response=${e.response?.data}');
      return null;
    } catch (e) {
      print('WalletService.getBalance error: $e');
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> getTransactions({
    String? type,
    int page = 1,
  }) async {
    try {
      final token = LocalStorage.getToken();
      final response = await DioClient.instance.get(
        ApiEndpoints.walletTransactions(type: type, page: page),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200 && response.data is Map) {
        final body = response.data as Map;
        if (body['status'] == true && body['data'] is Map) {
          final data = body['data'] as Map;
          final items = data['items'];
          if (items is List) {
            return items
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList();
          }
        }
      }
      return [];
    } on DioException catch (e) {
      print('WalletService.getTransactions DioException: ${e.message}; '
          'response=${e.response?.data}');
      return [];
    } catch (e) {
      print('WalletService.getTransactions error: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> requestDeposit({
    required double amountGhs,
    String? method,
    String? msisdn,
  }) async {
    return _postIntent(
      url: ApiEndpoints.walletDeposit,
      payload: {
        'amount_ghs': amountGhs,
        if (method != null) 'method': method,
        if (msisdn != null) 'msisdn': msisdn,
      },
    );
  }


  static Future<Map<String, dynamic>> requestWithdraw({
    required double amountGhs,
    required String destination,
    String? msisdn,
  }) async {
    return _postIntent(
      url: ApiEndpoints.walletWithdraw,
      payload: {
        'amount_ghs': amountGhs,
        'destination': destination,
        if (msisdn != null) 'msisdn': msisdn,
      },
    );
  }

  static Future<Map<String, dynamic>> _postIntent({
    required String url,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final token = LocalStorage.getToken();
      final response = await DioClient.instance.post(
        url,
        data: payload,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );
      final body = response.data;
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          body is Map &&
          body['status'] == true) {
        return {
          'success': true,
          'message': body['message']?.toString() ?? 'Submitted.',
          'data': body['data'] is Map
              ? Map<String, dynamic>.from(body['data'] as Map)
              : null,
        };
      }
      return {
        'success': false,
        'message':
            (body is Map ? body['message']?.toString() : null) ?? 'Failed.',
      };
    } on DioException catch (e) {
      // Backend ships typed error codes for 402/422 paths.
      //   INSUFFICIENT_FUNDS / BELOW_MIN_AMOUNT / ABOVE_MAX_AMOUNT
      final body = e.response?.data;
      final code = body is Map ? body['code']?.toString() : null;
      final message = body is Map ? body['message']?.toString() : null;
      print('WalletService intent DioException: code=$code '
          'message=$message; response=$body');
      return {
        'success': false,
        'code': code,
        'message': message ?? e.message ?? 'Failed.',
      };
    } catch (e) {
      print('WalletService intent error: $e');
      return {
        'success': false,
        'message': 'Failed. Please try again.',
      };
    }
  }
}
