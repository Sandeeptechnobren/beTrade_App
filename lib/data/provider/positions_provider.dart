import 'package:flutter/foundation.dart';

import '../model/position_model.dart';
import '../services/positions_service.dart';

/// State holder for the Portfolio Open Positions list and the
/// per-market position detail screen. Single instance lives in
/// main.dart's MultiProvider; consumed via Consumer / context.watch in:
///   - portfolio_page.dart       (Open Positions list)
///   - position_detail_page.dart (both-sides breakdown)
class PositionsProvider extends ChangeNotifier {
  // Open positions list
  List<PositionModel> openPositions = [];
  bool isLoadingOpen = false;
  String? openError;

  // Per-market detail (keyed by market UUID so revisits are cheap).
  final Map<String, MarketPositionsModel> _detailCache = {};
  bool isLoadingDetail = false;
  String? detailError;

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _safeNotify() {
    if (!_isDisposed) notifyListeners();
  }

  /// GET /api/positions
  Future<void> fetchOpenPositions() async {
    isLoadingOpen = true;
    openError = null;
    _safeNotify();

    final list = await PositionsService.getAll();

    openPositions = list;
    isLoadingOpen = false;
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
