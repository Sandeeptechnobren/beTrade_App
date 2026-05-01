import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import '../../core/config/api_endpoint..dart';
import '../../core/network/dio_client.dart';
import '../model/graph_model.dart';
import 'local_storage.dart';

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
          final isSuccess =
              responseData['status'] == true || responseData['success'] == true;

          // if (isSuccess) {
          //   final token = responseData['token'] ?? responseData['access_token'];
          //   if (token != null) {
          //     DioClient.setToken(token);
          //   }
          //   print(" OTP verified successfully!");
          //   return true;
          // }
          if (isSuccess) {
            final token = responseData['token'] ?? responseData['access_token'];
            if (token != null) {
              DioClient.setToken(token);
              await LocalStorage.setToken(token);
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
            return responseData['status'] == true ||
                responseData['success'] == true;
          }
        }
      } else {
        print("OTP ERROR: $e");
      }
      return false;
    }
  }

  Future<bool> completeSignup({
    required String phone,
    required String gender,
    required String firstName,
    required String lastName,
    required String email,
    required File image,
  }) async {
    try {
      String imagePath = image.path;
      String fileName = imagePath.split('/').last;
      if (!fileName.contains('.')) {
        fileName = '$fileName.jpg';
      }
      FormData formData = FormData.fromMap({
        'phone': phone,
        'gender': gender,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'avatar': await MultipartFile.fromFile(
          image.path,
          filename: 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: DioMediaType('image', 'jpeg'),
        ),
      });
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

  Future<bool?> verifyToken(String token) async {
    try {
      final response = await DioClient.instance.get(
        ApiEndpoints.verifyToken,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data['status'] == true;
      }

      return false; // real invalid
    } catch (e) {
      return null; // ⚠️ network issue
    }
  }
  //
  // Future<bool> verifyToken(String token) async {
  //   try {
  //     final response = await DioClient.instance.get(
  //       "https://api.buildacademy.io/projects/betrade/public/api/verify-token",
  //       options: Options(
  //         headers: {
  //           "Authorization": "Bearer $token",
  //         },
  //       ),
  //     );
  //     print("VERIFY TOKEN STATUS: ${response.statusCode}");
  //     print("VERIFY TOKEN RESPONSE: ${response.data}");
  //     if (response.statusCode == 200) {
  //       return response.data['status'] == true;
  //     }
  //     return false;
  //   } catch (e) {
  //     if (e is DioException) {
  //       print("VERIFY TOKEN ERROR: ${e.message}");
  //       print("VERIFY TOKEN RESPONSE: ${e.response?.data}");
  //     }
  //     return false;
  //   }
  // }

  Future<Map<String, dynamic>> login(String phone) async {
    try {
      final response = await DioClient.instance.post(
        ApiEndpoints.login,
        data: {"phone": phone},
      );

      final data = response.data;
      if (data is Map) {
        return {
          "success": data['status'] == true,
          "message": data['message'] ?? "Something went wrong",
        };
      }
      return {"success": false, "message": "Unexpected server response"};
    } catch (e) {
      if (e is DioException) {
        final resp = e.response?.data;
        final msg = (resp is Map ? resp['message'] : null) ??
            e.message ??
            "Server error";
        print("LOGIN ERROR: $msg");
        return {"success": false, "message": msg};
      }
      print("LOGIN ERROR: $e");
      return {"success": false, "message": "Server error"};
    }
  }

  Future<Map<String, dynamic>> verifyLoginOtp(String phone, String otp) async {
    try {
      final response = await DioClient.instance.post(
        ApiEndpoints.verifyLoginOtp,
        data: {"phone": phone, "otp": otp},
      );

      final data = response.data;
      if (data is Map) {
        final isSuccess = data['status'] == true || data['success'] == true;

        if (isSuccess) {
          final token = data['token'] ?? data['access_token'];
          if (token != null) {
            DioClient.setToken(token);
            await LocalStorage.setToken(token);
          }
        }

        final user = data['user'];
        final rawStatus =
            user is Map ? user['doc_upload_status'] : null;
        int docUploadStatus = 0;
        if (rawStatus is int) {
          docUploadStatus = rawStatus;
        } else if (rawStatus is String) {
          docUploadStatus = int.tryParse(rawStatus) ?? 0;
        } else if (rawStatus is bool) {
          docUploadStatus = rawStatus ? 1 : 0;
        }

        return {
          "success": isSuccess,
          "message": data['message'] ?? "Something went wrong",
          "data": user,
          "doc_upload_status": docUploadStatus,
        };
      }
      return {"success": false, "message": "Unexpected server response"};
    } catch (e) {
      if (e is DioException) {
        final resp = e.response?.data;
        final msg = (resp is Map ? resp['message'] : null) ??
            e.message ??
            "Server error";
        print("VERIFY LOGIN OTP ERROR: $msg");
        return {"success": false, "message": msg};
      }
      print("VERIFY LOGIN OTP ERROR: $e");
      return {"success": false, "message": "Server error"};
    }
  }
}
