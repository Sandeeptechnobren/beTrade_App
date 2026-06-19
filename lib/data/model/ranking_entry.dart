import '../../core/config/env_config.dart';

/// One row in a rankings list — either a podium slot (rank 1-3) or a
/// leaderboard list entry (rank 4+). Backend builds this in
/// `App\Services\RankingsService::shapeRows`; see api/rankings.
///
/// The `value` field is unit-erased — interpret it via [RankingsResponse.unit]:
///   - `overall`    → integer trade count
///   - `profit`     → double GHS (can be negative)
///   - `win_rate`   → integer percent
///   - `hot_streak` → integer days
class RankingEntry {
  final int userId;
  final String name;
  final String? avatarUrl;
  final String? thumbnailUrl;
  final double value;
  final int rank;
  final String movement; // 'none' | 'up' | 'down' | 'same' (v1: always 'none')
  final bool isCurrentUser;

  const RankingEntry({
    required this.userId,
    required this.name,
    this.avatarUrl,
    this.thumbnailUrl,
    required this.value,
    required this.rank,
    required this.movement,
    required this.isCurrentUser,
  });

  factory RankingEntry.fromJson(Map<String, dynamic> json) {
    return RankingEntry(
      userId: _int(json['user_id']),
      name: (json['name'] ?? 'Trader').toString(),
      avatarUrl: _resolveImageUrl(json['avatar']?.toString()),
      thumbnailUrl: _resolveImageUrl(json['thumbnail']?.toString()),
      value: _double(json['value']),
      rank: _int(json['rank']),
      movement: (json['movement'] ?? 'none').toString(),
      isCurrentUser: json['is_current_user'] == true,
    );
  }

  /// Best image for list rows — thumbnail when present, fallback to the
  /// full avatar. Either or both can be null.
  String? get displayImageUrl => thumbnailUrl ?? avatarUrl;

  static int _int(dynamic v) =>
      v is int ? v : (v is num ? v.toInt() : int.tryParse(v?.toString() ?? '') ?? 0);
  static double _double(dynamic v) =>
      v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0.0;

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'avatar': avatarUrl,
      'thumbnail': thumbnailUrl,
      'value': value,
      'rank': rank,
      'movement': movement,
      'is_current_user': isCurrentUser,
    };
  }

  /// The backend's `/api/profile` returns avatar as a full
  /// `https://…/storage/…` URL (built via Laravel `asset()`); but
  /// `/api/rankings` currently returns the raw `avatars/original/123.png`
  /// path from `users.avatar`. Handle both so we stay robust to either
  /// convention.
  static String? _resolveImageUrl(String? raw) {
    if (raw == null) return null;
    final s = raw.trim();
    if (s.isEmpty) return null;
    if (s.startsWith('http://') || s.startsWith('https://')) return s;
    // EnvConfig.baseUrl is the .env BASE_URL (typically
    // `https://api.buildacademy.io/projects/betrade/public/api`).
    // Storage files live alongside it at `…/public/storage/…`.
    final apiBase = EnvConfig.baseUrl;
    final storageBase =
        apiBase.replaceFirst(RegExp(r'/api/?$'), '/storage');
    final path = s.replaceFirst(RegExp(r'^/+'), '');
    return '$storageBase/$path';
  }
}
