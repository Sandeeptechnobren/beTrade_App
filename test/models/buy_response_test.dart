import 'package:betrade/data/model/buy_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BuyResponse.fromJson', () {
    test('parses a success envelope with order, quote and wallet balance', () {
      final r = BuyResponse.fromJson({
        'status': true,
        'message': 'Order placed',
        'data': {
          'order': {
            'shares': 123.45,
            'avg_fill_price': 0.405,
            'total_cost_ghs': 50.0,
            'fee_ghs': 0.5,
          },
          'quote': {'outcome_slug': 'yes', 'cost_ghs': 50.0},
          'wallet_balance': 450.0,
        },
      });

      expect(r.success, isTrue);
      expect(r.message, 'Order placed');
      expect(r.code, isNull);
      expect(r.order, isNotNull);
      expect(r.order!.shares, 123.45);
      expect(r.order!.totalCostGhs, 50.0);
      expect(r.quote, isNotNull);
      expect(r.quote!.outcomeSlug, 'yes');
      expect(r.walletBalance, 450.0);
    });

    test('parses a typed error envelope (status=false + code)', () {
      final r = BuyResponse.fromJson({
        'status': false,
        'message': 'Insufficient funds',
        'code': 'INSUFFICIENT_FUNDS',
      });

      expect(r.success, isFalse);
      expect(r.code, 'INSUFFICIENT_FUNDS');
      expect(r.order, isNull);
      expect(r.quote, isNull);
      expect(r.walletBalance, isNull);
    });

    test('networkFailure builds a generic failed result', () {
      final r = BuyResponse.networkFailure();
      expect(r.success, isFalse);
      expect(r.message, isNotNull);
    });
  });
}
