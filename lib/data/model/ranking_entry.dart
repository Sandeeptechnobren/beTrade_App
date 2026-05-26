/// One row in the rankings leaderboard or one cell in the podium.
///
/// Backend envelope shape (from `RankingsService::leaderboard`):
///   {
///     rank, user_id, name, avatar, thumbnail,
///     value, is_current_user?, movement
///   }
///
/// `value` is interpreted based on the category's `unit`:
///   - overall   → integer trade count
///   - profit    → GHS decimal
///   - win_rate  → integer percent
///   - hot_streak → integer days
///
/// `movement` is one of `'up'`, `'down'`, `'none'` — for now backend
/// always returns `'none'` (movement indicator deferred to phase 2).
class RankingEntry {
  final int rank;
  final int userId;
  final String name;
  final String? avatar;
  final String? thumbnail;
  final double value;
  final bool isCurrentUser;
  final String movement;

  const RankingEntry({
    required this.rank,
    required this.userId,
    required this.name,
    required this.avatar,
    required this.thumbnail,
    required this.value,
    required this.isCurrentUser,
    required this.movement,
  });

  /// Best URL for showing this user's avatar in a small circle.
  /// Mirrors ProfileModel.displayAvatar.
  String get displayAvatar {
    final t = thumbnail?.trim() ?? '';
    if (t.isNotEmpty) return t;
    return avatar?.trim() ?? '';
  }

  factory RankingEntry.fromJson(Map<String, dynamic> json) {
    double parseValue(dynamic v) {
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0;
      return 0;
    }

    return RankingEntry(
      rank: (json['rank'] is num) ? (json['rank'] as num).toInt() : 0,
      userId: (json['user_id'] is num) ? (json['user_id'] as num).toInt() : 0,
      name: (json['name'] ?? '').toString(),
      avatar: json['avatar']?.toString(),
      thumbnail: json['thumbnail']?.toString(),
      value: parseValue(json['value']),
      isCurrentUser: json['is_current_user'] == true,
      movement: (json['movement'] ?? 'none').toString(),
    );
  }
}

/// Envelope returned by `GET /api/rankings`.
class RankingResponse {
  final String category;
  final String unit;
  final List<RankingEntry> podium;
  final List<RankingEntry> leaderboard;
  final int totalUsers;
  final int? currentUserRank;
  final int page;
  final int perPage;
  final bool hasMore;

  const RankingResponse({
    required this.category,
    required this.unit,
    required this.podium,
    required this.leaderboard,
    required this.totalUsers,
    required this.currentUserRank,
    required this.page,
    required this.perPage,
    required this.hasMore,
  });

  factory RankingResponse.fromJson(Map<String, dynamic> json) {
    List<RankingEntry> parseList(dynamic raw) {
      if (raw is! List) return const [];
      return raw
          .whereType<Map>()
          .map((m) => RankingEntry.fromJson(Map<String, dynamic>.from(m)))
          .toList();
    }

    return RankingResponse(
      category: (json['category'] ?? 'overall').toString(),
      unit: (json['unit'] ?? '').toString(),
      podium: parseList(json['podium']),
      leaderboard: parseList(json['leaderboard']),
      totalUsers: (json['total_users'] is num)
          ? (json['total_users'] as num).toInt()
          : 0,
      currentUserRank: (json['current_user_rank'] is num)
          ? (json['current_user_rank'] as num).toInt()
          : null,
      page: (json['page'] is num) ? (json['page'] as num).toInt() : 1,
      perPage: (json['per_page'] is num)
          ? (json['per_page'] as num).toInt()
          : 50,
      hasMore: json['has_more'] == true,
    );
  }

  /// Format a `value` for display based on the category unit.
  String formatValue(double value) {
    switch (unit) {
      case 'GHS':
        // Use ₵ glyph + K-suffix for large amounts (matches Figma "₵12.5k")
        if (value.abs() >= 1000) {
          final k = (value / 1000);
          // 1 decimal place if not a whole number, else integer
          return '₵${k.toStringAsFixed(k.truncateToDouble() == k ? 0 : 1)}k';
        }
        return '₵${value.toStringAsFixed(2)}';
      case '%':
        return '${value.toStringAsFixed(0)}%';
      case 'days':
        final n = value.toInt();
        return '$n ${n == 1 ? 'day' : 'days'}';
      case 'trades':
      default:
        return '${value.toInt()} trades';
    }
  }
}
