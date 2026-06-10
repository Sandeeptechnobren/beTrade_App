import 'package:betrade/core/utils/cache_freshness.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CacheFreshness.format', () {
    final now = DateTime(2026, 6, 10, 12, 0, 0);

    test('returns empty string when never synced (null)', () {
      expect(CacheFreshness.format(null, now: now), '');
    });

    test('"just now" under a minute', () {
      expect(
        CacheFreshness.format(now.subtract(const Duration(seconds: 5)), now: now),
        'just now',
      );
      expect(
        CacheFreshness.format(now.subtract(const Duration(seconds: 59)), now: now),
        'just now',
      );
    });

    test('minutes', () {
      expect(
        CacheFreshness.format(now.subtract(const Duration(minutes: 1)), now: now),
        '1m ago',
      );
      expect(
        CacheFreshness.format(now.subtract(const Duration(minutes: 59)), now: now),
        '59m ago',
      );
    });

    test('hours', () {
      expect(
        CacheFreshness.format(now.subtract(const Duration(hours: 1)), now: now),
        '1h ago',
      );
      expect(
        CacheFreshness.format(now.subtract(const Duration(hours: 23)), now: now),
        '23h ago',
      );
    });

    test('days', () {
      expect(
        CacheFreshness.format(now.subtract(const Duration(days: 1)), now: now),
        '1d ago',
      );
      expect(
        CacheFreshness.format(now.subtract(const Duration(days: 7)), now: now),
        '7d ago',
      );
    });

    test('future timestamp (clock skew) clamps to "just now"', () {
      expect(
        CacheFreshness.format(now.add(const Duration(minutes: 5)), now: now),
        'just now',
      );
    });
  });
}
