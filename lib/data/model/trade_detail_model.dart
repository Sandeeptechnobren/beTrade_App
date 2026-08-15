/// DTO for `GET /trade/view/{uuid}` response `data` payload.
///
/// Defensive defaults match the existing project pattern (see
/// `trade_model.dart`) so a missing field never throws — it surfaces
/// as an empty string / 0 / null and the UI degrades gracefully.
///
/// Field-name aliases on every numeric / textual field — the backend
/// `tradeView` service returns `current_price`, `total_volume`,
/// `liquidity`, `closing_date_time`, `resolution_sources` (plural),
/// `status`, while the original flutter audit used the longer
/// `_ghs` suffix / `_at` postfix names. We accept both shapes so the
/// model parses cleanly without a backend rename.
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
  final String? closesAt; // formatted for display; see _formatClosesAt
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
    double? n(dynamic v) {
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    return TradeDetailModel(
      uuid: (json['uuid'] ?? json['trade_uuid'])?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      categoryName: json['category_name']?.toString() ?? '',
      // Backend may return `current_price_per_share`, `current_price`,
      // or `price_per_share` depending on which service path served
      // the response — accept all three.
      currentPricePerShare: n(json['current_price_per_share']) ??
          n(json['current_price']) ??
          n(json['price_per_share']) ??
          0,
      marketStatus:
          json['market_status']?.toString() ?? json['status']?.toString(),
      totalVolumeGhs: n(json['total_volume_ghs']) ?? n(json['total_volume']),
      liquidityGhs: n(json['liquidity_ghs']) ?? n(json['liquidity']),
      closesAt: _formatClosesAt(
        json['closes_at']?.toString() ??
            json['closing_date_time']?.toString() ??
            json['end_date']?.toString(),
      ),
      // Backend returns `resolution_sources` (plural) from
      // TradeDetailService.tradeView. Accept singular for backwards
      // compat too.
      resolutionSource: json['resolution_source']?.toString() ??
          json['resolution_sources']?.toString(),
    );
  }

  /// Convert backend ISO datetime (`2026-12-31 23:59:00` or
  /// `2026-12-31T23:59:00Z`) into the Figma-style display:
  /// `31/12/2026 • 11:59PM ET`.
  ///
  /// Falls back to the raw string if parsing fails so the user at
  /// least sees what the backend sent. Time-zone is rendered as a
  /// static "ET" suffix to match the Figma — the backend is currently
  /// in UTC and we don't have a per-user TZ field yet.
  static String? _formatClosesAt(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    DateTime? dt;
    try {
      dt = DateTime.parse(raw);
    } catch (_) {
      return raw; // unrecognised format — surface as-is
    }

    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    final yyyy = dt.year.toString();

    final hour24 = dt.hour;
    final ampm = hour24 >= 12 ? 'PM' : 'AM';
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    final minutes = dt.minute.toString().padLeft(2, '0');

    return '$dd/$mm/$yyyy • $hour12:$minutes$ampm ET';
  }
}
