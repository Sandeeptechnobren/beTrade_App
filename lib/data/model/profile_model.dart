/// User profile DTO returned by `GET /api/profile` (and embedded inside
/// `/api/verify-otp/login`'s `user` payload).
///
/// `avatar` is the full-resolution upload (used when previewing/editing).
/// `thumbnail` is a 200×200 server-rendered thumbnail. UI surfaces that
/// only need a small circular face (profile-tab CircleAvatar, list rows,
/// nav avatars) should call `displayAvatar` — it prefers the thumbnail
/// when present and falls back to the full image otherwise. Saves
/// bandwidth + render cost.
class ProfileModel {
  final String firstName;
  final String lastName;
  final String avatar;
  final String thumbnail;

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
    required this.thumbnail,
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

  /// Best URL to show in a small/read-only avatar slot. Uses the
  /// thumbnail when the backend returned one, otherwise falls back to the
  /// full-resolution upload. Returns empty string if neither is set so
  /// callers can do `.isNotEmpty` checks the same way as before.
  String get displayAvatar {
    if (thumbnail.isNotEmpty) return thumbnail;
    return avatar;
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final stats = (json['stats'] is Map)
        ? Map<String, dynamic>.from(json['stats'] as Map)
        : const <String, dynamic>{};

    return ProfileModel(
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      avatar: _fixAvatar(json['avatar'] ?? ''),
      // Backend started returning `thumbnail` on GET /profile + login.
      // Older payloads may not include it — default to empty string so
      // `displayAvatar` falls through to the full-size `avatar`.
      thumbnail: _fixAvatar(json['thumbnail'] ?? ''),
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

  /// Older backends (and a buggy revision of complete-profile) sometimes
  /// returned URLs with a doubled `https://` prefix. Strip back to the
  /// last occurrence so `Image.network` doesn't choke.
  static String _fixAvatar(String url) {
    if (url.contains("https://") &&
        url.indexOf("https://") != url.lastIndexOf("https://")) {
      return url.substring(url.lastIndexOf("https://"));
    }
    return url;
  }
}
