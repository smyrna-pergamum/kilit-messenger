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
    'tor.exe comes up, straight, through obfs4, and in a race',
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
      // a race: direct and obfs4 at once, the first up wins, one remains
      final began = DateTime.now();
      expect(tor.start(dir.path, '{"mode":"direct","race":["obfs4"]}'), isNull);
      final s = await _until(tor, const Duration(minutes: 3));
      // ignore: avoid_print
      print(
        'race: ${s.phase} via ${s.mode} in '
        '${DateTime.now().difference(began).inSeconds}s',
      );
      expect(s.phase, TorPhase.ready);
      expect(['direct', 'obfs4'], contains(s.mode));
      expect(tor.log(), contains('[obfs4]'));
    },
    timeout: const Timeout(Duration(minutes: 7)),
    skip: !Platform.isWindows,
  );
}
