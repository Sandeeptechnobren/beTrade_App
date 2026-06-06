import 'package:betrade/data/model/order_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OrderModel.fromJson', () {
    test('parses fill details', () {
      final o = OrderModel.fromJson({
        'shares': 10,
        'avg_fill_price': 0.4,
        'total_cost_ghs': 4.0,
        'fee_ghs': 0.04,
      });

      expect(o.shares, 10.0);
      expect(o.avgFillPrice, 0.4);
      expect(o.totalCostGhs, 4.0);
      expect(o.feeGhs, 0.04);
    });

    test('defaults to 0.0 on an empty/partial payload', () {
      final o = OrderModel.fromJson({});
      expect(o.shares, 0.0);
      expect(o.avgFillPrice, 0.0);
      expect(o.totalCostGhs, 0.0);
      expect(o.feeGhs, 0.0);
    });
  });
}
