import 'package:connectivity_plus/connectivity_plus.dart';

/// Thin wrapper around `connectivity_plus` so the rest of the app can ask
/// "are we online?" without depending on the package directly.
///
/// Note: connectivity only reflects whether a network interface exists, not
/// whether the API is actually reachable — so it is used to give a clearer
/// "no internet" message and to avoid pointless retries, not as a hard gate.
class ConnectivityService {
  ConnectivityService._();

  static final Connectivity _connectivity = Connectivity();

  /// Returns false only when the device reports no connectivity at all.
  /// Fails open (returns true) if the check itself errors, so a flaky probe
  /// never blocks a request.
  static Future<bool> isOnline() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results.any((r) => r != ConnectivityResult.none);
    } catch (_) {
      return true;
    }
  }
}
