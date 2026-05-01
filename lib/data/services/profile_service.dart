//
// import 'dart:convert';
// import 'dart:io';
// import 'package:http/http.dart' as http;
// import '../../core/config/api_endpoint..dart';
// import '../model/profile_model.dart';
// import 'local_storage.dart';
//
// class ProfileService {
//   static Future<ProfileModel?> getProfile() async {
//     try {
//       String? token = LocalStorage.getToken();
//
//       final response = await http.get(
//         Uri.parse(ApiEndpoints.profile),
//         headers: {
//           "Authorization": "Bearer $token",
//           "Accept": "application/json",
//         },
//       );
//       print("STATUS: ${response.statusCode}");
//       print("BODY: ${response.body}");
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         return ProfileModel.fromJson(data['data']);
//       }
//       if (response.statusCode == 404){
//         return null;
//       }
//     } catch (e) {
//       print("ERROR: $e");
//     }
//     return null;
//   }
//
//   static Future<bool> updateProfile({
//     required String firstName,
//     required String lastName,
//     required String phone,
//     required String gender,
//     required String country,
//     File? image,
//   }) async {
//     try {
//       String? token = LocalStorage.getToken();
//       var request = http.MultipartRequest(
//         "PUT",
//         Uri.parse(ApiEndpoints.editProfile),
//       );
//       request.headers.addAll({
//         "Authorization": "Bearer $token",
//         "Accept": "application/json",
//       });
//       request.fields['first_name'] = firstName;
//       request.fields['last_name'] = lastName;
//       request.fields['phone'] = phone;
//       request.fields['gender'] = gender;
//       request.fields['country'] = country;
//
//       if (image != null) {
//         request.files.add(
//           await http.MultipartFile.fromPath('avatar', image.path),
//         );
//       }
//       var response = await request.send();
//       var responseData = await response.stream.bytesToString();
//       print("STATUS: ${response.statusCode}");
//       print("BODY: $responseData");
//       print("response of api");
//       return response.statusCode == 200;
//     } catch (e) {
//       print("ERROR: $e");
//       return false;
//     }
//   }
// }
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../core/config/api_endpoint..dart';
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

      final response = await http.get(
        Uri.parse(ApiEndpoints.profile),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      print("📌 Response Status Code: ${response.statusCode}");
      print("📌 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print("📌 Parsed JSON Keys: ${data.keys}");

        ProfileModel? profile;

        // Check if response has 'data' key
        if (data.containsKey('data') && data['data'] != null) {
          print("✅ Using data['data'] structure");
          profile = ProfileModel.fromJson(data['data']);
        }
        else if (data.containsKey('user') && data['user'] != null) {
          print("✅ Using data['user'] structure");
          profile = ProfileModel.fromJson(data['user']);
        }
        else {
          print("✅ Using direct data structure");
          profile = ProfileModel.fromJson(data);
        }

        if (profile != null) {
          print("\n✅✅✅ PROFILE DATA SUCCESSFULLY LOADED ✅✅✅");
          print("👤 First Name: '${profile.firstName}'");
          print("👤 Last Name: '${profile.lastName}'");
          print("🖼️ Avatar URL: '${profile.avatar}'");
          print("📞 Phone: '${profile.phone}'");
          print("⚧ Gender: '${profile.gender}'");
          print("🌍 Country: '${profile.country}'");
          print("💵 Currency: '${profile.currency}'");
          print("🔤 Language: '${profile.language}'");
          print("==========================================\n");
        } else {
          print("❌ Profile is null after parsing!");
        }

        return profile;
      }
      else if (response.statusCode == 401) {
        print("❌ Unauthorized! Token may be expired.");
        print("🔄 Clearing token...");
        await LocalStorage.clearToken();
        return null;
      }
      else if (response.statusCode == 404) {
        print("❌ API Endpoint not found! Check URL: ${ApiEndpoints.profile}");
        return null;
      }
      else {
        print("❌ Unknown error! Status Code: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("❌ EXCEPTION in getProfile: $e");
      return null;
    }
  }

  static Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String gender,
    required String country,
    File? image,
  }) async {
    try {
      print("\n========== 🔵 UPDATE PROFILE STARTED ==========");

      String? token = LocalStorage.getToken();
      print("📌 Token Status: ${token != null ? "✅ Present" : "❌ Missing"}");

      if (token == null || token.isEmpty) {
        print("❌ No token found!");
        return false;
      }

      var request = http.MultipartRequest(
        "PUT",
        Uri.parse(ApiEndpoints.editProfile),
      );

      request.headers.addAll({
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      });

      request.fields['first_name'] = firstName;
      request.fields['last_name'] = lastName;
      request.fields['phone'] = phone;
      request.fields['email'] = email;
      request.fields['gender'] = gender;
      request.fields['country'] = country;

      print(" Update Data:");
      print("   first_name: $firstName");
      print("   last_name: $lastName");
      print("   phone: $phone");
      print("   gender: $gender");
      print("   country: $country");

      if (image != null) {
        print("📌 Image: ${image.path}");
        request.files.add(
          await http.MultipartFile.fromPath('avatar', image.path),
        );
      } else {
        print("📌 Image: Not changed");
      }

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      print("📌 Response Status: ${response.statusCode}");
      print("📌 Response Body: $responseData");

      if (response.statusCode == 200) {
        print("✅ Profile updated successfully!");
        print("==========================================\n");
        return true;
      } else {
        print("❌ Update failed! Status: ${response.statusCode}");
        print("==========================================\n");
        return false;
      }
    } catch (e) {
      print("❌ EXCEPTION in updateProfile: $e");
      return false;
    }
  }
}
