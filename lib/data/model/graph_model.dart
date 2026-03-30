class ChartData {
  final double x;
  final double y;

  ChartData({required this.x, required this.y});

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      x: (json['time']).toDouble(),
      y: (json['value']).toDouble(),
    );
  }
}