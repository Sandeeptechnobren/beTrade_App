/// A single achievement from GET /achievement-levels, with the caller's
/// earned flag + progress toward the threshold.
class AchievementModel {
  final String key;
  final String name;
  final String description;
  final String icon;
  final bool earned;
  final String? unlockedAt;
  final double progressCurrent;
  final double progressTarget;
  final int progressPct;

  AchievementModel({
    required this.key,
    required this.name,
    required this.description,
    required this.icon,
    required this.earned,
    this.unlockedAt,
    this.progressCurrent = 0,
    this.progressTarget = 0,
    this.progressPct = 0,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    final p = (json['progress'] is Map)
        ? Map<String, dynamic>.from(json['progress'] as Map)
        : const <String, dynamic>{};
    double d(dynamic v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0.0;

    return AchievementModel(
      key: json['key'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
      earned: json['earned'] == true,
      unlockedAt: json['unlocked_at'],
      progressCurrent: d(p['current']),
      progressTarget: d(p['target']),
      progressPct: (p['pct'] is num) ? (p['pct'] as num).round() : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'name': name,
      'description': description,
      'icon': icon,
      'earned': earned,
      'unlocked_at': unlockedAt,
      'progress': {
        'current': progressCurrent,
        'target': progressTarget,
        'pct': progressPct,
      },
    };
  }

  /// "3/10" style label for the progress under a locked badge.
  String get progressLabel {
    final cur = progressCurrent == progressCurrent.roundToDouble()
        ? progressCurrent.toStringAsFixed(0)
        : progressCurrent.toStringAsFixed(1);
    final tgt = progressTarget == progressTarget.roundToDouble()
        ? progressTarget.toStringAsFixed(0)
        : progressTarget.toStringAsFixed(1);
    return '$cur/$tgt';
  }
}
