import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/services/profile_service.dart';
import '../model/profile_model.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileModel? profile;
  bool isLoading = false;

  Future<void> fetchProfile() async {
    isLoading = true;
    notifyListeners();
    final result = await ProfileService.getProfile();
    profile = result;
    isLoading = false;
    notifyListeners();
  }

  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
    required String gender,
    required String country,
    File? image,
  }) async {
    isLoading = true;
    notifyListeners();

    bool success = await ProfileService.updateProfile(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      gender: gender,
      country: country,
      image: image,
    );

    if (success) {
      await fetchProfile();
    }

    isLoading = false;
    notifyListeners();

    return success;
  }
}