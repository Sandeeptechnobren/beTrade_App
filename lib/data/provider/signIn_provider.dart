import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/local_storage.dart';

class AuthProvider extends ChangeNotifier {
  bool isLoading = false;

  Future<Map<String, dynamic>> sendOtp(String phone) async {
    isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse(
        "https://api.easycoders.in/projects/betrade/public/api/login",
      );
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phone": phone}),
      );
      print(response.body);
      final data = jsonDecode(response.body);

      isLoading = false;
      notifyListeners();

      return {
        "success": data['status'] == true,
        "message": data['message'] ?? "Something went wrong",
      };

    } catch (e) {
      isLoading = false;
      notifyListeners();

      return {
        "success": false,
        "message": "Server error",
      };
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse(
        "https://api.easycoders.in/projects/betrade/public/api/verify-otp/login",
      );

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "phone": phone,
          "otp": otp,
        }),
      );

      final data = jsonDecode(response.body);
      print("VERIFY RESPONSE: $data");
      if (data['status'] == true) {
        String token = data['token'];

        await LocalStorage.setToken(token);
      }

      isLoading = false;
      notifyListeners();

      return {
        "success": data['status'] == true,
        "message": data['message'] ?? "Something went wrong",
        "data": data['user'],
      };

    } catch (e) {
      isLoading = false;
      notifyListeners();

      return {
        "success": false,
        "message": "Server error",
      };
    }
  }
}