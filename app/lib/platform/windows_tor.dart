import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'tor.dart';

/// Tor on Windows: `tor.exe` from the Tor Expert Bundle, as a process of its
/// own next to the app (`tor\` beside `kilit.exe`, put there by
/// `scripts/fetch-tor-windows.ps1` and the Windows build). Bridges go
/// through the bundle's `lyrebird.exe` (obfs4, webtunnel, snowflake); the
/// built-in bridge lines come from the bundle's `pt_config.json`.
///
/// Tor exits with the app (`__OwningControllerProcess`). A new way out
/// restarts it, which on Windows is cheap: it is not inside our process.
class WindowsTor implements TorBackend {
  WindowsTor._(this._bundle);

  /// The bundle beside the running app, or null when there is none.
  static WindowsTor? find() {
    if (!Platform.isWindows) return null;
    final exe = File(Platform.resolvedExecutable).parent.path;
    final bundle = '$exe\\tor';
    if (!File('$bundle\\tor\\tor.exe').existsSync()) return null;
    return WindowsTor._(bundle);
  }

  /// A bundle at [bundle] (the folder holding `tor\tor.exe` and `data\`);
  /// for the live test.
  WindowsTor.at(String bundle) : this._(bundle);

  final String _bundle;
  TorState _state = const TorState(TorPhase.off);
  String? _dir;
  String? _config;

  /// The tor.exe processes of this start: one, or several racing each
  /// other on different ways out until one comes up.
  List<_Slot> _slots = [];

  // the last lines tor printed
  final _log = <String>[];

  /// Bumped on every start; a process from an earlier start no longer
  /// reports.
  int _run = 0;

  @override
  bool get available => true;

  /// tor.exe is a process of its own: several can try different ways out
  /// at once.
  @override
  bool get canRace => true;

  @override
  TorState state() => _state;

  void _set(TorState s) => _state = s;

  @override
  String? start(String dir, String config) {
    final Map<String, Object?> cfg;
    try {
      cfg = jsonDecode(config) as Map<String, Object?>;
    } on FormatException {
      return 'config';
    }
    final mode = cfg['mode'] as String? ?? 'direct';
    final List<String> bridges;
    try {
      bridges = _bridgeLines(mode, [
        for (final b in cfg['bridges'] as List? ?? const []) '$b',
      ]);
    } on StateError catch (e) {
      return e.message;
    }
    // ways out tried at the same time; one that cannot start is left out
    final race = <(String, List<String>)>[];
    for (final r in cfg['race'] as List? ?? const []) {
      try {
        race.add(('$r', _bridgeLines('$r', const [])));
      } on StateError {
        // no built-in bridges for it
      }
    }
    _dir = dir;
    _config = config;
    final run = ++_run;
    _killAll();
    _set(TorState(TorPhase.starting, summary: 'starting', mode: mode));
    final main = '$dir\\tor';
    _slots = [
      _Slot(mode, main, bridges),
      for (final (m, lines) in race) _Slot(m, '$dir\\tor-$m', lines),
    ];
    for (final slot in _slots) {
      Directory(slot.data).createSync(recursive: true);
      if (slot.data != main) _shareCache(main, slot.data);
      File('${slot.data}\\torrc')
          .writeAsStringSync(_torrc(slot.data, slot.bridges));
      unawaited(_launch(run, slot));
    }
    return null;
  }

  /// A racing tor starts from what the main one already downloaded, so it
  /// does not fetch the whole directory again.
  static void _shareCache(String from, String to) {
    for (final name in const [
      'cached-certs',
      'cached-microdesc-consensus',
      'cached-microdescs',
    ]) {
      final src = File('$from\\$name');
      final dst = File('$to\\$name');
      try {
        if (src.existsSync() &&
            (!dst.existsSync() ||
                dst.lastModifiedSync().isBefore(src.lastModifiedSync()))) {
          src.copySync(dst.path);
        }
      } on FileSystemException {
        // it downloads its own
      }
    }
  }

  void _killAll() {
    for (final s in _slots) {
      s.done = true;
      s.process?.kill();
    }
    _slots = [];
  }

  /// The state of this start: the first tor to come up wins and the others
  /// stop; until then the one furthest along shows.
  void _report(int run) {
    if (run != _run || _slots.isEmpty) return;
    final winner = _slots.where((s) => s.ready).firstOrNull;
    if (winner != null) {
      for (final s in _slots) {
        if (s != winner) {
          s.done = true;
          s.process?.kill();
        }
      }
      _slots = [winner];
      _set(
        TorState(
          TorPhase.ready,
          progress: 100,
          summary: winner.summary,
          socks: winner.socks,
          mode: winner.mode,
        ),
      );
      return;
    }
    final alive = _slots.where((s) => s.error == null).toList();
    if (alive.isEmpty) {
      final last = _slots.last;
      _set(
        TorState(TorPhase.failed, error: last.error ?? 'tor', mode: last.mode),
      );
      return;
    }
    alive.sort((a, b) => b.progress.compareTo(a.progress));
    final best = alive.first;
    _set(
      TorState(
        TorPhase.starting,
        progress: best.progress,
        summary: best.summary,
        socks: best.socks,
        mode: best.mode,
      ),
    );
  }

