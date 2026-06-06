/// One open position from `GET /api/positions` or one row inside the
/// `positions` array of `GET /api/positions/{market_uuid}`.
///
/// All money/price math is computed server-side in PositionController —
/// the Flutter side is a thin display layer.
class PositionModel {
  final double shares;
  final double avgCostGhs;
  final double currentPrice;
  final double costBasisGhs;
  final double marketValueGhs;
  final double unrealisedPnlGhs;
  final double realizedPnlGhs;
  final double maxPayoutGhs;
  // P0-C — closed positions surface these. Open positions return null.
  final double? payoutGhs;       // amount paid out from settlement (winners only)
  final DateTime? settledAt;     // null for open positions
  final DateTime? updatedAt;

  // outcome.* — null only on a malformed row.
  final String outcomeSlug;
  final String outcomeLabel;
  final bool? outcomeIsWinner;

  // market.* — null only when the show() endpoint returns the
  // "summary" view that doesn't include market metadata. The list
  // (index) endpoint always populates these.
  final String? marketUuid;
  final String? marketDescription;
  final String? marketImage;
  final String? marketCategoryName;
  final DateTime? marketClosingDateTime;
  final int? marketStatus; // 1=open, 2=closed, 3=resolved

  PositionModel({
    required this.shares,
    required this.avgCostGhs,
    required this.currentPrice,
    required this.costBasisGhs,
    required this.marketValueGhs,
    required this.unrealisedPnlGhs,
    required this.realizedPnlGhs,
    required this.maxPayoutGhs,
    required this.outcomeSlug,
    required this.outcomeLabel,
    this.outcomeIsWinner,
    this.payoutGhs,
    this.settledAt,
    this.updatedAt,
    this.marketUuid,
    this.marketDescription,
    this.marketImage,
    this.marketCategoryName,
    this.marketClosingDateTime,
    this.marketStatus,
  });

  /// Decode one row from the backend response.
  factory PositionModel.fromJson(Map<String, dynamic> json) {
    final outcome = json['outcome'];
    final market = json['market'];

    return PositionModel(
      shares: _double(json['shares']),
      avgCostGhs: _double(json['avg_cost_ghs']),
      currentPrice: _double(json['current_price']),
      costBasisGhs: _double(json['cost_basis_ghs']),
      marketValueGhs: _double(json['market_value_ghs']),
      unrealisedPnlGhs: _double(json['unrealised_pnl_ghs']),
      realizedPnlGhs: _double(json['realized_pnl_ghs']),
      maxPayoutGhs: _double(json['max_payout_ghs']),
      payoutGhs: json['payout_ghs'] == null ? null : _double(json['payout_ghs']),
      settledAt: _parseDate(json['settled_at']),
      updatedAt: _parseDate(json['updated_at']),
      outcomeSlug: outcome is Map ? outcome['slug']?.toString() ?? '' : '',
      outcomeLabel: outcome is Map ? outcome['label']?.toString() ?? '' : '',
      outcomeIsWinner: outcome is Map ? outcome['is_winner'] as bool? : null,
      marketUuid: market is Map ? market['uuid']?.toString() : null,
      marketDescription:
          market is Map ? market['description']?.toString() : null,
      marketImage: market is Map ? market['image']?.toString() : null,
      marketCategoryName:
          market is Map ? market['category_name']?.toString() : null,
      marketClosingDateTime:
          market is Map ? _parseDate(market['closing_date_time']) : null,
      marketStatus:
          market is Map ? (market['status'] as num?)?.toInt() : null,
    );
  }

  /// True if YES (the conventional "buy yes" case). Used for accent
  /// colour in the position card.
  bool get isYes => outcomeSlug.toLowerCase() == 'yes';

  /// Derived percent-change vs cost basis. Returns 0 when costBasis is 0.
  double get unrealisedPnlPct {
    if (costBasisGhs == 0) return 0;
    return (unrealisedPnlGhs / costBasisGhs) * 100;
  }

  static double _double(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString());
  }
}

/// Wrapper for `GET /api/positions/{market_uuid}` — both sides of one
/// market plus the market metadata.
class MarketPositionsModel {
  final String marketUuid;
  final String description;
  final List<PositionModel> sides;

  MarketPositionsModel({
    required this.marketUuid,
    required this.description,
    required this.sides,
  });

  factory MarketPositionsModel.fromJson(Map<String, dynamic> json) {
    final positions = json['positions'];
    return MarketPositionsModel(
      marketUuid: json['market_uuid']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      sides: positions is List
          ? positions
              .whereType<Map>()
              .map((m) => PositionModel.fromJson(Map<String, dynamic>.from(m)))
              .toList()
          : [],
    );
  }
}
