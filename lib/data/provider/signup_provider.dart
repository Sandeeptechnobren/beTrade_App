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

  Future<Map<String, dynamic>> sendOtp() async {
    isLoading = true;
    notifyListeners();
    Map<String, dynamic> success = await _service.sendOtp(phone);
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

  /// Final step of signup. Returns the typed envelope from AuthService so
  /// SignupScreen can show the backend's actual error message on failure
  /// instead of a generic snackbar.
  ///
  /// Shape on success:
  ///   { success: true, message, data: user, doc_upload_status }
  /// On failure:
  ///   { success: false, message }
  ///
  /// The AuthService already persists the Sanctum token + FCM token +
  /// doc_upload_status before returning, so the caller can route straight
  /// to MainScreen on success.
  Future<Map<String, dynamic>> completeSignup() async {
    if (profileImage == null) {
      return {"success": false, "message": "Please select a profile photo"};
    }

    isLoading = true;
    notifyListeners();

    try {
      if (!await profileImage!.exists()) {
        debugPrint("Profile image missing at path: ${profileImage!.path}");
        return {
          "success": false,
          "message": "Profile photo no longer exists. Please reselect.",
        };
      }

      return await _service.completeSignup(
        phone: phone,
        gender: gender,
        firstName: firstName,
        lastName: lastName,
        email: email,
        image: profileImage!,
      );
    } catch (e) {
      debugPrint("SignupProvider.completeSignup error: $e");
      return {"success": false, "message": "Unexpected error during signup"};
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}