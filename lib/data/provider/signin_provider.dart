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
}