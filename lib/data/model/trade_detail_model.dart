/// DTO for `GET /trade/view/{uuid}` response `data` payload.
///
/// Defensive defaults match the existing project pattern (see
/// `trade_model.dart`) so a missing field never throws — it surfaces
/// as an empty string / 0 / null and the UI degrades gracefully.
///
/// Fields populated from the API today (confirmed):
///   uuid, title, description, category_name, current_price_per_share
///
/// Fields used by the new Details screen — names are best-guess and
/// fall through to multiple aliases. Confirm with backend and prune
/// the aliases once the canonical name is known. Hardcoded fallbacks
/// live in the UI (see [TradeDetailsPage]) — tracked in
/// `tasks/todo.md` under "Phase 2.6 / Details screen — backend gaps".
class TradeDetailModel {
  final String uuid;
  final String title;
  final String description;
  final String categoryName;
  final double currentPricePerShare;

  // Optional metadata for the Details screen. Null when the backend
  // doesn't return them — UI shows a hardcoded fallback in that case.
  final String? marketStatus; // "open" / "closed" / "resolved"
  final double? totalVolumeGhs;
  final double? liquidityGhs;
  final String? closesAt; // ISO date string OR human-readable
  final String? resolutionSource;

  TradeDetailModel({
    required this.uuid,
    required this.title,
    required this.description,
    required this.categoryName,
    required this.currentPricePerShare,
    this.marketStatus,
    this.totalVolumeGhs,
    this.liquidityGhs,
    this.closesAt,
    this.resolutionSource,
  });

  factory TradeDetailModel.fromJson(Map<String, dynamic> json) {
    double? n(dynamic v) => v is num ? v.toDouble() : null;

    return TradeDetailModel(
      uuid: json['uuid']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      categoryName: json['category_name']?.toString() ?? '',
      currentPricePerShare:
          double.tryParse('${json['current_price_per_share']}') ?? 0,
      marketStatus: json['market_status']?.toString() ??
          json['status']?.toString(),
      totalVolumeGhs: n(json['total_volume_ghs']) ?? n(json['total_volume']),
      liquidityGhs: n(json['liquidity_ghs']) ?? n(json['liquidity']),
      closesAt: json['closes_at']?.toString() ?? json['end_date']?.toString(),
      resolutionSource: json['resolution_source']?.toString(),
    );
  }
}
