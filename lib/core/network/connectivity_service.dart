import 'package:connectivity_plus/connectivity_plus.dart';
class ConnectivityService {
  ConnectivityService._();

  static final Connectivity _connectivity = Connectivity();
  static Future<bool> isOnline() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results.any((r) => r != ConnectivityResult.none);
    } catch (_) {
      return true;
    }
  }
}
