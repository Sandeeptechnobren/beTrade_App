import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../services/apple_auth_service.dart';
import '../services/google_auth_service.dart';
import '../services/auth_service.dart';
import '../services/notification_services.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool isLoading = false;

  Future<Map<String, dynamic>> sendLoginOtp(String phone) async {
    isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.sendLoginOtp(phone);

      debugPrint("SEND OTP API RESPONSE => $result");

      return {
        "status": result["status"] == true,
        "message": result["message"] ?? "OTP sent",
      };
    } catch (e) {
      debugPrint("SEND OTP ERROR => $e");

      return {
        "status": false,
        "message": "Something went wrong",
      };
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.verifyLoginOtp(phone, otp);

      return {
        "success": result["success"] == true,
        "message": result["message"] ?? "Verified",
        "data": result,
      };
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Orchestrates a full Continue-with-Apple flow:
  ///   1. Launches Apple's native sheet via [AppleAuthService].
  ///   2. Forwards the resulting tokens (+ optional profile fields) to
  ///      the backend via [AuthService.socialLogin].
  ///   3. Returns the same `{success, message, data, doc_upload_status,
  ///      cancelled}` envelope callers expect — the `cancelled` flag
  ///      is set when the user dismissed Apple's sheet so the UI can
  ///      stay silent (no snackbar).
  ///
  /// Errors are caught and mapped to user-friendly messages here so
  /// the screens don't have to know about [SignInWithAppleAuthorizationException]
  /// or [DioException] types.
  Future<Map<String, dynamic>> signInWithApple() async {
    isLoading = true;
    notifyListeners();

    try {
      final credential = await AppleAuthService.signIn();
      debugPrint(
          "🍎 Apple credential: sub=${credential.userIdentifier}, "
          "email=${credential.email}, "
          "givenName=${credential.givenName}, "
          "familyName=${credential.familyName}");

      final result = await _authService.socialLogin(
        provider: "apple",
        identityToken: credential.identityToken,
        authorizationCode: credential.authorizationCode,
        email: credential.email,
        firstName: credential.givenName,
        lastName: credential.familyName,
      );

      return {
        "success": result["success"] == true,
        "message": result["message"] ?? "",
        "data": result["data"],
        "doc_upload_status": result["doc_upload_status"] ?? 0,
      };
    } on SignInWithAppleAuthorizationException catch (e) {
      // User cancelled the sheet — keep the UI silent and don't show an
      // error. Other Apple error codes do warrant a snackbar.
      if (e.code == AuthorizationErrorCode.canceled) {
        debugPrint("🍎 Apple sign-in cancelled by user");
        return {"success": false, "message": "", "cancelled": true};
      }
      debugPrint("🍎 Apple auth error: code=${e.code} message=${e.message}");
      return {
        "success": false,
        "message": "Apple sign-in failed. Please try again.",
      };
    } on SignInWithAppleNotSupportedException catch (e) {
      // Android (no webAuthenticationOptions configured) or an older OS
      // hits this — show a clear message instead of a generic error.
      // To enable Apple on Android: pass WebAuthenticationOptions(
      //   clientId: '<service-id>', redirectUri: <backend-callback>)
      // to SignInWithApple.getAppleIDCredential.
      debugPrint("🍎 Apple sign-in not supported on this device: ${e.message}");
      return {
        "success": false,
        "message": "Apple sign-in isn't available on this device. "
            "Please use another sign-in option.",
      };
    } on DioException catch (e) {
      debugPrint("🍎 Apple backend error: ${e.message}");
      return {
        "success": false,
        "message": "Network error. Please check your connection.",
      };
    } catch (e) {
      debugPrint("🍎 Unexpected Apple sign-in error: $e");
      return {
        "success": false,
        "message": "Something went wrong. Please try again.",
      };
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Orchestrates a full Continue-with-Google flow:
  ///   1. Launches Google's native account chooser via [GoogleAuthService].
  ///   2. Exchanges the resulting `id_token` for the app JWT via
  ///      [AuthService.loginWithGoogle] (which stores the token + KYC status).
  ///   3. Best-effort registers the FCM token (never fails the login).
  ///
  /// Returns a stable `{success, cancelled, message, needs_phone, email,
  /// doc_upload_status}` envelope. `needs_phone` tells the UI to route to the
  /// attach-phone step; `cancelled` is set when the user dismissed the chooser
  /// so the UI can stay silent (no snackbar). All error branches return the
  /// same shape so callers can read every key unconditionally.
  Future<Map<String, dynamic>> signInWithGoogle() async {
    isLoading = true;
    notifyListeners();

    try {
      final credential = await GoogleAuthService.signIn();
      debugPrint("🟢 Google sign-in success: ${credential.email}");

      if (credential.idToken == null) {
        return {
          "success": false,
          "cancelled": false,
          "message": "Google didn't return a sign-in token. Please try again.",
          "needs_phone": false,
          "email": credential.email,
          "doc_upload_status": 0,
        };
      }

      final result = await _authService.loginWithGoogle(credential.idToken!);

      if (result['success'] == true) {
        // Best-effort FCM registration — an FCM failure must never block a
        // successful login, so it's isolated in its own try/catch.
        try {
          final fcmToken = await NotificationService.getFcmToken();
          if (fcmToken != null && fcmToken.isNotEmpty) {
            await _authService.saveFcmToken(fcmToken);
          }
        } catch (e) {
          debugPrint("🟢 Google login FCM register error (ignored): $e");
        }
      }

      return {
        "success": result['success'] == true,
        "cancelled": false,
        "message": result['message'] ?? '',
        "needs_phone": result['needs_phone'] == true,
        "email": credential.email,
        "doc_upload_status": result['doc_upload_status'] ?? 0,
      };
    } on GoogleSignInException catch (e) {
      // User dismissed the chooser — keep the UI silent.
      if (e.code == GoogleSignInExceptionCode.canceled) {
        debugPrint("🟢 Google sign-in cancelled by user");
        return {
          "success": false,
          "cancelled": true,
          "message": "",
          "needs_phone": false,
          "email": null,
          "doc_upload_status": 0,
        };
      }
      debugPrint(
          "🟢 Google auth error: code=${e.code} message=${e.description}");
      return {
        "success": false,
        "cancelled": false,
        "message": "Google sign-in failed. Please try again.",
        "needs_phone": false,
        "email": null,
        "doc_upload_status": 0,
      };
    } catch (e) {
      debugPrint("🟢 Unexpected Google sign-in error: $e");
      return {
        "success": false,
        "cancelled": false,
        "message": "Something went wrong. Please try again.",
        "needs_phone": false,
        "email": null,
        "doc_upload_status": 0,
      };
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Sends an OTP so a Google-authenticated user can attach a phone number.
  /// Delegates to [AuthService.attachPhone]; returns `{success, message}`.
  Future<Map<String, dynamic>> attachPhone(String phone) async {
    isLoading = true;
    notifyListeners();

    try {
      return await _authService.attachPhone(phone);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Verifies the attach-phone OTP. Delegates to
  /// [AuthService.verifyAttachPhone]; returns `{success, message}`.
  Future<Map<String, dynamic>> verifyAttachPhone(
      String phone, String otp) async {
    isLoading = true;
    notifyListeners();

    try {
      return await _authService.verifyAttachPhone(phone, otp);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}