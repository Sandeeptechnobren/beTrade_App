import 'package:flutter/foundation.dart';

import '../model/rankings_response.dart';
import '../services/rankings_service.dart';

/// Snapshot of one category's state — exposed by [RankingsProvider.stateFor]
/// so the screen can render each tab independently.
@immutable
class RankingsTabState {
  final RankingsResponse? response;
  final bool isLoading;       // first-page fetch in flight
  final bool isLoadingMore;   // pagination fetch in flight
  final String? error;

  const RankingsTabState({
    this.response,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
  });
}

/// Per-category state cache so switching tabs is instant after first
/// load. Each category caches its current page + accumulated leaderboard
/// list (for infinite scroll); podium is replaced on each refresh.
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

  // Per-category state maps. A null entry in `_byCat` means "not loaded
  // yet" (different from "loaded, empty leaderboard").
  final Map<String, RankingsResponse?> _byCat = {
    for (final c in categories) c: null,
  };
  final Map<String, bool> _loading = {for (final c in categories) c: false};
  final Map<String, bool> _loadingMore = {for (final c in categories) c: false};
  final Map<String, String?> _error = {for (final c in categories) c: null};

  /// Snapshot for the given category — safe to call for any of the
  /// four supported strings.
  RankingsTabState stateFor(String category) => RankingsTabState(
        response: _byCat[category],
        isLoading: _loading[category] ?? false,
        isLoadingMore: _loadingMore[category] ?? false,
        error: _error[category],
      );

  /// Shortcut for the currently-active category.
  RankingsTabState get currentState => stateFor(_category);

  /// Switch to a different tab. Triggers a first-page fetch lazily on
  /// the new category (no-op if already loaded or in flight).
  void setCategory(String category) {
    if (!categories.contains(category) || category == _category) return;
    _category = category;
    notifyListeners();
    if (_byCat[category] == null && !(_loading[category] ?? false)) {
      // Fire-and-forget; the loading flag drives the UI.
      _fetchFirstPage(category);
    }
  }

  /// First-time load for the active category. Idempotent: safe to call
  /// from `initState`.
  Future<void> ensureLoaded() async {
    if (_byCat[_category] == null && !(_loading[_category] ?? false)) {
      await _fetchFirstPage(_category);
    }
  }

  /// Pull-to-refresh — always re-fetches page 1.
  Future<void> refreshFor(String category) => _fetchFirstPage(category);

  /// Re-fetch the currently-active category — used to auto-refresh when the
  /// Rankings tab is (re)opened so avatars/counts stay fresh without a pull.
  Future<void> refreshCurrent() => _fetchFirstPage(_category);

  /// Infinite-scroll: append the next page of leaderboard rows. No-op
  /// when the current category has no more pages or a fetch is already
  /// in flight.
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
        _error[cat] = "Couldn't load rankings. Pull down to retry.";
      } else {
        _byCat[cat] = response;
      }
    } finally {
      _loading[cat] = false;
      notifyListeners();
    }
  }
}
