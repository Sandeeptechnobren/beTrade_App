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

  /// Live trading stats from `data.stats` (GET /profile).
  final int winRate; // 0..100
  final double totalEarnedGhs; // net realised P&L (can be negative)
  final int totalTrades;

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
    this.winRate = 0,
    this.totalEarnedGhs = 0,
    this.totalTrades = 0,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final stats = (json['stats'] is Map)
        ? Map<String, dynamic>.from(json['stats'] as Map)
        : const <String, dynamic>{};

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

      /// Live stats (default 0 when absent).
      winRate: (stats['win_rate'] is num)
          ? (stats['win_rate'] as num).round()
          : int.tryParse('${stats['win_rate'] ?? 0}') ?? 0,
      totalEarnedGhs: (stats['total_earned_ghs'] is num)
          ? (stats['total_earned_ghs'] as num).toDouble()
          : double.tryParse('${stats['total_earned_ghs'] ?? 0}') ?? 0.0,
      totalTrades: (stats['total_trades'] is num)
          ? (stats['total_trades'] as num).round()
          : int.tryParse('${stats['total_trades'] ?? 0}') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'avatar': avatar,
      'phone': phone,
      'gender': gender,
      'country': country,
      'currency': currency,
      'language': language,
      'email': email,
      'stats': {
        'win_rate': winRate,
        'total_earned_ghs': totalEarnedGhs,
        'total_trades': totalTrades,
      },
    };
  }

  static String _fixAvatar(String url) {
    if (url.contains("https://") &&
        url.indexOf("https://") != url.lastIndexOf("https://")) {
      return url.substring(url.lastIndexOf("https://"));
    }
    return url;
  }
}