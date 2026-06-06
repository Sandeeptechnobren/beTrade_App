import 'package:betrade/core/utils/idempotency.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final v4 = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  );

  test('newKey returns a well-formed RFC-4122 v4 UUID', () {
    final key = Idempotency.newKey();
    expect(v4.hasMatch(key), isTrue, reason: 'got "$key"');
  });

  test('newKey is unique across many calls', () {
    final keys = List.generate(2000, (_) => Idempotency.newKey()).toSet();
    expect(keys.length, 2000);
  });
}
