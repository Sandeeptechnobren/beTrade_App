import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Centralized network-status source of truth for the whole app.
///
/// `connectivity_plus` only reports the **network interface** (wifi / mobile /
/// none) — it does NOT tell us whether the internet is actually reachable.
/// Captive portals (hotels/airports), WiFi-without-WAN and expired data plans
/// all report "connected" while every request fails. This service combines
/// that cheap interface signal with a real **reachability probe** (a short TCP
/// handshake to well-known anycast endpoints) so the rest of the app reacts to
/// *true* connectivity.
///
/// Use [instance] everywhere:
/// - the UI listens to [onStatusChange] (via `ConnectivityProvider`),
/// - one-shot callers (e.g. the Dio retry interceptor) await [checkNow].
class ConnectivityService {
  ConnectivityService._internal()
      : _connectivity = Connectivity(),
        _probe = _defaultProbe {
    _init();
  }

  /// Test seam: inject a fake [connectivity] and [probe]. Unlike the singleton
  /// this constructor does NOT start listening to the platform stream — drive
  /// it manually via [checkNow] in tests.
  @visibleForTesting
  ConnectivityService.withDependencies({
    required Connectivity connectivity,
    required Future<bool> Function() probe,
  })  : _connectivity = connectivity,
        _probe = probe;

  /// App-wide singleton. Lazily created on first access; lives for the session.
  static final ConnectivityService instance = ConnectivityService._internal();

  final Connectivity _connectivity;
  final Future<bool> Function() _probe;
  final StreamController<bool> _statusController =
      StreamController<bool>.broadcast();

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _debounce;

  bool _isOnline = true;

  /// Last known *effective* status. `true` = interface up AND internet reachable.
  bool get isOnline => _isOnline;

  /// Emits whenever the effective online status flips. Broadcast — multiple
  /// listeners are fine.
  Stream<bool> get onStatusChange => _statusController.stream;

  /// Reliable anycast endpoints. A successful TCP handshake to ANY one proves
  /// we can reach the public internet (not just the local router). We mix DNS
  /// (53) and HTTPS (443) ports so networks that block one still resolve.
  static const List<_ProbeHost> _probeHosts = [
    _ProbeHost('1.1.1.1', 443), // Cloudflare (HTTPS port — rarely blocked)
    _ProbeHost('8.8.8.8', 53), // Google DNS
    _ProbeHost('1.1.1.1', 53), // Cloudflare DNS
  ];

  static const Duration _probeTimeout = Duration(seconds: 3);
  static const Duration _debounceWindow = Duration(milliseconds: 500);

  Future<void> _init() async {
    // Seed the initial status, then watch for interface changes.
    _isOnline = await _resolveStatus();
    _statusController.add(_isOnline);

    _subscription = _connectivity.onConnectivityChanged.listen((_) {
      // Coalesce rapid wifi<->mobile handoff bursts into a single probe.
      _debounce?.cancel();
      _debounce = Timer(_debounceWindow, _refresh);
    });
  }

  Future<void> _refresh() async {
    final online = await _resolveStatus();
    _emitIfChanged(online);
  }

  /// Forces a fresh check right now and returns it. Used by the retry
  /// interceptor before deciding whether a failed request is worth retrying.
  /// Also updates the cached status / notifies listeners if it changed.
  Future<bool> checkNow() async {
    final online = await _resolveStatus();
    _emitIfChanged(online);
    return online;
  }

  void _emitIfChanged(bool online) {
    if (online != _isOnline) {
      _isOnline = online;
      _statusController.add(online);
    }
  }

  /// Interface up? -> then is the internet *actually* reachable?
  Future<bool> _resolveStatus() async {
    try {
      final results = await _connectivity.checkConnectivity();
      final hasInterface = results.any((r) => r != ConnectivityResult.none);
      if (!hasInterface) return false;
      return _probe();
    } catch (_) {
      // Fail open: if the platform check itself blows up, assume online and let
      // the actual request surface any real error.
      return true;
    }
  }

  static Future<bool> _defaultProbe() async {
    // Probe all hosts in parallel; the first success wins. Each probe is
    // self-contained (never throws) and capped by [_probeTimeout], so the whole
    // check returns in at most ~3s even when fully offline.
    final outcomes = await Future.wait(_probeHosts.map(_canReach));
    return outcomes.any((reachable) => reachable);
  }

  static Future<bool> _canReach(_ProbeHost host) async {
    Socket? socket;
    try {
      socket = await Socket.connect(
        host.host,
        host.port,
        timeout: _probeTimeout,
      );
      return true;
    } catch (_) {
      return false;
    } finally {
      socket?.destroy();
    }
  }

  /// For tests / teardown only. The singleton normally lives the whole session.
  void dispose() {
    _debounce?.cancel();
    _subscription?.cancel();
    _statusController.close();
  }
}

class _ProbeHost {
  const _ProbeHost(this.host, this.port);
  final String host;
  final int port;
}
