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
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../data/services/profile_service.dart';
import '../../data/services/achievement_service.dart';
import '../model/achievement_model.dart';
import '../model/profile_model.dart';
import '../../data/services/local_storage.dart';
import '../../core/utils/avatar_cache.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileModel? profile;
  List<AchievementModel> achievements = [];
  bool isLoading = false;
  String? errorMessage;

  ProfileProvider() {
    _loadCachedProfile();
  }

  void _loadCachedProfile() {
    final cachedProfile = LocalStorage.getCachedData("profile");
    if (cachedProfile != null) {
      try {
        profile = ProfileModel.fromJson(jsonDecode(cachedProfile));
      } catch (e) {
        debugPrint("Error decoding cached profile: $e");
      }
    }

    final cachedAchievements = LocalStorage.getCachedData("achievements");
    if (cachedAchievements != null) {
      try {
        final List<dynamic> decoded = jsonDecode(cachedAchievements);
        achievements = decoded.map((e) => AchievementModel.fromJson(e)).toList();
      } catch (e) {
        debugPrint("Error decoding cached achievements: $e");
      }
    }
    notifyListeners();
  }

  Future<void> fetchProfile() async {
    debugPrint("\n========== 🔵 FETCH PROFILE CALLED ==========");

    // If we have cached data, don't show loading on screen to avoid flicker, 
    // unless we want to force a refresh indicator.
    if (profile == null) {
      isLoading = true;
      notifyListeners();
    }

    errorMessage = null;
    debugPrint("📌 Loading state: $isLoading");

    final result = await ProfileService.getProfile();

    if (result != null) {
      profile = result;
      errorMessage = null;
      debugPrint("✅ Profile saved to provider");
      
      // Save to cache
      LocalStorage.cacheData("profile", jsonEncode(profile!.toJson()));
    } else {
      // If API fails and we have no profile at all, show error
      if (profile == null) {
        errorMessage = "Failed to load profile data";
      }
      debugPrint("❌ Failed to load profile - result is null");
    }

    // Fetch the achievement board
    final achievementsResult = await AchievementService.getAchievements();
    if (achievementsResult.isNotEmpty) {
      achievements = achievementsResult;
      // Save to cache
      LocalStorage.cacheData("achievements", jsonEncode(achievements.map((e) => e.toJson()).toList()));
    }

    isLoading = false;
    notifyListeners();

    debugPrint("📌 Loading state: false");
    debugPrint("========== 🔵 FETCH PROFILE COMPLETED ==========\n");
  }

  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
    // required String email,
    // required String gender,
    // required String country,
    File? image,
  }) async {
    debugPrint("\n========== 🔵 UPDATE PROFILE CALLED ==========");

    isLoading = true;
    notifyListeners();

    bool success = await ProfileService.updateProfile(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      // email: email,
      // gender: gender,
      // country: country,
      image: image,
    );

    if (success) {
      debugPrint("✅ Update successful, fetching fresh profile...");
      // Avatar URLs are stable (the server overwrites the file in place), so
      // Flutter's ImageCache + mounted Image widgets keep serving the OLD
      // picture. Bump the cache-bust token (changes the avatar URL so it
      // re-downloads everywhere) and clear the decoded image cache too.
      AvatarCache.bump();
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
      await fetchProfile();
    } else {
      debugPrint("❌ Update failed");
    }

    isLoading = false;
    notifyListeners();

    debugPrint("========== 🔵 UPDATE PROFILE COMPLETED ==========\n");
    return success;
  }

  void clearProfile() {
    profile = null;
    errorMessage = null;
    notifyListeners();
    debugPrint("🔄 Profile cleared from provider");
  }
}
