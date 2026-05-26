import 'package:flutter/foundation.dart';

import '../model/ranking_entry.dart';
import '../services/rankings_service.dart';

/// State holder for the Rankings tab.
///
/// Keeps a per-category cache so switching tabs doesn't re-fetch
/// when the user has already loaded a category in the current
/// session. Pull-to-refresh on a tab forces re-fetch for that
/// category only.
///
/// Loading + error state are tracked per category so the four tabs
/// can show independent UI (one tab can be loading while another
/// shows a populated list).
class RankingsProvider extends ChangeNotifier {
  /// Most-recent response per category, keyed by 'overall' / 'profit' /
  /// 'win_rate' / 'hot_streak'.
  final Map<String, RankingResponse> _cache = {};

  /// Active fetch flag per category — `true` while a fetch is in
  /// flight. Used by the tab UI to show a spinner.
  final Map<String, bool> _loading = {};

  /// Last error message per category (null on success). UI may display.
  final Map<String, String?> _errors = {};

  bool isLoading(String category) => _loading[category] == true;
  String? errorFor(String category) => _errors[category];
  RankingResponse? responseFor(String category) => _cache[category];

  Future<void> fetch({
    required String category,
    bool force = false,
  }) async {
    // Skip if already loaded and caller hasn't requested a force refresh.
    if (!force && _cache.containsKey(category) && _loading[category] != true) {
      return;
    }

    _loading[category] = true;
    _errors[category] = null;
    notifyListeners();

    try {
      final response = await RankingsService.fetch(category: category);
      if (response == null) {
        _errors[category] = 'Could not load rankings. Pull to retry.';
      } else {
        _cache[category] = response;
      }
    } catch (e) {
      debugPrint('RankingsProvider.fetch error: $e');
      _errors[category] = 'Something went wrong.';
    } finally {
      _loading[category] = false;
      notifyListeners();
    }
  }
}
