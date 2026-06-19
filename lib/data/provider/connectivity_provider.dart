import 'dart:async';
import 'package:flutter/material.dart';

import '../../core/network/connectivity_service.dart';

/// Thin [ChangeNotifier] bridge over [ConnectivityService] so the widget tree
/// can `watch` / `Consumer` the online status. All the interface + reachability
/// logic lives in the service (single source of truth) — this just mirrors its
/// effective status into the Provider tree.
class ConnectivityProvider with ChangeNotifier {
  ConnectivityProvider() {
    _isOffline = !ConnectivityService.instance.isOnline;
    _subscription =
        ConnectivityService.instance.onStatusChange.listen(_onStatus);
  }

  bool _isOffline = false;
  bool get isOffline => _isOffline;

  late final StreamSubscription<bool> _subscription;

  void _onStatus(bool isOnline) {
    final offline = !isOnline;
    if (_isOffline != offline) {
      _isOffline = offline;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
