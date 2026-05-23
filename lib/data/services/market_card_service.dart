import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../../core/config/api_endpoint.dart';
import '../../core/network/dio_client.dart';
import '../model/category_detail_model.dart';
import 'local_storage.dart';

class MarketCardService {

  static Future<MarketCardModel?> getTradeDetail(
      String uuid,
      ) async {

    try {

      String? token =
      LocalStorage.getToken();

      final url =
      ApiEndpoints.tradeDetail(uuid);

      debugPrint(
        "FINAL URL => $url",
      );

      final response =
      await DioClient.instance.get(

        url,

        options: Options(
          headers: {

            "Accept":
            "application/json",

            "Authorization":
            "Bearer $token",
          },
        ),
      );

      debugPrint(
        "STATUS CODE => ${response.statusCode}",
      );

      debugPrint(
        "BODY => ${response.data}",
      );

      if (response.statusCode == 200) {

        final data = response.data;

        if (data['success'] == true) {

          return MarketCardModel.fromJson(
            data['data'],
          );
        }
      }

    } on DioException catch (e) {

      debugPrint(
        "DIO ERROR => ${e.response?.data}",
      );

    } catch (e) {

      debugPrint(
        "ERROR => $e",
      );
    }

    return null;
  }
}