

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

  /// Updates the signed-in user profile.
  ///
  /// IMPORTANT - this is sent as POST with a `_method: PUT` field (Laravel
  /// method spoofing), NOT as a real PUT. The route really is
  /// `PUT /edit-profile`, but PHP only parses `multipart/form-data` bodies for
  /// POST requests - it never populates `$_POST` / `$_FILES` for a PUT. A
  /// genuine PUT therefore reached Laravel with an empty request bag: every
  /// `sometimes` rule passed on zero fields, `$data` was empty,
  /// `hasFile(avatar)` was false, and `$user->update([])` was a silent no-op
  /// that still returned 200 "Profile updated successfully". That is why
  /// editing a field and changing the avatar both appeared to work but never
  /// persisted. Do not change this back to `.put()`.
  ///
  /// `phone` is deliberately NOT sent: it is excluded from the backend
  /// allowlist (security fix P1-3) because the phone number is the login
  /// identity. Phone changes go through the OTP-verified attach-phone flow.
  static Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    String? country,
    String? currency,
    String? language,
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
        // Laravel method spoofing - see the doc comment above.
        '_method': 'PUT',
        'first_name': firstName,
        'last_name': lastName,
      };

      // Only send the optional fields when we actually have a value. Every
      // backend rule is `sometimes`, so omitting a key leaves that column
      // untouched rather than blanking it.
      if (country != null && country.isNotEmpty) fields['country'] = country;
      if (currency != null && currency.isNotEmpty) {
        fields['currency'] = currency;
      }
      if (language != null && language.isNotEmpty) {
        fields['language'] = language;
      }

      debugPrint(" Update Data:");
      debugPrint("   first_name: $firstName");
      debugPrint("   last_name: $lastName");
      debugPrint("   country: ${country ?? '(unchanged)'}");
      debugPrint("   currency: ${currency ?? '(unchanged)'}");
      debugPrint("   language: ${language ?? '(unchanged)'}");

      if (image != null) {
        debugPrint("📌 Image: ${image.path}");
        fields['avatar'] = await MultipartFile.fromFile(image.path);
      } else {
        debugPrint("📌 Image: Not changed");
      }

      final formData = FormData.fromMap(fields);

      final response = await DioClient.multipartInstance.post(
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
