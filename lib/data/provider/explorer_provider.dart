import 'package:flutter/material.dart';
import '../model/category_model.dart';
import '../model/trade_model.dart';
import '../services/category_service.dart';
import '../services/trade_service.dart';

/// Drives the Explore tab. One canonical source — GET /trade/list via
/// [TradeService.fetchExplore] — powers the base list, text search,
/// category filter, and infinite-scroll pagination.
class ExploreProvider extends ChangeNotifier {
  /// Markets currently displayed (already server-filtered + paginated).
  List<TradeModel> trades = [];

  /// Category filter chips ("All" + these). Loaded once, best-effort.
  List<CategoryModel> categories = [];

  /// null = "All". Otherwise the selected category uuid.
  String? selectedCategoryUuid;

  /// First-page / reload spinner.
  bool isLoading = false;

  /// Appending the next page (footer spinner).
  bool isLoadingMore = false;

  /// User-friendly error (never a raw exception string).
  String error = "";

  /// Current search text ("" = browsing).
  String query = "";

  int _page = 1;
  int _lastPage = 1;
  bool _isDisposed = false;

  bool get isSearchMode => query.trim().isNotEmpty;
  bool get hasMore => _page < _lastPage;
  bool get isEmpty => trades.isEmpty;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _safeNotify() {
    if (!_isDisposed) notifyListeners();
  }

  /// Initial load for the tab. Also lazily loads the category chips.
  Future<void> fetchExploreTrades() async {
    if (categories.isEmpty) {
      _loadCategories(); // fire-and-forget — chips fill in when ready
    }
    await _load(reset: true);
  }

  Future<void> _loadCategories() async {
    try {
      categories = await CategoryService.getCategories();
      _safeNotify();
    } catch (_) {
      // Chips are optional — never block the list on them.
    }
  }

  Future<void> selectCategory(String? uuid) async {
    selectedCategoryUuid = (uuid == null || uuid == 'all') ? null : uuid;
    await _load(reset: true);
  }

  Future<void> searchTrades(String q) async {
    query = q;
    await _load(reset: true);
  }

  Future<void> clearSearch() async {
    if (query.isEmpty) return;
    query = "";
    await _load(reset: true);
  }

  Future<void> loadMore() async {
    if (isLoading || isLoadingMore || !hasMore) return;
    await _load(reset: false);
  }

  Future<void> _load({required bool reset}) async {
    final targetPage = reset ? 1 : _page + 1;
    try {
      if (reset) {
        isLoading = true;
        error = "";
      } else {
        isLoadingMore = true;
      }
      _safeNotify();

      // QA #4 — request popularity-ranked ordering. Backend serves it via
      // `?sort=trending` (older backends ignore the param and keep the
      // legacy newest-first ordering, so this is forward-compatible).
      final res = await TradeService.fetchExplore(
        page: targetPage,
        search: query,
        categoryUuid: selectedCategoryUuid,
        sort: 'trending',
      );

      trades = reset ? res.items : [...trades, ...res.items];
      // Defensive client-side sort: if the deployed backend hasn't
      // picked up the `sort=trending` handler yet, the items come back
      // newest-first. At current data volumes (page=20 typically covers
      // every open market) sorting the already-loaded list by trade
      // count still surfaces the correct top-N. Once backend deploys,
      // this becomes a no-op (already-sorted input → stable sort).
      trades.sort((a, b) => (b.totalTrades).compareTo(a.totalTrades));
      _page = res.currentPage;
      _lastPage = res.lastPage;
      error = "";
    } catch (_) {
      // Never surface a raw exception to the UI.
      if (reset) trades = [];
      error = "Couldn't load markets. Pull down to retry.";
    } finally {
      isLoading = false;
      isLoadingMore = false;
      _safeNotify();
    }
  }
}
