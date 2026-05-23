import 'package:flutter/material.dart';

import '../services/default_settings_service.dart';

class DefaultAmountProvider extends ChangeNotifier {
  int? _defaultAmount;
  int? get defaultAmount => _defaultAmount;

  /// True once the backend response has actually been parsed into
  /// `_defaultAmount`. This is the source of truth for "have we loaded
  /// yet?" — distinct from `_isFetching`, which only tracks whether a
  /// request is currently in flight. The previous version flipped
  /// `_hasLoaded = true` BEFORE awaiting the response, which let callers
  /// like HomeScreen's `_ensureReadyToTrade()` falsely conclude "amount
  /// is loaded" during the request window and open a TradePage that
  /// then immediately popped itself with a "set default amount" error.
  bool _hasLoaded = false;
  bool get hasLoaded => _hasLoaded;

  /// True only while `loadFromBackend()` has a request in flight. Used
  /// internally to dedupe concurrent calls — callers should consult
  /// `hasLoaded` instead.
  bool _isFetching = false;

  /// Fetches the user's default amount from `/userDefaultSettings/list`
  /// once. Concurrent calls while a fetch is in flight are no-ops; calls
  /// after a successful load are also no-ops. Call from any screen that
  /// needs the provider populated (typically HomeScreen) so the swipe
  /// action sends the correct cost_ghs even before the user has visited
  /// Default Settings.
  Future<void> loadFromBackend() async {
    if (_hasLoaded || _isFetching) return;
    _isFetching = true;
    try {
      final settings = await DefaultSettingsService.getSettings();
      if (settings != null) {
        _defaultAmount = settings.minDefaultAmount;
        _hasLoaded = true;
        notifyListeners();
      }
      // settings == null → fetch failed. Leave _hasLoaded = false so the
      // next call retries.
    } finally {
      _isFetching = false;
    }
  }

  void setDefaultAmount(int amount) {
    _defaultAmount = amount;
    _hasLoaded = true;
    notifyListeners();
  }
}