  Future<void> _launch(int run, _Slot slot) async {
    final racing = _slots.length > 1;
    try {
      final p = await Process.start('$_bundle\\tor\\tor.exe', [
        '-f',
        '${slot.data}\\torrc',
        '--defaults-torrc',
        '${slot.data}\\torrc-none',
        '--ignore-missing-torrc',
      ], workingDirectory: '$_bundle\\tor');
      if (run != _run || slot.done) {
        p.kill();
        return;
      }
      slot.process = p;
      p.stdout.transform(utf8.decoder).transform(const LineSplitter()).listen((
        line,
      ) {
        _log.add(racing ? '[${slot.mode}] $line' : line);
        if (_log.length > 200) _log.removeAt(0);
        final boot = _bootstrapped.firstMatch(line);
        if (boot != null) {
          slot.progress = int.parse(boot[1]!);
          slot.summary = boot[2]!;
        }
        final port = _socksOpened.firstMatch(line);
        if (port != null) slot.socks = int.parse(port[1]!);
        if (boot != null || port != null) _report(run);
      });
      p.stderr.drain<void>();
      final code = await p.exitCode;
      if (run == _run && !slot.done) {
        slot.error = '${slot.mode}: tor exited ($code)';
        slot.progress = 0;
        slot.socks = 0;
        _report(run);
      }
    } on ProcessException catch (e) {
      if (run == _run) {
        slot.error = '${slot.mode}: ${e.message}';
        _report(run);
      }
    }
  }

  @override
  String log() => _log.join('\n');

  /// tor.exe runs without a control port: no circuits to show.
  @override
  List<List<String>> circuits() => const [];

  /// tor.exe is its own process: a fresh one is the cleanest reconnect.
  @override
  String? reconnect() {
    final dir = _dir;
    final config = _config;
    if (dir == null || config == null) return 'not started';
    return start(dir, config);
  }

  @override
  void stop() {
    _run++;
    _killAll();
    _set(const TorState(TorPhase.off));
  }

  static final _bootstrapped = RegExp(r'Bootstrapped (\d+)%[^:]*: (.*)$');
  static final _socksOpened = RegExp(
    r'Opened Socks listener connection \(ready\) on 127\.0\.0\.1:(\d+)',
  );

  String _torrc(String data, List<String> bridges) {
    final lyrebird = '$_bundle\\tor\\pluggable_transports\\lyrebird.exe';
    return [
      'DataDirectory $data',
      'GeoIPFile $_bundle\\data\\geoip',
      'GeoIPv6File $_bundle\\data\\geoip6',
      'SocksPort 127.0.0.1:auto',
      'ClientOnly 1',
      'AvoidDiskWrites 1',
      'Log notice stdout',
      // gone with the app, even if it is killed
      '__OwningControllerProcess $pid',
      if (bridges.isNotEmpty) ...[
        'UseBridges 1',
        'ClientTransportPlugin obfs4,webtunnel exec $lyrebird',
        'ClientTransportPlugin snowflake exec $lyrebird',
        for (final b in bridges) 'Bridge $b',
      ],
      '',
    ].join('\n');
  }

  /// The bridge lines for [mode]: the bundle's own for obfs4 and
  /// snowflake, the user's checked lines for custom, none for direct.
  List<String> _bridgeLines(String mode, List<String> own) {
    switch (mode) {
      case 'direct':
        return const [];
      case 'obfs4':
      case 'snowflake':
        final pt = jsonDecode(
          File('$_bundle\\tor\\pluggable_transports\\pt_config.json')
              .readAsStringSync(),
        ) as Map<String, Object?>;
        final lines = ((pt['bridges'] as Map?)?[mode] as List? ?? const [])
            .map((e) => '$e')
            .toList();
        if (lines.isEmpty) throw StateError('no built-in $mode bridges');
        return lines;
      case 'custom':
        final lines = own.map(cleanBridgeLine).whereType<String>().toList();
        if (lines.isEmpty) throw StateError('no usable bridge line');
        return lines;
    }
    throw StateError('unknown mode $mode');
  }
}

/// One tor.exe of a start, and how far it got.
class _Slot {
  _Slot(this.mode, this.data, this.bridges);

  final String mode;
  final String data;
  final List<String> bridges;
  Process? process;
  int progress = 0;
  int socks = 0;
  String summary = '';
  String? error;

  /// Stopped on purpose: its exit is no failure.
  bool done = false;

  bool get ready => progress == 100 && socks > 0;
}

/// A bridge line someone pasted, trimmed ("Bridge " in front, spaces), or
/// null when it is not one Kilit can use. The same rule as engine-tor's.
String? cleanBridgeLine(String s) {
  var l = s.trim().split(RegExp(r'\s+')).join(' ');
  if (l.startsWith('Bridge ')) l = l.substring(7);
  if (l.length > 2048 || l.contains('\n')) return null;
  return _bridge.hasMatch(l) ? l : null;
}

final _bridge = RegExp(
  r'^(obfs4|webtunnel|snowflake) '
  r'(\[[0-9a-fA-F:]+\]|[0-9]{1,3}(\.[0-9]{1,3}){3}):[0-9]{1,5}'
  r'( [0-9A-Fa-f]{40})?'
  r'( [A-Za-z0-9_-]+=[^ ]+)*$',
);
