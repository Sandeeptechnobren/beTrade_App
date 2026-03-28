import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../core/config/api_endpoint..dart';
class AuthService {
  Future<bool> sendOtp(String phone) async {
    try {
      print(" FINAL PHONE SENT: $phone");
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
        Uri.parse("https://api.easycoders.in/projects/betrade/public/api/verify-otp/register"),
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
    var request = http.MultipartRequest('POST', Uri.parse("https://api.easycoders.in/projects/betrade/public/api/complete-profile"),);
    request.fields['phone'] = phone;
    request.fields['gender'] = gender;
    request.fields['first_name'] = firstName;
    request.fields['last_name'] = lastName;
    request.files.add(
      await http.MultipartFile.fromPath('avatar', image.path),
    );
    var response = await request.send();
    return response.statusCode == 200;
  }
}