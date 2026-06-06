import 'package:dio/dio.dart';
import '../../core/config/api_endpoint.dart';
import '../../core/network/dio_client.dart';
import '../model/deposit_initiate_response.dart';
import 'local_storage.dart';


/// Typed envelope for the P0-A initiate endpoint so callers can branch
/// on `success` + `code` without re-decoding `Map<String, dynamic>`.
class DepositInitiateResult {
  final bool success;
  final DepositInitiateResponse? data;
  final String? message;
  final String? code; // backend typed codes: BELOW_MIN_AMOUNT, GATEWAY_UNAVAILABLE, ...

  const DepositInitiateResult({
    required this.success,
    this.data,
    this.message,
    this.code,
  });

  factory DepositInitiateResult.failure({String? message, String? code}) =>
      DepositInitiateResult(success: false, message: message, code: code);
}

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
    String? idempotencyKey,
  }) async {
    return _postIntent(
      url: ApiEndpoints.walletDeposit,
      payload: {
        'amount_ghs': amountGhs,
        if (method != null) 'method': method,
        if (msisdn != null) 'msisdn': msisdn,
        if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      },
    );
  }

  /// P0-A — gateway-backed deposit. Accepts a method-discriminated
  /// payload and returns a typed envelope including the gateway's
  /// channel-specific blob (`checkout_url`, `stk_push`, or
  /// `virtual_account`).
  ///
  /// [methodPayload] is the method-specific sub-block exactly as
  /// documented in `tasks/portfolio_deposit_flutter_bind_points.md` §2:
  ///   card:        { token, brand, last4, country }
  ///   mobile_money:{ provider:'mtn|telecel|airteltigo', msisdn:'+233...' }
  ///   bank_account:{ bank_code, account_number, account_name? }
  ///
  /// Failure returns `DepositInitiateResult.failure(code:..., message:...)`
  /// so the UI can map backend typed codes (`BELOW_MIN_AMOUNT`,
  /// `ABOVE_MAX_AMOUNT`, `GATEWAY_UNAVAILABLE`, `GATEWAY_NOT_CONFIGURED`,
  /// `INVALID_METHOD`) to user-readable strings.
  static Future<DepositInitiateResult> initiateDeposit({
    required double amountGhs,
    required String method,
    required Map<String, dynamic> methodPayload,
    required String idempotencyKey,
    bool savePaymentMethod = false,
  }) async {
    try {
      final token = LocalStorage.getToken();
      final body = <String, dynamic>{
        'amount_ghs': amountGhs,
        'method': method,
        'idempotency_key': idempotencyKey,
        'save_payment_method': savePaymentMethod,
        method: methodPayload, // 'card' / 'mobile_money' / 'bank_account'
      };

      final response = await DioClient.instance.post(
        ApiEndpoints.walletDepositInitiate,
        data: body,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      final data = response.data;
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data is Map &&
          data['status'] == true &&
          data['data'] is Map) {
        return DepositInitiateResult(
          success: true,
          data: DepositInitiateResponse.fromJson(
            Map<String, dynamic>.from(data['data'] as Map),
          ),
          message: data['message']?.toString(),
        );
      }
      return DepositInitiateResult.failure(
        message: data is Map ? data['message']?.toString() : null,
      );
    } on DioException catch (e) {
      final body = e.response?.data;
      final code = body is Map ? body['code']?.toString() : null;
      final message = body is Map ? body['message']?.toString() : null;
      print('WalletService.initiateDeposit DioException: code=$code '
          'message=$message; response=$body');
      return DepositInitiateResult.failure(
        message: message ?? e.message ?? 'Could not initiate deposit.',
        code: code,
      );
    } catch (e) {
      print('WalletService.initiateDeposit error: $e');
      return DepositInitiateResult.failure(
        message: 'Could not initiate deposit. Please try again.',
      );
    }
  }


  static Future<Map<String, dynamic>> requestWithdraw({
    required double amountGhs,
    required String destination,
    String? msisdn,
    String? idempotencyKey,
  }) async {
    return _postIntent(
      url: ApiEndpoints.walletWithdraw,
      payload: {
        'amount_ghs': amountGhs,
        'destination': destination,
        if (msisdn != null) 'msisdn': msisdn,
        if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
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
