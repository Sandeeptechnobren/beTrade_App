/// Client-side helpers for working with monetary (GHS) amounts.
///
/// IMPORTANT: the backend ledger and the JSON wire format remain the source of
/// truth for money. This utility only makes **client-side** parsing, rounding,
/// formatting and validation consistent, and avoids accumulating binary
/// floating-point error in what we *display* and *validate*. A complete fix
/// (integer minor units / Decimal end-to-end) requires a backend contract
/// change — tracked as CHALLENGES F2 / B4.
class Money {
  Money._();

  /// Parses a possibly-null dynamic (num or String) into a double, or returns
  /// null when it is not a valid number. Strips thousands separators.
  static double? tryParse(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    final s = v.toString().trim().replaceAll(',', '');
    if (s.isEmpty) return null;
    return double.tryParse(s);
  }

  /// Parses with a fallback (defaults to 0.0).
  static double parse(dynamic v, [double fallback = 0.0]) =>
      tryParse(v) ?? fallback;

  /// Rounds to [places] decimal places (default 2) by scaling to an integer
  /// first, which avoids the FP drift of repeated double arithmetic.
  static double round(double value, [int places = 2]) {
    if (value.isNaN || value.isInfinite) return 0.0;
    final factor = _pow10(places);
    return (value * factor).roundToDouble() / factor;
  }

  /// Formats an amount as a fixed-decimal string (no currency suffix).
  static String format(double value, [int places = 2]) =>
      round(value, places).toStringAsFixed(places);

  /// Formats with the GHS suffix, e.g. `"12.50 GHS"`.
  static String ghs(double value, [int places = 2]) =>
      '${format(value, places)} GHS';

  /// Number of decimal places in a user-typed string (after trimming).
  static int decimalPlaces(String input) {
    final s = input.trim();
    final dot = s.indexOf('.');
    if (dot < 0) return 0;
    return s.length - dot - 1;
  }

  /// Validates a user-entered amount. Returns a user-facing error string, or
  /// `null` when the amount is valid.
  ///
  /// - [min] / [max] bound the amount (inclusive).
  /// - [balance], when provided, caps the amount at available funds.
  /// - [maxDecimals] limits precision (GHS = 2 by default).
  static String? validateAmount(
    String raw, {
    double min = 0.0,
    double? max,
    double? balance,
    int maxDecimals = 2,
  }) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return 'Enter an amount';

    final parsed = tryParse(trimmed);
    if (parsed == null) return 'Enter a valid number';
    if (parsed <= 0) return 'Amount must be greater than 0';
    if (decimalPlaces(trimmed) > maxDecimals) {
      return 'Use at most $maxDecimals decimal place${maxDecimals == 1 ? '' : 's'}';
    }
    if (parsed < min) return 'Minimum is ${ghs(min)}';
    if (max != null && parsed > max) return 'Maximum is ${ghs(max)}';
    if (balance != null && parsed > balance) {
      return 'Amount exceeds your balance (${ghs(balance)})';
    }
    return null;
  }

  static int _pow10(int n) {
    var r = 1;
    for (var i = 0; i < n; i++) {
      r *= 10;
    }
    return r;
  }
}
