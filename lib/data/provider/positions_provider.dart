import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../model/position_model.dart';
import '../services/positions_service.dart';
import '../services/local_storage.dart';

/// State holder for the Portfolio Open Positions list and the
class PositionsProvider extends ChangeNotifier {
  // Open positions list
  List<PositionModel> openPositions = [];
  bool isLoadingOpen = false;
  String? openError;

  // P0-C — closed (settled) positions list
  List<PositionModel> settledPositions = [];
  bool isLoadingSettled = false;
  String? settledError;

  // Per-market detail (keyed by market UUID so revisits are cheap).
  final Map<String, MarketPositionsModel> _detailCache = {};
  bool isLoadingDetail = false;
  String? detailError;

  bool _isDisposed = false;

  PositionsProvider() {
    _loadCachedPositions();
  }

  void _loadCachedPositions() {
    final cachedOpen = LocalStorage.getCachedData("open_positions");
    if (cachedOpen != null) {
      try {
        final List<dynamic> decoded = jsonDecode(cachedOpen);
        openPositions = decoded.map((e) => PositionModel.fromJson(e)).toList();
      } catch (e) {
        debugPrint("Error decoding cached open positions: $e");
      }
    }

    final cachedSettled = LocalStorage.getCachedData("settled_positions");
    if (cachedSettled != null) {
      try {
        final List<dynamic> decoded = jsonDecode(cachedSettled);
        settledPositions = decoded.map((e) => PositionModel.fromJson(e)).toList();
      } catch (e) {
        debugPrint("Error decoding cached settled positions: $e");
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

  /// GET /api/positions?status=open
  Future<void> fetchOpenPositions() async {
    if (openPositions.isEmpty) {
      isLoadingOpen = true;
      _safeNotify();
    }
    openError = null;

    final list = await PositionsService.getAll(status: 'open');

    if (list.isNotEmpty || openPositions.isEmpty) {
      openPositions = list;
      LocalStorage.cacheData("open_positions", jsonEncode(openPositions.map((e) => e.toJson()).toList()));
    }
    
    isLoadingOpen = false;
    _safeNotify();
  }

  /// GET /api/positions?status=settled (P0-C, 2026-05-28)
  Future<void> fetchSettledPositions() async {
    if (settledPositions.isEmpty) {
      isLoadingSettled = true;
      _safeNotify();
    }
    settledError = null;

    final list = await PositionsService.getAll(status: 'settled');

    if (list.isNotEmpty || settledPositions.isEmpty) {
      settledPositions = list;
      LocalStorage.cacheData("settled_positions", jsonEncode(settledPositions.map((e) => e.toJson()).toList()));
    }

    isLoadingSettled = false;
    _safeNotify();
  }

  /// GET /api/positions/{market_uuid}
  /// Returns the cached value if [forceRefresh] is false and a
  /// previous fetch succeeded. Pull-to-refresh callers pass true.
  Future<MarketPositionsModel?> fetchMarketDetail(
    String marketUuid, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _detailCache.containsKey(marketUuid)) {
      return _detailCache[marketUuid];
    }

    isLoadingDetail = true;
    detailError = null;
    _safeNotify();

    final detail = await PositionsService.getForMarket(marketUuid);


    if (detail != null) {
      _detailCache[marketUuid] = detail;
    } else {
      detailError = 'Could not load position detail.';
    }

    isLoadingDetail = false;
    _safeNotify();
    return detail;
  }

  /// Read the cached detail without triggering a fetch — useful for
  /// the position detail screen build() so it can render synchronously
  /// after the fetchMarketDetail() future has resolved.
  MarketPositionsModel? cachedDetail(String marketUuid) =>
      _detailCache[marketUuid];

  /// Total cost basis across all open positions — convenient summary
  /// for the portfolio header.
  double get totalCostBasisGhs =>
      openPositions.fold(0.0, (sum, p) => sum + p.costBasisGhs);

  /// Total unrealised P&L across all open positions.
  double get totalUnrealisedPnlGhs =>
      openPositions.fold(0.0, (sum, p) => sum + p.unrealisedPnlGhs);

  /// Total current market value of all open positions.
  double get totalMarketValueGhs =>
      openPositions.fold(0.0, (sum, p) => sum + p.marketValueGhs);
}
