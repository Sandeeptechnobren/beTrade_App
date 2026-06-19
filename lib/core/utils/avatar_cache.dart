/// App-wide cache-buster for user avatars.
///
/// Avatar URLs are stable — the backend overwrites the file in place, so the
/// URL string stays identical after a picture change. Flutter's ImageCache
/// (and already-mounted Image widgets) therefore keep serving the OLD image
/// even after a refresh. Bump [version] whenever the avatar changes and append
/// it to avatar URLs via [bust]; the changed URL forces every avatar to
/// re-download — on the profile, in rankings, anywhere.
class AvatarCache {
  AvatarCache._();

  static int version = 0;

  /// Call once after a successful profile-picture change.
  static void bump() => version++;

  /// Appends the current cache-bust token to [url]. Returns the URL unchanged
  /// when it is null/empty, or when nothing has changed yet (version 0) so a
  /// fresh launch keeps normal image caching.
  static String? bust(String? url) {
    if (url == null || url.isEmpty || version == 0) return url;
    final sep = url.contains('?') ? '&' : '?';
    return '$url${sep}v=$version';
  }
}
