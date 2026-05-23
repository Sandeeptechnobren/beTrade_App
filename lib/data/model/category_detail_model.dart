class MarketCardModel {
  final int totalTrades;
  final int yesPercentage;
  final int noPercentage;
  final List<UserImage> users;

  MarketCardModel({
    required this.totalTrades,
    required this.yesPercentage,
    required this.noPercentage,
    required this.users,
  });

  factory MarketCardModel.fromJson(Map<String, dynamic> json) {
    return MarketCardModel(
      totalTrades: _parseInt(json['total_trades']),
      yesPercentage: _parseInt(json['yes_percentage']),
      noPercentage: _parseInt(json['no_percentage']),
      users: (json['users'] as List?)
          ?.map((e) => UserImage.fromJson(e))
          .toList() ??
          [],
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;

    if (value is int) return value;

    return int.tryParse(value.toString()) ?? 0;
  }
}

class UserImage {
  final String image;

  UserImage({
    required this.image,
  });

  factory UserImage.fromJson(Map<String, dynamic> json) {
    return UserImage(
      image: json['image'] ?? "",
    );
  }
}