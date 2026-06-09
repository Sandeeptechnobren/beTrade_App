import 'dart:convert';
import 'package:flutter/material.dart';
import '../model/category_model.dart';
import '../model/trade_model.dart';
import '../services/category_service.dart';
import '../services/trade_service.dart';
import '../services/local_storage.dart';

/// Drives the Explore tab. One canonical source — GET /trade/list via
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

  ExploreProvider() {
    _loadCachedData();
  }

  void _loadCachedData() {
    final cachedTrades = LocalStorage.getCachedData("explore_trades");
    if (cachedTrades != null) {
      try {
        final List<dynamic> decoded = jsonDecode(cachedTrades);
        trades = decoded.map((e) => TradeModel.fromJson(e)).toList();
      } catch (e) {
        debugPrint("Error decoding cached explore trades: $e");
      }
    }

    final cachedCats = LocalStorage.getCachedData("categories");
    if (cachedCats != null) {
      try {
        final List<dynamic> decoded = jsonDecode(cachedCats);
        categories = decoded.map((e) => CategoryModel.fromJson(e)).toList();
      } catch (e) {
        debugPrint("Error decoding cached categories: $e");
      }
    }
    notifyListeners();
  }

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
      final result = await CategoryService.getCategories();
      if (result.isNotEmpty) {
        categories = result;
        LocalStorage.cacheData("categories", jsonEncode(categories.map((e) => e.toJson()).toList()));
        _safeNotify();
      }
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
      if (reset && trades.isEmpty) {
        isLoading = true;
        error = "";
      } else if (!reset) {
        isLoadingMore = true;
      }
      _safeNotify();

      final res = await TradeService.fetchExplore(
        page: targetPage,
        search: query,
        categoryUuid: selectedCategoryUuid,
      );

      if (reset) {
        trades = res.items;
        // Only cache the first page of default browsing (no search/filter)
        if (query.isEmpty && selectedCategoryUuid == null) {
          LocalStorage.cacheData("explore_trades", jsonEncode(trades.map((e) => e.toJson()).toList()));
        }
      } else {
        trades = [...trades, ...res.items];
      }
      
      _page = res.currentPage;
      _lastPage = res.lastPage;
      error = "";
    } catch (_) {
      // Never surface a raw exception to the UI.
      if (reset && trades.isEmpty) {
        error = "Couldn't load markets. Pull down to retry.";
      }
    } finally {
      isLoading = false;
      isLoadingMore = false;
      _safeNotify();
    }
  }
}
