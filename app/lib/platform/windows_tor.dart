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
  Process? _tor;
  TorState _state = const TorState(TorPhase.off);
  String _mode = '';
  String? _dir;
  String? _config;

  // the last lines tor printed
  final _log = <String>[];

  /// Bumped on every start; a process from an earlier start no longer
  /// reports.
  int _run = 0;

  @override
  bool get available => true;

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
    _dir = dir;
    _config = config;
    final data = '$dir\\tor';
    Directory(data).createSync(recursive: true);
    File('$data\\torrc').writeAsStringSync(_torrc(data, bridges));
    _mode = mode;
    final run = ++_run;
    _tor?.kill();
    _set(TorState(TorPhase.starting, summary: 'starting', mode: mode));
    unawaited(_launch(run, data));
    return null;
  }

  Future<void> _launch(int run, String data) async {
    try {
      final p = await Process.start('$_bundle\\tor\\tor.exe', [
        '-f',
        '$data\\torrc',
        '--defaults-torrc',
        '$data\\torrc-none',
        '--ignore-missing-torrc',
      ], workingDirectory: '$_bundle\\tor');
      if (run != _run) {
        p.kill();
        return;
      }
      _tor = p;
      var progress = 0;
      var socks = 0;
      var summary = '';
      void report() {
        if (run != _run) return;
        _set(
          TorState(
            progress == 100 && socks > 0 ? TorPhase.ready : TorPhase.starting,
            progress: progress,
            summary: summary,
            socks: socks,
            mode: _mode,
          ),
        );
      }

      p.stdout.transform(utf8.decoder).transform(const LineSplitter()).listen((
        line,
      ) {
        _log.add(line);
        if (_log.length > 200) _log.removeAt(0);
        final boot = _bootstrapped.firstMatch(line);
        if (boot != null) {
          progress = int.parse(boot[1]!);
          summary = boot[2]!;
        }
        final port = _socksOpened.firstMatch(line);
        if (port != null) socks = int.parse(port[1]!);
        if (boot != null || port != null) report();
      });
      p.stderr.drain<void>();
      final code = await p.exitCode;
      if (run == _run && _state.phase != TorPhase.off) {
        _set(
          TorState(TorPhase.failed, error: 'tor exited ($code)', mode: _mode),
        );
      }
    } on ProcessException catch (e) {
      if (run == _run) {
        _set(TorState(TorPhase.failed, error: e.message, mode: _mode));
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
    _tor?.kill();
    _tor = null;
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
