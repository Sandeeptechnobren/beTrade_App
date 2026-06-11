import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

/// Thin wrapper over `share_plus` so share call-sites stay one-liners and
/// the share copy lives in one place. There is no public per-market URL /
/// deep link in the app yet, so we share descriptive text that still drives
/// word-of-mouth growth (QA #2 — "Can users share events directly?").
class ShareHelper {
  ShareHelper._();

  /// Share a single market/event (from a feed card or detail screen).
  /// [title] is the market question/description; when it's empty we fall
  /// back to a generic app invite so the button is never a no-op.
  static Future<void> shareMarket({String? title}) async {
    final q = (title ?? '').trim();
    final text = q.isEmpty
        ? "I'm making predictions on BeTrade — come join me! 🎯"
        : "🎯 $q\n\nThink you know the outcome? Make your prediction on BeTrade.";
    try {
      await SharePlus.instance.share(ShareParams(text: text));
    } catch (e) {
      debugPrint("❌ Share failed: $e");
    }
  }
}
