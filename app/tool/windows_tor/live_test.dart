// Starts the Windows Tor from app/windows/tor and waits until it is ready,
// straight and through obfs4. Needs Windows, the network and the bundle
// (scripts/fetch-tor-windows.ps1):
//
//   flutter test tool/windows_tor
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kilit/platform/tor.dart';
import 'package:kilit/platform/windows_tor.dart';

Future<TorState> _until(WindowsTor t, Duration limit) async {
  final end = DateTime.now().add(limit);
  while (DateTime.now().isBefore(end)) {
    final s = t.state();
    if (s.phase == TorPhase.ready || s.phase == TorPhase.failed) return s;
    await Future<void>.delayed(const Duration(seconds: 1));
  }
  return t.state();
}

void main() {
  test(
    'tor.exe comes up, straight and through obfs4',
    () async {
      final tor = WindowsTor.at(
        '${Directory.current.path}'
        r'\windows\tor',
      );
      final dir = Directory.systemTemp.createTempSync('kilit-tor');
      addTearDown(() {
        tor.stop();
      });
      for (final mode in ['direct', 'obfs4']) {
        expect(tor.start(dir.path, '{"mode":"$mode"}'), isNull);
        final s = await _until(tor, const Duration(minutes: 3));
        // ignore: avoid_print
        print('$mode: ${s.phase} ${s.progress}% socks ${s.socks} ${s.error}');
        expect(s.phase, TorPhase.ready, reason: mode);
        expect(s.socks, greaterThan(0));
      }
    },
    timeout: const Timeout(Duration(minutes: 7)),
    skip: !Platform.isWindows,
  );
}
