import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import '../../core/config/api_endpoint..dart';
import '../../core/network/dio_client.dart';
import '../model/graph_model.dart';

class AuthService {

  // Future<bool> sendOtp(String phone) async {
  //   try {
  //     final res = await http.post(
  //       Uri.parse(ApiEndpoints.register),
  //       headers: {
  //         "Accept": "application/json",
  //         "Content-Type": "application/json",
  //       },
  //       body: jsonEncode({
  //         "phone": phone,
  //       }),
  //     );
  //
  //     print("STATUS: ${res.statusCode}");
  //     print("RESPONSE: ${res.body}");
  //
  //     return res.statusCode == 200;
  //   } catch (e) {
  //     print("ERROR: $e");
  //     return false;
  //   }
  // }
  Future<bool> sendOtp(String phone) async {
    try {
      final response = await DioClient.instance.post(
        ApiEndpoints.register,
        data: {
          "phone": phone,
        },
      );

      print("STATUS: ${response.statusCode}");
      print("RESPONSE: ${response.data}");

      return response.statusCode == 200;
    } catch (e) {
      if (e is DioException) {
        print("ERROR: ${e.message}");
        print("RESPONSE: ${e.response?.data}");
      } else {
        print("ERROR: $e");
      }
      return false;
    }
  }

Future<bool> verifyOtp(String phone, String otp) async {
  try {
    final response = await DioClient.instance.post(
      ApiEndpoints.verifyOtp,
      data: {
        "phone": phone,
        "otp": otp,
      },
    );

    print("OTP VERIFY STATUS: ${response.statusCode}");
    print("OTP VERIFY RESPONSE: ${response.data}");
    if (response.statusCode == 200) {
      final responseData = response.data;
      if (responseData is Map) {
        final isSuccess = responseData['status'] == true ||
            responseData['success'] == true;

        if (isSuccess) {
          final token = responseData['token'] ?? responseData['access_token'];
          if (token != null) {
            DioClient.setToken(token);
          }
          print(" OTP verified successfully!");
          return true;
        } else {
          print("OTP verification failed: ${responseData['message']}");
          return false;
        }
      }
      return false;
    }

    return false;
  } catch (e) {
    if (e is DioException) {
      print("OTP ERROR: ${e.message}");
      print("OTP ERROR RESPONSE: ${e.response?.data}");

      // Even if status code is 200, check response data
      if (e.response?.statusCode == 200 && e.response?.data != null) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          return responseData['status'] == true || responseData['success'] == true;
        }
      }
    } else {
      print("OTP ERROR: $e");
    }
    return false;
  }
}

  // Future<bool> completeSignup({
  //   required String phone,
  //   required String gender,
  //   required String firstName,
  //   required String lastName,
  //   required File image,
  // }) async {
  //   try {
  //     var request = http.MultipartRequest(
  //       'POST',
  //       Uri.parse(ApiEndpoints.completeProfile),
  //     );
  //
  //     request.fields['phone'] = phone;
  //     request.fields['gender'] = gender;
  //     request.fields['first_name'] = firstName;
  //     request.fields['last_name'] = lastName;
  //
  //     request.files.add(
  //       await http.MultipartFile.fromPath('avatar', image.path),
  //     );
  //
  //     var response = await request.send();
  //
  //     return response.statusCode == 200;
  //   } catch (e) {
  //     print("Signup Error: $e");
  //     return false;
  //   }
  // }

  Future<bool> completeSignup({
    required String phone,
    required String gender,
    required String firstName,
    required String lastName,
    required File image,
  }) async {
    try {
      // Create FormData object
      FormData formData = FormData.fromMap({
        'phone': phone,
        'gender': gender,
        'first_name': firstName,
        'last_name': lastName,
        'avatar': await MultipartFile.fromFile(image.path),
      });

      // Use multipartInstance from your DioClient
      final response = await DioClient.multipartInstance.post(
        ApiEndpoints.completeProfile,
        data: formData,
      );

      print("SIGNUP STATUS: ${response.statusCode}");
      print("SIGNUP RESPONSE: ${response.data}");

      return response.statusCode == 200;
    } catch (e) {
      if (e is DioException) {
        print("Signup Error: ${e.message}");
        print("Signup Error Response: ${e.response?.data}");
      } else {
        print("Signup Error: $e");
      }
      return false;
    }
  }

  // Future<List<ChartData>> fetchChartData() async {
  //   try {
  //     final response = await http.get(
  //       Uri.parse(ApiEndpoints.chart), // ✅ FIXED
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final List data = jsonDecode(response.body);
  //       return data.map((e) => ChartData.fromJson(e)).toList();
  //     } else {
  //       throw Exception("Failed to load data");
  //     }
  //   } catch (e) {
  //     throw Exception("Chart Error: $e");
  //   }
  // }

  Future<List<ChartData>> fetchChartData() async {
    try {
      final response = await DioClient.instance.get(
        ApiEndpoints.chart,
      );

      print("CHART DATA STATUS: ${response.statusCode}");
      print("CHART DATA RESPONSE: ${response.data}");

      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((e) => ChartData.fromJson(e)).toList();
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      if (e is DioException) {
        print("CHART ERROR: ${e.message}");
        print("CHART ERROR RESPONSE: ${e.response?.data}");
        throw Exception("Chart Error: ${e.message}");
      } else {
        print("CHART ERROR: $e");
        throw Exception("Chart Error: $e");
      }
    }
  }

  // static Future<bool> logout(String token) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse(ApiEndpoints.logout),
  //       headers: {
  //         "Authorization": "Bearer $token",
  //         "Accept": "application/json",
  //       },
  //     );
  //
  //     print("Logout Response: ${response.body}");
  //
  //     return response.statusCode == 200;
  //   } catch (e) {
  //     print("Logout Error: $e");
  //     return false;
  //   }
  // }
  static Future<bool> logout(String token) async {
    try {
      final response = await DioClient.instance.post(
        ApiEndpoints.logout,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      print("Logout Response: ${response.data}");
      print("Logout Status: ${response.statusCode}");

      return response.statusCode == 200;
    } catch (e) {
      if (e is DioException) {
        print("Logout Error: ${e.message}");
        print("Logout Error Response: ${e.response?.data}");
      } else {
        print("Logout Error: $e");
      }
      return false;
    }
  }
}