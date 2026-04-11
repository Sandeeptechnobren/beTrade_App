import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../core/config/api_endpoint..dart';
import '../model/graph_model.dart';

class AuthService {

  Future<bool> sendOtp(String phone) async {
    try {
      final res = await http.post(
        Uri.parse(ApiEndpoints.register),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "phone": phone,
        }),
      );

      print("STATUS: ${res.statusCode}");
      print("RESPONSE: ${res.body}");

      return res.statusCode == 200;
    } catch (e) {
      print("ERROR: $e");
      return false;
    }
  }

  Future<bool> verifyOtp(String phone, String otp) async {
    try {
      final res = await http.post(
        Uri.parse(ApiEndpoints.verifyOtp),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "phone": phone,
          "otp": otp,
        }),
      );

      print("OTP VERIFY STATUS: ${res.statusCode}");
      print("OTP VERIFY RESPONSE: ${res.body}");

      return res.statusCode == 200;
    } catch (e) {
      print("OTP ERROR: $e");
      return false;
    }
  }

  Future<bool> completeSignup({
    required String phone,
    required String gender,
    required String firstName,
    required String lastName,
    required File image,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiEndpoints.completeProfile),
      );

      request.fields['phone'] = phone;
      request.fields['gender'] = gender;
      request.fields['first_name'] = firstName;
      request.fields['last_name'] = lastName;

      request.files.add(
        await http.MultipartFile.fromPath('avatar', image.path),
      );

      var response = await request.send();

      return response.statusCode == 200;
    } catch (e) {
      print("Signup Error: $e");
      return false;
    }
  }

  Future<List<ChartData>> fetchChartData() async {
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.chart), // ✅ FIXED
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => ChartData.fromJson(e)).toList();
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      throw Exception("Chart Error: $e");
    }
  }

  static Future<bool> logout(String token) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.logout),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      print("Logout Response: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("Logout Error: $e");
      return false;
    }
  }
}