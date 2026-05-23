

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '../../core/config/api_endpoint.dart';
import '../../core/network/dio_client.dart';
import '../model/profile_model.dart';
import 'local_storage.dart';

class ProfileService {

  static Future<ProfileModel?> getProfile() async {
    try {
      print("\n========== 🔵 GET PROFILE STARTED ==========");

      String? token = LocalStorage.getToken();
      print("📌 Token Status: ${token != null ? "✅ Present" : "❌ Missing"}");

      if (token == null || token.isEmpty) {
        print("❌ ERROR: No token found! User not logged in.");
        return null;
      }

      print("📌 API URL: ${ApiEndpoints.profile}");

      final response = await DioClient.instance.get(
        ApiEndpoints.profile,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
        ),
      );

      debugPrint("📌 Response Status Code: ${response.statusCode}");
      debugPrint("📌 Response Body: ${response.data}");

      if (response.statusCode == 200) {
        final dynamic raw = response.data;
        if (raw is! Map) {
          debugPrint("❌ Response is not a Map");
          return null;
        }
        final Map<String, dynamic> data = Map<String, dynamic>.from(raw);
        debugPrint("📌 Parsed JSON Keys: ${data.keys}");

        ProfileModel? profile;

        // Check if response has 'data' key
        if (data.containsKey('data') && data['data'] != null) {
          debugPrint("✅ Using data['data'] structure");
          profile = ProfileModel.fromJson(
              Map<String, dynamic>.from(data['data'] as Map));
        } else if (data.containsKey('user') && data['user'] != null) {
          debugPrint("✅ Using data['user'] structure");
          profile = ProfileModel.fromJson(
              Map<String, dynamic>.from(data['user'] as Map));
        } else {
          debugPrint("✅ Using direct data structure");
          profile = ProfileModel.fromJson(data);
        }

        if (profile != null) {
          debugPrint("\n✅✅✅ PROFILE DATA SUCCESSFULLY LOADED ✅✅✅");
          debugPrint("👤 First Name: '${profile.firstName}'");
          debugPrint("👤 Last Name: '${profile.lastName}'");
          debugPrint("🖼️ Avatar URL: '${profile.avatar}'");
          debugPrint("📞 Phone: '${profile.phone}'");
          debugPrint("⚧ Gender: '${profile.gender}'");
          debugPrint("🌍 Country: '${profile.country}'");
          debugPrint("💵 Currency: '${profile.currency}'");
          debugPrint("🔤 Language: '${profile.language}'");
          debugPrint("==========================================\n");
        } else {
          debugPrint("❌ Profile is null after parsing!");
        }

        return profile;
      } else {
        debugPrint("❌ Unknown error! Status Code: ${response.statusCode}");
        return null;
      }
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      if (code == 401) {
        debugPrint("❌ Unauthorized! Token may be expired.");
        debugPrint("🔄 Clearing token...");
        await LocalStorage.clearToken();
      } else if (code == 404) {
        debugPrint("❌ API Endpoint not found! Check URL: ${ApiEndpoints.profile}");
      } else {
        debugPrint(
            "❌ DioException in getProfile: ${e.message}; code=$code; response=${e.response?.data}");
      }
      return null;
    } catch (e) {
      debugPrint("❌ EXCEPTION in getProfile: $e");
      return null;
    }
  }

  static Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
    // required String email,
    // required String gender,
    // required String country,
    File? image,
  }) async {
    try {
      debugPrint("\n========== 🔵 UPDATE PROFILE STARTED ==========");

      String? token = LocalStorage.getToken();
      debugPrint("📌 Token Status: ${token != null ? "✅ Present" : "❌ Missing"}");

      if (token == null || token.isEmpty) {
        debugPrint("❌ No token found!");
        return false;
      }

      final fields = <String, dynamic>{
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        // 'email': email,
        // 'gender': gender,
        // 'country': country,
      };

      debugPrint(" Update Data:");
      debugPrint("   first_name: $firstName");
      debugPrint("   last_name: $lastName");
      debugPrint("   phone: $phone");
      // print("   email: $email");
      // print("   gender: $gender");
      // print("   country: $country");

      if (image != null) {
        debugPrint("📌 Image: ${image.path}");
        fields['avatar'] = await MultipartFile.fromFile(image.path);
      } else {
        debugPrint("📌 Image: Not changed");
      }

      final formData = FormData.fromMap(fields);

      final response = await DioClient.multipartInstance.put(
        ApiEndpoints.editProfile,
        data: formData,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
        ),
      );

      debugPrint("📌 Response Status: ${response.statusCode}");
      debugPrint("📌 Response Body: ${response.data}");

      if (response.statusCode == 200) {
        debugPrint("✅ Profile updated successfully!");
        debugPrint("==========================================\n");
        return true;
      } else {
        debugPrint("❌ Update failed! Status: ${response.statusCode}");
        debugPrint("==========================================\n");
        return false;
      }
    } on DioException catch (e) {
      debugPrint(
          "❌ DioException in updateProfile: ${e.message}; code=${e.response?.statusCode}; response=${e.response?.data}");
      return false;
    } catch (e) {
      debugPrint("❌ EXCEPTION in updateProfile: $e");
      return false;
    }
  }
}
