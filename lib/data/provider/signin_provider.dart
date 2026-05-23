import 'package:flutter/cupertino.dart';

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

  /// Trigger native Google account picker → backend tokeninfo verify →
  /// Sanctum token issuance. The service layer handles the heavy lifting
  /// (FCM registration, doc_upload_status persistence). We just toggle
  /// `isLoading` so the UI can show a spinner across the round-trip.
  Future<Map<String, dynamic>> loginWithGoogle() async {
    isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.loginWithGoogle();
      return {
        "success": result["success"] == true,
        "cancelled": result["cancelled"] == true,
        "needs_phone": result["needs_phone"] == true,
        "message": result["message"] ?? "Something went wrong",
        "data": result["data"],
        "doc_upload_status": result["doc_upload_status"] ?? 0,
      };
    } catch (e) {
      debugPrint("GOOGLE SIGN-IN PROVIDER ERROR: $e");
      return {
        "success": false,
        "message": "Something went wrong",
      };
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Step 1 of the post-Google phone attach flow — sends an OTP.
  Future<Map<String, dynamic>> sendAttachPhoneOtp(String phone) async {
    isLoading = true;
    notifyListeners();
    try {
      final result = await _authService.attachPhone(phone);
      return {
        "success": result["success"] == true,
        "message": result["message"] ?? "Something went wrong",
      };
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Step 2 of the post-Google phone attach flow — verifies the OTP and the
  /// backend writes phone onto the authed user.
  Future<Map<String, dynamic>> verifyAttachPhoneOtp(String phone, String otp) async {
    isLoading = true;
    notifyListeners();
    try {
      final result = await _authService.verifyAttachPhone(phone, otp);
      return {
        "success": result["success"] == true,
        "message": result["message"] ?? "Something went wrong",
        "data": result["data"],
      };
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}