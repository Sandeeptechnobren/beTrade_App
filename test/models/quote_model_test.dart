import 'package:betrade/data/model/quote_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QuoteModel.fromJson', () {
    test('parses a full LMSR quote payload', () {
      final q = QuoteModel.fromJson({
        'outcome_slug': 'yes',
        'cost_ghs': 50,
        'shares': 123.45,
        'avg_price_per_share': 0.405,
        'new_price_after_fill': 0.42,
        'max_payout_ghs': 123.45,
        'potential_profit_ghs': 73.45,
        'fee_ghs': 0.5,
      });

      expect(q.outcomeSlug, 'yes');
      expect(q.costGhs, 50.0);
      expect(q.shares, 123.45);
      expect(q.avgPricePerShare, 0.405);
      expect(q.newPriceAfterFill, 0.42);
      expect(q.maxPayoutGhs, 123.45);
      expect(q.potentialProfitGhs, 73.45);
      expect(q.feeGhs, 0.5);
    });

    test('defaults missing or non-numeric fields safely (never throws)', () {
      final q = QuoteModel.fromJson({'outcome_slug': 'no', 'cost_ghs': 'abc'});

      expect(q.outcomeSlug, 'no');
      expect(q.costGhs, 0.0);
      expect(q.shares, 0.0);
      expect(q.feeGhs, 0.0);
    });

    test('coerces integer JSON values to double', () {
      final q = QuoteModel.fromJson({'cost_ghs': 10, 'shares': 5});
      expect(q.costGhs, isA<double>());
      expect(q.costGhs, 10.0);
      expect(q.shares, 5.0);
    });
  });
}
