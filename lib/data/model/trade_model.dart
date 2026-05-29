/// A single tradable side of a market (Yes / No) with its live LMSR price.
/// `currentPrice` is a probability in [0..1]; the two sides sum to ~1.
class OutcomePrice {
  final String slug;
  final String label;
  final double currentPrice;

  OutcomePrice({
    required this.slug,
    required this.label,
    required this.currentPrice,
  });

  factory OutcomePrice.fromJson(Map<String, dynamic> json) {
    final raw = json['current_price'];
    return OutcomePrice(
      slug: json['slug'] ?? "",
      label: json['label'] ?? "",
      currentPrice: raw is num ? raw.toDouble() : (double.tryParse('$raw') ?? 0.0),
    );
  }

  /// Probability as a whole-number percent (0.7006 -> 70).
  int get percent => (currentPrice * 100).round();
}

class TradeModel {
  final int id;
  final String uuid;
  final String categoryName;
  final String description;
  final String minTradeAmount;
  final String? image;
  final String endDate;

  // ── Explore card enrichment (canonical /trade/list) ──────────────
  /// Yes/No outcomes (ordered yes, no) for the probability bar.
  final List<OutcomePrice> outcomes;

  /// Real activity for the social-proof row (no more hardcoded "500K").
  final int totalTrades;
  final String totalTradesDisplay;

  /// Up to 3 recent trader avatar URLs (non-null only).
  final List<String> traderAvatars;

  TradeModel({
    required this.id,
    required this.uuid,
    required this.categoryName,
    required this.description,
    required this.minTradeAmount,
    this.image,
    required this.endDate,
    this.outcomes = const [],
    this.totalTrades = 0,
    this.totalTradesDisplay = "0",
    this.traderAvatars = const [],
  });

  OutcomePrice? _bySlug(String slug) {
    for (final o in outcomes) {
      if (o.slug == slug) return o;
    }
    return null;
  }

  /// YES side (falls back to the first outcome if slugs differ).
  OutcomePrice? get yes =>
      _bySlug('yes') ?? (outcomes.isNotEmpty ? outcomes.first : null);

  /// NO side (falls back to the second outcome).
  OutcomePrice? get no =>
      _bySlug('no') ?? (outcomes.length > 1 ? outcomes[1] : null);

  factory TradeModel.fromJson(Map<String, dynamic> json) {
    final outcomesJson = (json['outcomes'] as List?) ?? const [];
    final tradersJson = (json['traders'] as List?) ?? const [];

    return TradeModel(
      id: json['id'] ?? 0,
      uuid: json['uuid'] ?? "",
      categoryName: json['category_name'] ?? "",
      description: json['description'] ?? "",
      minTradeAmount: "${json['min_trade_amount'] ?? ""}",
      image: json['image'], // nullable allowed (already a full URL from backend)
      endDate: json['end_date'] ?? "",
      outcomes: outcomesJson
          .whereType<Map>()
          .map((e) => OutcomePrice.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      totalTrades: json['total_trades'] is int
          ? json['total_trades'] as int
          : int.tryParse('${json['total_trades'] ?? 0}') ?? 0,
      totalTradesDisplay:
          "${json['total_trades_display'] ?? json['total_trades'] ?? 0}",
      traderAvatars: tradersJson
          .whereType<Map>()
          .map((e) => e['avatar'])
          .whereType<String>()
          .where((s) => s.isNotEmpty)
          .toList(),
    );
  }
}
