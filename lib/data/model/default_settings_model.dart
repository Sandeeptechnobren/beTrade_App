/// DTO for the `userDefaultSettings/list` response.
///
/// Backend shape:
/// ```
/// {
///   "user_id": 14,
///   "min_default_amount": 100,
///   "max_default_amount": 1000
/// }
/// ```
///
/// `min_default_amount` is the user's pre-fill / "Default Amount".
/// `max_default_amount` is the upper limit (displayed disabled in the UI).
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
      minDefaultAmount: _parseInt(json['min_default_amount'], 100),
      maxDefaultAmount: _parseInt(json['max_default_amount'], 1000),
    );
  }

  static int _parseInt(dynamic v, int fallback) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? fallback;
    return fallback;
  }

  static int? _parseIntOrNull(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }
}
