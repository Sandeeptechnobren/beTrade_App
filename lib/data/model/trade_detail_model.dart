/// DTO for `GET /trade/view/{uuid}` response `data` payload.
///
/// Captures only the fields used by the trade detail screen today.
/// Defensive defaults match the existing project pattern (see
/// `trade_model.dart`) so a missing field never throws — it surfaces
/// as an empty string or 0 and the UI degrades gracefully.
class TradeDetailModel {
  final String uuid;
  final String title;
  final String description;
  final String categoryName;
  final double currentPricePerShare;

  TradeDetailModel({
    required this.uuid,
    required this.title,
    required this.description,
    required this.categoryName,
    required this.currentPricePerShare,
  });

  factory TradeDetailModel.fromJson(Map<String, dynamic> json) {
    return TradeDetailModel(
      uuid: json['uuid']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      categoryName: json['category_name']?.toString() ?? '',
      currentPricePerShare:
          double.tryParse('${json['current_price_per_share']}') ?? 0,
    );
  }
}
