
class TradeModel {
  final String uuid;
  final String categoryName;
  final String description;
  final String minTradeAmount;
  final String? image;
  final String endDate;

  TradeModel({
    required this.uuid,
    required this.categoryName,
    required this.description,
    required this.minTradeAmount,
    this.image,
    required this.endDate,
  });

  factory TradeModel.fromJson(Map<String, dynamic> json) {
    return TradeModel(
      uuid: json['uuid'] ?? "",
      categoryName: json['category_name'] ?? "",
      description: json['description'] ?? "",
      minTradeAmount: json['min_trade_amount'] ?? "",
      image: json['image'], // nullable allowed
      endDate: json['end_date'] ?? "",
    );
  }
}