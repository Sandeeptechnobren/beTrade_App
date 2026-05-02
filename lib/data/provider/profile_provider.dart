// import 'dart:io';
// import 'package:flutter/material.dart';
// import '../../data/services/profile_service.dart';
// import '../model/profile_model.dart';
//
// class ProfileProvider extends ChangeNotifier {
//   ProfileModel? profile;
//   bool isLoading = false;
//
//   Future<void> fetchProfile() async {
//     isLoading = true;
//     notifyListeners();
//     final result = await ProfileService.getProfile();
//     profile = result;
//     isLoading = false;
//     notifyListeners();
//   }
//
//   Future<bool> updateProfile({
//     required String firstName,
//     required String lastName,
//     required String phone,
//     required String gender,
//     required String country,
//     File? image,
//   }) async {
//     isLoading = true;
//     notifyListeners();
//
//     bool success = await ProfileService.updateProfile(
//       firstName: firstName,
//       lastName: lastName,
//       phone: phone,
//       gender: gender,
//       country: country,
//       image: image,
//     );
//
//     if (success) {
//       await fetchProfile();
//     }
//
//     isLoading = false;
//     notifyListeners();
//
//     return success;
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/services/profile_service.dart';
import '../model/profile_model.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileModel? profile;
  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchProfile() async {
    print("\n========== 🔵 FETCH PROFILE CALLED ==========");

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    print("📌 Loading state: true");

    final result = await ProfileService.getProfile();

    if (result != null) {
      profile = result;
      errorMessage = null;
      print("✅ Profile saved to provider");
      print("   Name: ${profile!.firstName} ${profile!.lastName}");
      print("   Avatar: ${profile!.avatar}");
    } else {
      profile = null;
      errorMessage = "Failed to load profile data";
      print("❌ Failed to load profile - result is null");
    }

    isLoading = false;
    notifyListeners();

    print("📌 Loading state: false");
    print("========== 🔵 FETCH PROFILE COMPLETED ==========\n");
  }

  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String gender,
    required String country,
    File? image,
  }) async {
    print("\n========== 🔵 UPDATE PROFILE CALLED ==========");

    isLoading = true;
    notifyListeners();

    bool success = await ProfileService.updateProfile(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      email: email,
      gender: gender,
      country: country,
      image: image,
    );

    if (success) {
      print("✅ Update successful, fetching fresh profile...");
      await fetchProfile();
    } else {
      print("❌ Update failed");
    }

    isLoading = false;
    notifyListeners();

    print("========== 🔵 UPDATE PROFILE COMPLETED ==========\n");
    return success;
  }

  void clearProfile() {
    profile = null;
    errorMessage = null;
    notifyListeners();
    print("🔄 Profile cleared from provider");
  }
}