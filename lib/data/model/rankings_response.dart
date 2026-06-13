import 'ranking_entry.dart';

/// Envelope returned by `GET /api/rankings?category=…&page=…`.
/// Matches `App\Services\RankingsService::leaderboard`.
class RankingsResponse {
  /// 'overall' | 'profit' | 'win_rate' | 'hot_streak'
  final String category;

  /// Unit suffix for [RankingEntry.value]:
  /// 'trades' | 'GHS' | '%' | 'days'.
  final String unit;

  /// Top 3, re-ordered by the backend to [#2, #1, #3] so the UI can
  /// render middle-#1 / left-#2 / right-#3 straight from this list.
  final List<RankingEntry> podium;

  /// Ranks 4+ for the current page (size = perPage).
  final List<RankingEntry> leaderboard;

  /// Total ranked users across the leaderboard (capped at the backend
  /// `RANK_CAP` of 1000 in v1).
  final int totalUsers;
  final int page;
  final int perPage;
  final bool hasMore;

  /// The signed-in user's rank in this category. Null when they have
  /// no qualifying activity. Populated by the backend over the FULL
  /// ranked list — works even when the user is on page 5 of the
  /// leaderboard.
  final int? currentUserRank;

  const RankingsResponse({
    required this.category,
    required this.unit,
    required this.podium,
    required this.leaderboard,
    required this.totalUsers,
    required this.page,
    required this.perPage,
    required this.hasMore,
    this.currentUserRank,
  });

  factory RankingsResponse.fromJson(Map<String, dynamic> json) {
    // Accept both `{data: {...}}` envelope or the inner data shape.
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;
    return RankingsResponse(
      category: (data['category'] ?? 'overall').toString(),
      unit: (data['unit'] ?? '').toString(),
      podium: _parseList(data['podium']),
      leaderboard: _parseList(data['leaderboard']),
      totalUsers: _int(data['total_users']),
      page: _int(data['page']) <= 0 ? 1 : _int(data['page']),
      perPage: _int(data['per_page']) <= 0 ? 50 : _int(data['per_page']),
      hasMore: data['has_more'] == true,
      currentUserRank: data['current_user_rank'] is num
          ? (data['current_user_rank'] as num).toInt()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'unit': unit,
      'podium': podium.map((e) => e.toJson()).toList(),
      'leaderboard': leaderboard.map((e) => e.toJson()).toList(),
      'total_users': totalUsers,
      'page': page,
      'per_page': perPage,
      'has_more': hasMore,
      'current_user_rank': currentUserRank,
    };
  }

  static int _int(dynamic v) =>
      v is int ? v : (v is num ? v.toInt() : 0);

  static List<RankingEntry> _parseList(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => RankingEntry.fromJson(Map<String, dynamic>.from(e)))
        .toList(growable: false);
  }
}
