import 'package:betrade/core/network/connectivity_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockConnectivity extends Mock implements Connectivity {}

void main() {
  late _MockConnectivity connectivity;

  setUp(() {
    connectivity = _MockConnectivity();
  });

  ConnectivityService buildService({
    required List<ConnectivityResult> interface,
    required bool reachable,
  }) {
    when(() => connectivity.checkConnectivity())
        .thenAnswer((_) async => interface);
    return ConnectivityService.withDependencies(
      connectivity: connectivity,
      probe: () async => reachable,
    );
  }

  group('ConnectivityService.checkNow', () {
    test('offline when there is no network interface', () async {
      final s = buildService(
        interface: [ConnectivityResult.none],
        reachable: true,
      );
      expect(await s.checkNow(), isFalse);
    });

    test(
        'offline when interface is up but the internet is unreachable '
        '(captive portal / wifi-without-internet)', () async {
      final s = buildService(
        interface: [ConnectivityResult.wifi],
        reachable: false,
      );
      expect(await s.checkNow(), isFalse);
    });

    test('online only when interface is up AND internet is reachable', () async {
      final s = buildService(
        interface: [ConnectivityResult.mobile],
        reachable: true,
      );
      expect(await s.checkNow(), isTrue);
    });

    test('short-circuits: does not probe when the interface is down', () async {
      var probed = false;
      when(() => connectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);
      final s = ConnectivityService.withDependencies(
        connectivity: connectivity,
        probe: () async {
          probed = true;
          return true;
        },
      );
      await s.checkNow();
      expect(probed, isFalse, reason: 'interface=none should skip the probe');
    });

    test('emits the new status on onStatusChange when it flips', () async {
      final s = buildService(
        interface: [ConnectivityResult.wifi],
        reachable: false,
      );
      final firstEvent = s.onStatusChange.first; // listen before triggering
      await s.checkNow();
      expect(await firstEvent, isFalse);
    });
  });
}
