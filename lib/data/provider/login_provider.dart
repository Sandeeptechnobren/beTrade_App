import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginProvider extends ChangeNotifier {

  final AuthService _service = AuthService();

  bool isLoading = false;

  String phone = "";

  void setPhone(String value) {
    phone = value;
    notifyListeners();
  }

  Future<Map<String, dynamic>> sendOtp(String phone) async {

    if (isLoading) {
      return {
        "success": false,
        "message": "Please wait...",
      };
    }

    isLoading = true;
    notifyListeners();

    try {

      final result = await _service.sendOtp(phone);

      return result;

    } finally {

      isLoading = false;
      notifyListeners();
    }
  }
}