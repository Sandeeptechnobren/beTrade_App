import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../services/apple_auth_service.dart';
import '../services/auth_service.dart';

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
}