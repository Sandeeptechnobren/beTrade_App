import 'package:betrade/core/utils/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Money.tryParse / parse', () {
    test('parses numbers and numeric strings (incl. thousands separators)', () {
      expect(Money.tryParse(12), 12.0);
      expect(Money.tryParse('12.5'), 12.5);
      expect(Money.tryParse('1,234.50'), 1234.50);
    });

    test('returns null for invalid input', () {
      expect(Money.tryParse('abc'), isNull);
      expect(Money.tryParse(''), isNull);
      expect(Money.tryParse(null), isNull);
    });

    test('parse falls back to a default', () {
      expect(Money.parse('abc'), 0.0);
      expect(Money.parse(null, 5), 5.0);
      expect(Money.parse('7.25'), 7.25);
    });
  });

  group('Money.round / format', () {
    test('rounds to 2 decimal places', () {
      expect(Money.round(1.239, 2), 1.24);
      expect(Money.round(1.231, 2), 1.23);
      expect(Money.round(10, 2), 10.0);
    });

    test('format pads to fixed decimals and adds the GHS suffix', () {
      expect(Money.format(5), '5.00');
      expect(Money.format(5.1), '5.10');
      expect(Money.ghs(5), '5.00 GHS');
    });
  });

  group('Money.decimalPlaces', () {
    test('counts decimals in a typed string', () {
      expect(Money.decimalPlaces('10'), 0);
      expect(Money.decimalPlaces('10.5'), 1);
      expect(Money.decimalPlaces('10.55'), 2);
    });
  });

  group('Money.validateAmount', () {
    test('rejects empty, non-numeric and non-positive amounts', () {
      expect(Money.validateAmount(''), isNotNull);
      expect(Money.validateAmount('abc'), isNotNull);
      expect(Money.validateAmount('0'), isNotNull);
      expect(Money.validateAmount('-5'), isNotNull);
    });

    test('rejects more than two decimal places', () {
      expect(Money.validateAmount('10.555'), isNotNull);
      expect(Money.validateAmount('10.55'), isNull);
    });

    test('enforces min, max and balance bounds', () {
      expect(Money.validateAmount('5', min: 10), isNotNull);
      expect(Money.validateAmount('50', max: 20), isNotNull);
      expect(Money.validateAmount('100', balance: 50), isNotNull);
    });

    test('accepts a valid amount within all bounds', () {
      expect(
        Money.validateAmount('25.50', min: 1, max: 1000, balance: 100),
        isNull,
      );
    });
  });
}
