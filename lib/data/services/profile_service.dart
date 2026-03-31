import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../model/profile_model.dart';
import 'local_storage.dart';

class ProfileService {
  static Future<ProfileModel?> getProfile() async {
    try {
      String? token = LocalStorage.getToken();

      final response = await http.get(
        Uri.parse(
          "https://api.easycoders.in/projects/betrade/public/api/profile",
        ),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );
      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ProfileModel.fromJson(data['data']);
      }

      if (response.statusCode == 404) {
        return null;
      }
    } catch (e) {
      print("ERROR: $e");
    }

    return null;
  }

  static Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
    required String gender,
    required String country,
    File? image,
  }) async {
    try {
      String? token = LocalStorage.getToken();

      var request = http.MultipartRequest(
        "PUT",
        Uri.parse(
          "https://api.easycoders.in/projects/betrade/public/api/edit-profile",
        ),
      );
      request.headers.addAll({
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      });
      request.fields['first_name'] = firstName;
      request.fields['last_name'] = lastName;
      request.fields['phone'] = phone;
      request.fields['gender'] = gender;
      request.fields['country'] = country;
      if (image != null) {
        request.files.add(
          await http.MultipartFile.fromPath('avatar', image.path),
        );
      }
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      print("STATUS: ${response.statusCode}");
      print("BODY: $responseData");
      return response.statusCode == 200;
    } catch (e) {
      print("ERROR: $e");
      return false;
    }
  }
}
