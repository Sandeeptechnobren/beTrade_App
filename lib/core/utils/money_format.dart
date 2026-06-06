/// Single source of truth for GHS amount formatting. Replaces the
/// ~10 ad-hoc shapes scattered across the app (`X GHS`, `XGHS`,
/// `X.XX GHS`, `+X.XX GHS`, `Xc`, etc.). Use throughout new UI; sweep
/// existing call sites as we migrate per phase.
///
/// House rules:
///   - Money values always have **2 decimals** unless they're a chip
///     value (use `formatGhsCount`) or a per-share LMSR price (use
///     `formatPrice`).
///   - **One space** between the number and "GHS" — `'10.00 GHS'`, never
///     `'10.00GHS'`.
///   - Signed (positive prefix `+`) only for P&L / profit displays —
///     pass `withSign: true`.
///   - Currency string is hard-coded "GHS" for now; if we localise the
///     wallet currency later, accept a `currency` parameter.
class Money {
  Money._();

  /// `10.00 GHS` (default), or `+10.00 GHS` with [withSign].
  /// Defaults to 2 decimals; pass [decimals] for finer-grained displays
  /// (e.g. 4 for per-share quote details).
  static String formatGhs(num? amount,
      {bool withSign = false, int decimals = 2}) {
    final v = (amount ?? 0).toDouble();
    final formatted = v.toStringAsFixed(decimals);
    if (withSign && v > 0) return '+$formatted GHS';
    return '$formatted GHS';
  }

  /// `10 GHS` — used for amount chips and read-only default-amount
  /// displays where decimals would be noise.
  static String formatGhsCount(num? amount) {
    final v = (amount ?? 0).toDouble();
    return '${v.toStringAsFixed(0)} GHS';
  }

  /// Per-share LMSR price — always 2 decimals so 0.50 doesn't round to
  /// `0 GHS`. Pass [decimals] for the buy-sheet's higher-precision rows.
  static String formatPrice(num? price, {int decimals = 2}) {
    final v = (price ?? 0).toDouble();
    return '${v.toStringAsFixed(decimals)} GHS';
  }

  /// Plain share count: `12.40` (default) or `12 shares` with [withUnit].
  static String formatShares(num? shares,
      {bool withUnit = false, int decimals = 2}) {
    final v = (shares ?? 0).toDouble();
    final formatted = v.toStringAsFixed(decimals);
    return withUnit ? '$formatted shares' : formatted;
  }
}
