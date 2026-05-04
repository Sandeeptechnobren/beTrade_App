class DefaultSettingsModel {
  final int? userId;
  final int minDefaultAmount;
  final int maxDefaultAmount;

  DefaultSettingsModel({
    this.userId,
    required this.minDefaultAmount,
    required this.maxDefaultAmount,
  });

  factory DefaultSettingsModel.fromJson(Map<String, dynamic> json) {
    return DefaultSettingsModel(
      userId: _parseIntOrNull(json['user_id']),
      minDefaultAmount: _parseInt(json['default_amount'], 100),
      maxDefaultAmount: _parseInt(json['max_default_amount'], 1000),
    );
  }

  static int _parseInt(dynamic v, int fallback) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) {
      // Backend may send "60.00" (decimal string). int.tryParse rejects
      // those; route through num.tryParse so "60.00" → 60.0 → 60.
      return num.tryParse(v)?.toInt() ?? fallback;
    }
    return fallback;
  }

  static int? _parseIntOrNull(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }
}
