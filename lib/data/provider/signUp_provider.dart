import 'dart:io';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SignupProvider extends ChangeNotifier {
  final AuthService _service = AuthService();

  String phone = "";
  String otp = "";
  String gender = "";
  String firstName = "";
  String lastName = "";
  File? profileImage;

  bool isLoading = false;
  void setPhone(String val) {
    phone = val;
    notifyListeners();
  }

  void setOtp(String val) {
    otp = val;
    notifyListeners();
  }

  void setGender(String val) {
    gender = val;
    notifyListeners();
  }

  void setName(String f, String l) {
    firstName = f;
    lastName = l;
    notifyListeners();
  }

  void setProfileImage(File file) {
    profileImage = file;
    notifyListeners();
  }

  Future<bool> sendOtp() async {
    isLoading = true;
    notifyListeners();
    bool success = await _service.sendOtp(phone);
    isLoading = false;
    notifyListeners();

    return success;
  }

  Future<bool> verifyOtp(String otp) async {
    isLoading = true;
    notifyListeners();

    bool success = await _service.verifyOtp(phone, otp);

    isLoading = false;
    notifyListeners();

    return success;
  }
  Future<bool> completeSignup() async {
    if (profileImage == null) return false;

    isLoading = true;
    notifyListeners();

    bool success = await _service.completeSignup(
      phone: phone,
      gender: gender,
      firstName: firstName,
      lastName: lastName,
      image: profileImage!,
    );

    isLoading = false;
    notifyListeners();
    return success;
  }
}