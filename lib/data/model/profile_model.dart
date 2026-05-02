// class ProfileModel {
//   final String firstName;
//   final String lastName;
//   final String avatar;
//
//   ProfileModel({
//     required this.firstName,
//     required this.lastName,
//     required this.avatar,
//   });
//
//   factory ProfileModel.fromJson(Map<String, dynamic> json) {
//     return ProfileModel(
//       firstName: json['first_name'] ?? '',
//       lastName: json['last_name'] ?? '',
//       avatar: _fixAvatar(json['avatar'] ?? ''),
//     );
//   }
//
//   static String _fixAvatar(String url) {
//     if (url.contains("https://") && url.indexOf("https://") != url.lastIndexOf("https://")) {
//       return url.substring(url.lastIndexOf("https://"));
//     }
//     return url;
//   }
// }

class ProfileModel {
  final String firstName;
  final String lastName;
  final String avatar;

  final String? phone;
  final String? gender;
  final String? country;
  final String? currency;
  final String? language;
  final String? email;

  ProfileModel({
    required this.firstName,
    required this.lastName,
    required this.avatar,
    this.phone,
    this.gender,
    this.country,
    this.currency,
    this.language,
    this.email,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      avatar: _fixAvatar(json['avatar'] ?? ''),

      /// 🔥 NEW FIELDS
      phone: json['phone'],
      gender: json['gender'],
      country: json['country'],
      currency: json['currency'],
      language: json['language'],
      email: json['email'],
    );
  }
  static String _fixAvatar(String url) {
    if (url.contains("https://") &&
        url.indexOf("https://") != url.lastIndexOf("https://")) {
      return url.substring(url.lastIndexOf("https://"));
    }
    return url;
  }
}