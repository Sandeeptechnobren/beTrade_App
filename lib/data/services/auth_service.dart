import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../core/config/api_endpoint.dart';
import '../../core/network/dio_client.dart';
import '../model/graph_model.dart';
import '../provider/default_amount_provider.dart';
import 'local_storage.dart';
import 'package:provider/provider.dart';

class AuthService {


  Future<Map<String, dynamic>> sendOtp(String phone) async {
    try {
      final response = await DioClient.instance.post(
        ApiEndpoints.register,
        data: {
          "phone": phone,
        },
      );

      print("STATUS: ${response.statusCode}");
      // Sensitive — body could contain a token or backend error
      // payload. Don't dump it to logcat in release builds.

      // SUCCESS
      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": "OTP sent successfully",
        };
      }
      // NUMBER ALREADY EXISTS
      else if (response.statusCode == 202) {
        return {
          "success": false,
          "message": "Phone number already registered! Please use another number .",
        };
      }
      // OTHER STATUS
      else {
        return {
          "success": false,
          "message": "Something went wrong",
        };
      }

    } on DioException catch (e) {
      print("ERROR: ${e.message}");
      // Response body redacted — may contain backend error fields
      // that echo OTPs or user metadata.

      return {
        "success": false,
        "message": e.response?.data["message"] ??
            "Server error occurred",
      };
    } catch (e) {
      print("ERROR: $e");

      return {
        "success": false,
        "message": "Unexpected error occurred",
      };
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
      // Response body redacted — the success response CONTAINS THE
      // BEARER TOKEN. Never dump in any environment.
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map) {
          final isSuccess =
              responseData['status'] == true || responseData['success'] == true;

          if (isSuccess) {
            final token = responseData['token'] ?? responseData['access_token'];
            if (token != null) {
              // Persist to disk BEFORE setting the in-memory Dio header. If
              // the app dies between these two lines, we'd rather be fully
              // logged out than have a header without persistence.
              await LocalStorage.setToken(token);
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
        // Response body redacted (potential OTP echo / token in 200
        // path masquerading as exception).

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
      // Response body redacted — contains the user profile + token.
      return response.statusCode == 200;
    } catch (e) {
      if (e is DioException) {
        print("Signup Error: ${e.message}");
        // Response body redacted — echoes form fields (PII).
      } else {
        print("Signup Error: $e");
      }
      return false;
    }
  }

  Future<Map<String, dynamic>> sendLoginOtp(String phone) async {
    try {
      final response = await DioClient.instance.post(
        ApiEndpoints.login,
        data: {
          "phone": phone,
        },
      );

      // ✅ SUCCESS CASE
      if (response.statusCode == 200 && response.data["status"] == true) {
        return {
          "status": true,
          "message": response.data["message"] ?? "OTP sent successfully",
        };
      }

      // ❌ API returned 200 but success: false (phone not registered)
      return {
        "status": false,
        "message": response.data["message"] ?? "Phone not registered",
      };

    } on DioException catch (e) {
      return {
        "status": false,
        "message": e.response?.data["message"] ?? "Server error occurred",
      };
    } catch (e) {
      return {
        "status": false,
        "message": "Unexpected error occurred",
      };
    }
  }

  Future<List<ChartData>> fetchChartData() async {
    try {
      final response = await DioClient.instance.get(
        ApiEndpoints.chart,
      );
      print("CHART DATA STATUS: ${response.statusCode}");
      // Body redacted to avoid noisy log dumps in production.
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((e) => ChartData.fromJson(e)).toList();
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      if (e is DioException) {
        print("CHART ERROR: ${e.message}");
        // Body redacted.
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
      // Logout response body redacted (may echo session info).
      print("Logout Status: ${response.statusCode}");
      return response.statusCode == 200;
    } catch (e) {
      if (e is DioException) {
        print("Logout Error: ${e.message}");
        // Body redacted.
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
    } on DioException catch (e) {
      // 401 = server rejected the token — treat as invalid, force re-login.
      if (e.response?.statusCode == 401) {
        return false;
      }
      // 404 = backend hasn't deployed /verify-token yet — fall through
      // to the network-issue branch so users aren't locked out during
      // a rolling deploy. Once the route ships everywhere this can be
      // tightened.
      return null; // ⚠️ network issue or transitional 404
    } catch (e) {
      return null; // ⚠️ network issue
    }
  }


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
            // Persist to disk BEFORE setting the in-memory Dio header. See
            // matching comment in verifyOtp above.
            await LocalStorage.setToken(token);
            DioClient.setToken(token);
          }
        }

        try {
          final fcmToken = await FirebaseMessaging.instance.getToken();
          if (fcmToken != null) {
            await saveFcmToken(fcmToken);
          }
        } catch (e) {
          print("FCM TOKEN ERROR: $e");
        }

        final user = data['user'];
        final rawStatus = user is Map ? user['doc_upload_status'] : null;
        int docUploadStatus = 0;
        if (rawStatus is int) {
          docUploadStatus = rawStatus;
        } else if (rawStatus is String) {
          docUploadStatus = int.tryParse(rawStatus) ?? 0;
        } else if (rawStatus is bool) {
          docUploadStatus = rawStatus ? 1 : 0;
        }

        // Persist so the KYC banner survives app close/reopen.
        if (isSuccess) {
          await LocalStorage.setDocUploadStatus(docUploadStatus);
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

  Future<bool> saveFcmToken(String token) async {
    try {
      final response = await DioClient.instance.post(
        ApiEndpoints.saveFcmToken,
        data: {
          "token": token,
        },
      );
      print("FCM SAVE STATUS: ${response.statusCode}");
      // FCM-save response body redacted.

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map) {
          return data['status'] == true;
        }
      }

      return false;
    } catch (e) {
      if (e is DioException) {
        print("FCM SAVE ERROR: ${e.message}");
        // Body redacted.
      } else {
        print("FCM SAVE ERROR: $e");
      }
      return false;
    }
  }

//   google
}
