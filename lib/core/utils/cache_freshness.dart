/// Formats how long ago cached data was last refreshed, for the offline UI.
///
/// Pure + deterministic: pass [now] in tests; it defaults to the wall clock.
class CacheFreshness {
  const CacheFreshness._();

  /// Human-readable age like "just now", "5m ago", "2h ago", "3d ago".
  /// Returns an empty string when [timestamp] is null (app never synced).
  static String format(DateTime? timestamp, {DateTime? now}) {
    if (timestamp == null) return '';

    final current = now ?? DateTime.now();
    var diff = current.difference(timestamp);
    if (diff.isNegative) diff = Duration.zero; // guard against clock skew

    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
