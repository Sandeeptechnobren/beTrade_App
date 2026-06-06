import 'dart:math';

/// Generates RFC-4122 v4 UUIDs for use as idempotency keys.
///
/// A key should be created **once per logical action** (one buy, one deposit,
/// one withdrawal) and reused across retries, so a re-submit after a network
/// timeout is recognised by the backend as the *same* request rather than a
/// new, duplicate one. Generating a fresh key on every tap defeats the
/// purpose — see CHALLENGES F3.
class Idempotency {
  Idempotency._();

  static final Random _rng = Random.secure();

  static String newKey() {
    final bytes = List<int>.generate(16, (_) => _rng.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40; // version 4
    bytes[8] = (bytes[8] & 0x3f) | 0x80; // variant 1
    String hex(int n) => n.toRadixString(16).padLeft(2, '0');
    final s = bytes.map(hex).join();
    return '${s.substring(0, 8)}-'
        '${s.substring(8, 12)}-'
        '${s.substring(12, 16)}-'
        '${s.substring(16, 20)}-'
        '${s.substring(20, 32)}';
  }
}
