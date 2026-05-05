import 'package:flutter/material.dart';

import '../services/default_settings_service.dart';

class DefaultAmountProvider extends ChangeNotifier {
  int? _defaultAmount;
  int? get defaultAmount => _defaultAmount;

  bool _hasLoaded = false;
  bool get hasLoaded => _hasLoaded;

  /// Fetches the user's default amount from `/userDefaultSettings/list`
  /// once. Idempotent — subsequent calls are no-ops while the first
  /// fetch is still in flight or after it has completed. Call from any
  /// screen that needs the provider populated (typically HomeScreen) so
  /// the swipe action sends the correct cost_ghs even before the user
  /// has visited Default Settings.
  Future<void> loadFromBackend() async {
    if (_hasLoaded) return;
    _hasLoaded = true; // optimistic — prevents duplicate parallel fetches
    final settings = await DefaultSettingsService.getSettings();
    if (settings != null) {
      _defaultAmount = settings.minDefaultAmount;
      notifyListeners();
    } else {
      // Fetch failed — allow a retry on the next call.
      _hasLoaded = false;
    }
  }

  void setDefaultAmount(int amount) {
    _defaultAmount = amount;
    _hasLoaded = true;
    notifyListeners();
  }
}