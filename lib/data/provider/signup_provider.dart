// import 'dart:io';
// import 'package:flutter/material.dart';
// import '../services/auth_service.dart';
//
// class SignupProvider extends ChangeNotifier {
//   final AuthService _service = AuthService();
//   String phone = "";
//   String otp = "";
//   String gender = "";
//   String firstName = "";
//   String lastName = "";
//   File? profileImage;
//   bool isLoading = false;
//   void setPhone(String val) {
//     phone = val;
//     notifyListeners();
//   }
//   void setOtp(String val) {
//     otp = val;
//     notifyListeners();
//   }
//   void setGender(String val) {
//     gender = val;
//     notifyListeners();
//   }
//   void setName(String f, String l) {
//     firstName = f;
//     lastName = l;
//     notifyListeners();
//   }
//   void setProfileImage(File file) {
//     profileImage = file;
//     notifyListeners();
//   }
//   Future<bool> sendOtp() async {
//     isLoading = true;
//     notifyListeners();
//     bool success = await _service.sendOtp(phone);
//     isLoading = false;
//     notifyListeners();
//     return success;
//   }
//   Future<bool> verifyOtp(String otp) async {
//     isLoading = true;
//     notifyListeners();
//     bool success = await _service.verifyOtp(phone, otp);
//     isLoading = false;
//     notifyListeners();
//     return success;
//   }
//   Future<bool> completeSignup() async {
//     if (profileImage == null) return false;
//     isLoading = true;
//     notifyListeners();
//     bool success = await _service.completeSignup(
//       phone: phone,
//       gender: gender,
//       firstName: firstName,
//       lastName: lastName,
//       image: profileImage!,
//     );
//     isLoading = false;
//     notifyListeners();
//     return success;
//   }
// }









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
  String email = "";
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

  void setName(String f, String l, String e) {
    firstName = f;
    lastName = l;
    email = e;
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

  // ✅ FIXED: Complete signup with proper file handling
  Future<bool> completeSignup() async {
    if (profileImage == null) return false;

    isLoading = true;
    notifyListeners();

    try {
      // Verify file exists before proceeding
      if (!await profileImage!.exists()) {
        debugPrint("❌ Profile image does not exist at path: ${profileImage!.path}");
        return false;
      }

      debugPrint("✅ Profile image exists at: ${profileImage!.path}");
      debugPrint("✅ File size: ${await profileImage!.length()} bytes");

      bool success = await _service.completeSignup(
        phone: phone,
        gender: gender,
        firstName: firstName,
        lastName: lastName,
        email: email,
        image: profileImage!,
      );

      return success;
    } catch (e) {
      debugPrint("❌ Error in completeSignup: $e");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}