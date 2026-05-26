import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../core/config/api_endpoint.dart';
import '../../core/network/dio_client.dart';

/// One bucketed price sample returned by `GET /api/trade/{uuid}/chart`.
///
/// Backend already buckets the raw `price_snapshots` table per range
/// (5 min for 1D, 1 hour for 1W, 4 hour for 1M, 1 day for 1Y/MAX) so
/// the client doesn't need to do any aggregation — just plot the
/// returned points.
class ChartPoint {
  /// Bucket-start timestamp.
  final DateTime t;

  /// LMSR price for the outcome at that bucket, range `[0, 1]`.
  /// Multiply by 100 for a percentage on the Y axis.
  final double price;

  const ChartPoint({required this.t, required this.price});

  factory ChartPoint.fromJson(Map<String, dynamic> json) {
    final raw = json['t'];
    DateTime parsed;
    try {
      parsed = raw is String ? DateTime.parse(raw) : DateTime.now();
    } catch (_) {
      parsed = DateTime.now();
    }
    final priceRaw = json['price'];
    double price = 0;
    if (priceRaw is num) {
      price = priceRaw.toDouble();
    } else if (priceRaw is String) {
      price = double.tryParse(priceRaw) ?? 0;
    }
    return ChartPoint(t: parsed, price: price);
  }
}

/// Envelope returned by `fetch()` — carries the points plus the
/// backend's `latest` field (which is the current LMSR price when the
/// snapshots table has no rows in the requested window, otherwise the
/// price from the last bucket).
class ChartResponse {
  final String range;
  final String outcome;
  final List<ChartPoint> points;
  final double latest;

  const ChartResponse({
    required this.range,
    required this.outcome,
    required this.points,
    required this.latest,
  });

  /// 24h-ish change percentage derived from the points window. Returns
  /// null when there aren't enough points to compute a delta. The
  /// magnitude is `(latest - first) / first * 100` so a price moving
  /// from 0.50 → 0.40 reads as -20 (the "20% down" red badge in the
  /// Figma's Chart tab).
  double? get deltaPct {
    if (points.length < 2) return null;
    final first = points.first.price;
    if (first == 0) return null;
    return (latest - first) / first * 100;
  }
}

/// Read-only service for the price-chart endpoint.
///
/// Returns null on any failure (network / parsing / non-200) — the
/// caller falls back to either a sample chart or an empty state.
class TradeChartService {
  static Future<ChartResponse?> fetch({
    required String tradeUuid,
    String range = '1D',
    String outcome = 'yes',
  }) async {
    try {
      final response = await DioClient.instance.get(
        ApiEndpoints.tradeChart(tradeUuid),
        queryParameters: {
          'range': range,
          'outcome': outcome,
        },
      );

      if (response.statusCode != 200) return null;

      final body = response.data;
      if (body is! Map || body['status'] != true) return null;

      final data = body['data'];
      if (data is! Map) return null;

      final rawPoints = data['points'];
      final pts = <ChartPoint>[];
      if (rawPoints is List) {
        for (final item in rawPoints) {
          if (item is Map<String, dynamic>) {
            pts.add(ChartPoint.fromJson(item));
          } else if (item is Map) {
            pts.add(ChartPoint.fromJson(Map<String, dynamic>.from(item)));
          }
        }
      }

      double latest = 0;
      final latestRaw = data['latest'];
      if (latestRaw is num) {
        latest = latestRaw.toDouble();
      } else if (latestRaw is String) {
        latest = double.tryParse(latestRaw) ?? 0;
      } else if (pts.isNotEmpty) {
        latest = pts.last.price;
      }

      return ChartResponse(
        range: data['range']?.toString() ?? range,
        outcome: data['outcome']?.toString() ?? outcome,
        points: pts,
        latest: latest,
      );
    } on DioException catch (e) {
      debugPrint('TradeChartService: dio error ${e.message}');
      return null;
    } catch (e) {
      debugPrint('TradeChartService: unexpected $e');
      return null;
    }
  }
}
