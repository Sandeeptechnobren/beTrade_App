import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import '../../core/config/api_endpoint.dart';
import '../../core/network/dio_client.dart';
import '../model/graph_model.dart';
import '../provider/default_amount_provider.dart';
import 'local_storage.dart';
import 'notification_services.dart';
import 'package:provider/provider.dart';

class AuthService {

  /// Dev helper: surfaces the OTP from a send-OTP API response so testers
  /// don't have to ask the backend. Many dev/staging backends echo the OTP
  /// in the response — if found it's printed prominently; otherwise the full
  /// response is logged (the OTP was likely sent via SMS only). Scans the
  /// common key names + a couple of nested spots.
  static void _logOtp(String where, dynamic data) {
    // Debug builds only — never surface the OTP in a release build.
    if (!kDebugMode) return;
    try {
      Object? pick(dynamic m) => (m is Map)
          ? (m['otp'] ??
              m['code'] ??
              m['otp_code'] ??
              m['OTP'] ??
              m['verification_code'])
          : null;
      final otp = pick(data) ??
          (data is Map ? pick(data['data']) : null) ??
          (data is Map ? pick(data['user']) : null);
      if (otp != null) {
        debugPrint("🔑🔑🔑 [$where] OTP = $otp 🔑🔑🔑");
      } else {
        debugPrint("🔑 [$where] No OTP field in response (likely SMS-only). "
            "Full response: $data");
      }
    } catch (e) {
      debugPrint("🔑 [$where] OTP log error: $e");
    }
  }

