import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../model/rankings_response.dart';
import '../services/rankings_service.dart';
import '../services/local_storage.dart';

@immutable
class RankingsTabState {
  final RankingsResponse? response;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;

  const RankingsTabState({
    this.response,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
  });
}
class RankingsProvider extends ChangeNotifier {
  static const List<String> categories = [
    'overall',
    'profit',
    'win_rate',
    'hot_streak',
  ];
  static const int pageSize = 25;

  String _category = 'overall';
  String get category => _category;
  final Map<String, RankingsResponse?> _byCat = {
    for (final c in categories) c: null,
  };
  final Map<String, bool> _loading = {for (final c in categories) c: false};
  final Map<String, bool> _loadingMore = {for (final c in categories) c: false};
  final Map<String, String?> _error = {for (final c in categories) c: null};

  RankingsProvider() {
    _loadCachedRankings();
  }

  void _loadCachedRankings() {
    for (final cat in categories) {
      final cached = LocalStorage.getCachedData("rankings_$cat");
      if (cached != null) {
        try {
          _byCat[cat] = RankingsResponse.fromJson(jsonDecode(cached));
        } catch (e) {
          debugPrint("Error decoding cached rankings for $cat: $e");
        }
      }
    }
    notifyListeners();
  }
  RankingsTabState stateFor(String category) => RankingsTabState(
        response: _byCat[category],
        isLoading: _loading[category] ?? false,
        isLoadingMore: _loadingMore[category] ?? false,
        error: _error[category],
      );

  RankingsTabState get currentState => stateFor(_category);
  void setCategory(String category) {
    if (!categories.contains(category) || category == _category) return;
    _category = category;
    notifyListeners();
    if (_byCat[category] == null && !(_loading[category] ?? false)) {
      // Fire-and-forget; the loading flag drives the UI.
      _fetchFirstPage(category);
    }
  }

  Future<void> ensureLoaded() async {
    if (_byCat[_category] == null && !(_loading[_category] ?? false)) {
      await _fetchFirstPage(_category);
    }
  }

  Future<void> refreshFor(String category) => _fetchFirstPage(category);
  Future<void> refreshCurrent() => _fetchFirstPage(_category);
  Future<void> loadMoreFor(String category) async {
    final cur = _byCat[category];
    if (cur == null || !cur.hasMore) return;
    if (_loadingMore[category] == true) return;
    _loadingMore[category] = true;
    notifyListeners();
    try {
      final next = await RankingsService.fetch(
        category: category,
        page: cur.page + 1,
        perPage: pageSize,
      );
      if (next != null) {
        _byCat[category] = RankingsResponse(
          category: cur.category,
          unit: cur.unit,
          podium: cur.podium, // unchanged on load-more
          leaderboard: [...cur.leaderboard, ...next.leaderboard],
          totalUsers: next.totalUsers,
          page: next.page,
          perPage: next.perPage,
          hasMore: next.hasMore,
          currentUserRank: next.currentUserRank ?? cur.currentUserRank,
        );
      }
    } finally {
      _loadingMore[category] = false;
      notifyListeners();
    }
  }

  Future<void> _fetchFirstPage(String cat) async {
    _loading[cat] = true;
    _error[cat] = null;
    notifyListeners();
    try {
      final response = await RankingsService.fetch(
        category: cat,
        page: 1,
        perPage: pageSize,
      );
      if (response == null) {
        if (_byCat[cat] == null) {
          _error[cat] = "Couldn't load rankings. Pull down to retry.";
        }
      } else {
        _byCat[cat] = response;
        LocalStorage.cacheData("rankings_$cat", jsonEncode(response.toJson()));
      }
    } finally {
      _loading[cat] = false;
      notifyListeners();
    }
  }
}
