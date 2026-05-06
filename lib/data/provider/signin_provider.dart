import 'package:betrade/data/services/auth_service.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool isLoading = false;

  Future<Map<String, dynamic>> sendOtp(String phone) async {
    isLoading = true;
    notifyListeners();

    final result = await _authService.login(phone);

    isLoading = false;
    notifyListeners();
    return result;
  }

  Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    isLoading = true;
    notifyListeners();

    final result = await _authService.verifyLoginOtp(phone, otp);

    isLoading = false;
    notifyListeners();
    return result;
  }
}