  Future<Map<String, dynamic>> sendOtp(String phone) async {
    try {
      final response = await DioClient.instance.post(
        ApiEndpoints.register,
        data: {
          "phone": phone,
        },
      );

      print("STATUS: ${response.statusCode}");
      print("RESPONSE: ${response.data}");
      _logOtp("Signup", response.data);

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
      print("RESPONSE: ${e.response?.data}");

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
      print("OTP VERIFY RESPONSE: ${response.data}");
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

  /// POST /api/complete-profile (multipart).
  ///
  /// Backend now mints a Sanctum token on success — we persist it the
  /// same way verifyLoginOtp does (disk first, then Dio header) so the
  /// new user lands on MainScreen already authenticated. No redundant
  /// trip back to /api/login afterwards.
  ///
  /// Returns a typed envelope rather than a bare bool so callers can
  /// surface the backend message on failure ("Phone number already
  /// registered", "OTP expired", etc.) instead of a generic snackbar.
  Future<Map<String, dynamic>> completeSignup({
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

      final data = response.data;
      if (response.statusCode == 200 && data is Map) {
        final isSuccess = data['status'] == true || data['success'] == true;
        if (isSuccess) {
          // Persist the Sanctum token disk-first, header-second — same
          // ordering used in verifyLoginOtp. Survives an app kill between
          // the two assignments because disk wins.
          final token = data['token'] ?? data['access_token'];
          if (token != null) {
            await LocalStorage.setToken(token.toString());
            DioClient.setToken(token.toString());
          }

          // Register the FCM token best-effort. Failures here don't break
          // the signup flow — push notifications just won't reach the
          // user until the next app open.
          try {
            final fcmToken = await FirebaseMessaging.instance.getToken();
            if (fcmToken != null) {
              await saveFcmToken(fcmToken);
            }
          } catch (e) {
            debugPrint("FCM token registration after signup failed: $e");
          }

          // Mirror verifyLoginOtp's doc_upload_status persistence so the
          // KYC reminder banner on MainScreen survives an app restart.
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
          await LocalStorage.setDocUploadStatus(docUploadStatus);

          return {
            "success": true,
            "message": data['message'] ?? "Signup successful",
            "data": user,
            "doc_upload_status": docUploadStatus,
          };
        }
        // 200 with status:false — backend rejected for a business reason
        // (e.g. email already taken). Surface the backend's message.
        return {
          "success": false,
          "message": data['message'] ?? "Signup failed",
        };
      }

      return {
        "success": false,
        "message": "Unexpected server response",
      };
    } on DioException catch (e) {
      final resp = e.response?.data;
      final msg = (resp is Map ? resp['message'] : null) ??
          e.message ??
          "Server error";
      debugPrint("Signup error: $msg");
      return {"success": false, "message": msg.toString()};
    } catch (e) {
      debugPrint("Signup error: $e");
      return {"success": false, "message": "Unexpected error during signup"};
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
      _logOtp("Login", response.data);

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
      _logOtp("Login", response.data);

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
      print("FCM SAVE RESPONSE: ${response.data}");

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
        print("FCM SAVE RESPONSE: ${e.response?.data}");
      } else {
        print("FCM SAVE ERROR: $e");
      }
      return false;
    }
  }

  /// POSTs a verified social-auth credential (currently Apple) to the
  /// backend. Mirrors [verifyLoginOtp] exactly:
  ///   - persists the returned JWT to disk BEFORE setting the in-memory
  ///     Dio header (so a crash between the two leaves us logged-out,
  ///     not header-only),
  ///   - parses `doc_upload_status` into an int and saves it to
  ///     [LocalStorage] so the KYC banner survives an app relaunch,
  ///   - returns the same `{success, message, data, doc_upload_status}`
  ///     shape so callers can reuse the OTP success path.
  ///
  /// FCM token is included in the request body (per the agreed contract)
  /// so the backend can register push at the same moment it mints the
  /// JWT — that's why we skip the separate /fcm/save-token call that
  /// verifyLoginOtp makes.
  ///
  /// `provider` is the literal string the backend expects, e.g. "apple".
  /// `email`/`firstName`/`lastName` are nullable because Apple only
  /// returns them on the FIRST sign-in for an app — subsequent sign-ins
  /// pass null. The backend identifies returning users via the
  /// identity-token's `sub` claim, so these fields are creation-only
  /// hints, not authentication material.
  Future<Map<String, dynamic>> socialLogin({
    required String provider,
    required String identityToken,
    required String authorizationCode,
    String? email,
    String? firstName,
    String? lastName,
  }) async {
    try {
      final fcmToken = await NotificationService.getFcmToken();

      final response = await DioClient.instance.post(
        ApiEndpoints.socialLogin,
        data: {
          "provider": provider,
          "identity_token": identityToken,
          "authorization_code": authorizationCode,
          "fcm_token": fcmToken ?? "",
          "device_type": Platform.isIOS ? "ios" : "android",
          if (email != null) "email": email,
          if (firstName != null) "first_name": firstName,
          if (lastName != null) "last_name": lastName,
        },
      );

      print("SOCIAL LOGIN STATUS: ${response.statusCode}");
      print("SOCIAL LOGIN RESPONSE: ${response.data}");

      final data = response.data;
      if (data is Map) {
        final isSuccess = data['status'] == true || data['success'] == true;

        if (isSuccess) {
          final token = data['token'] ?? data['access_token'];
          if (token != null) {
            await LocalStorage.setToken(token);
            DioClient.setToken(token);
          }
        }

        // Same defensive parse as verifyLoginOtp — backend has been seen
        // to return doc_upload_status as int, string, or bool.
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
        print("SOCIAL LOGIN ERROR: $msg");
        return {"success": false, "message": msg};
      }
      print("SOCIAL LOGIN ERROR: $e");
      return {"success": false, "message": "Server error"};
    }
  }

  /// Continue-with-Google — exchanges a Google `id_token` for the app JWT.
  /// Mirrors [socialLogin]'s token-store + `doc_upload_status` parse exactly:
  ///   - persists the returned JWT to disk BEFORE setting the in-memory Dio
  ///     header (crash between the two leaves us logged-out, not header-only),
  ///   - parses `doc_upload_status` (int/String/bool) and saves it to
  ///     [LocalStorage] so the KYC banner survives an app relaunch.
  ///
  /// `needs_phone` tells the caller whether the Google account had no phone
  /// on file — the UI then routes to the attach-phone step.
  Future<Map<String, dynamic>> loginWithGoogle(String idToken) async {
    try {
      final response = await DioClient.instance.post(
        ApiEndpoints.loginWithGoogle,
        data: {
          "id_token": idToken,
        },
      );

      print("GOOGLE LOGIN STATUS: ${response.statusCode}");
      print("GOOGLE LOGIN RESPONSE: ${response.data}");

      final data = response.data;
      if (data is Map) {
        final isSuccess = data['status'] == true || data['success'] == true;

        if (isSuccess) {
          final token = data['token'] ?? data['access_token'];
          if (token != null) {
            await LocalStorage.setToken(token);
            DioClient.setToken(token);
          }
        }

        // Same defensive parse as socialLogin — backend has been seen to
        // return doc_upload_status as int, string, or bool.
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

        if (isSuccess) {
          await LocalStorage.setDocUploadStatus(docUploadStatus);
        }

        return {
          "success": isSuccess,
          "message": data['message'] ?? "Something went wrong",
          "needs_phone": data['needs_phone'] == true,
          "doc_upload_status": docUploadStatus,
        };
      }
      return {
        "success": false,
        "message": "Unexpected server response",
        "needs_phone": false,
        "doc_upload_status": 0,
      };
    } catch (e) {
      if (e is DioException) {
        final resp = e.response?.data;
        final msg = (resp is Map ? resp['message'] : null) ??
            e.message ??
            "Server error";
        print("GOOGLE LOGIN ERROR: $msg");
        return {
          "success": false,
          "message": msg,
          "needs_phone": false,
          "doc_upload_status": 0,
        };
      }
      print("GOOGLE LOGIN ERROR: $e");
      return {
        "success": false,
        "message": "Server error",
        "needs_phone": false,
        "doc_upload_status": 0,
      };
    }
  }

  /// Sends an OTP to [phone] so a Google-authenticated user can attach a
  /// phone number to their account. Bearer token is already set on
  /// [DioClient] by [loginWithGoogle]. Returns `{success, message}`.
  Future<Map<String, dynamic>> attachPhone(String phone) async {
    try {
      final response = await DioClient.instance.post(
        ApiEndpoints.attachPhone,
        data: {
          "phone": phone,
        },
      );

      print("ATTACH PHONE STATUS: ${response.statusCode}");
      print("ATTACH PHONE RESPONSE: ${response.data}");
      _logOtp("Google attach-phone", response.data);

      final data = response.data;
      if (data is Map) {
        final isSuccess = data['status'] == true || data['success'] == true;
        return {
          "success": isSuccess,
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
        print("ATTACH PHONE ERROR: $msg");
        return {"success": false, "message": msg};
      }
      print("ATTACH PHONE ERROR: $e");
      return {"success": false, "message": "Server error"};
    }
  }

  /// Verifies the OTP sent by [attachPhone] and finalises the phone attach.
  /// Bearer token already set on [DioClient]. Returns `{success, message}`.
  Future<Map<String, dynamic>> verifyAttachPhone(
      String phone, String otp) async {
    try {
      final response = await DioClient.instance.post(
        ApiEndpoints.verifyAttachPhone,
        data: {
          "phone": phone,
          "otp": otp,
        },
      );

      print("VERIFY ATTACH PHONE STATUS: ${response.statusCode}");
      print("VERIFY ATTACH PHONE RESPONSE: ${response.data}");

      final data = response.data;
      if (data is Map) {
        final isSuccess = data['status'] == true || data['success'] == true;
        return {
          "success": isSuccess,
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
        print("VERIFY ATTACH PHONE ERROR: $msg");
        return {"success": false, "message": msg};
      }
      print("VERIFY ATTACH PHONE ERROR: $e");
      return {"success": false, "message": "Server error"};
    }
  }

//   google
}
