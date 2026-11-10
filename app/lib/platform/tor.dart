import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';

/// Where Tor is.
enum TorPhase {
  off,
  starting,
  ready,
  failed,

  /// No Tor on this platform yet (Windows gets tor.exe in stage 3).
  unavailable,
}

class TorState {
  const TorState(
    this.phase, {
    this.progress = 0,
    this.summary = '',
    this.socks = 0,
    this.error = '',
    this.mode = '',
  });

  final TorPhase phase;

  /// Bootstrap percentage, 0 to 100.
  final int progress;

  /// Tor's own words for the step it is on.
  final String summary;

  /// The local SOCKS5 port; 0 until Tor listens.
  final int socks;
  final String error;

  /// The way out Tor is using: direct, obfs4, snowflake or custom.
  final String mode;

  static TorState fromJson(String json) {
    final m = jsonDecode(json) as Map<String, dynamic>;
    return TorState(
      switch (m['phase']) {
        'starting' => TorPhase.starting,
        'ready' => TorPhase.ready,
        'failed' => TorPhase.failed,
        _ => TorPhase.off,
      },
      progress: (m['progress'] as num?)?.toInt() ?? 0,
      summary: m['summary'] as String? ?? '',
      socks: (m['socks'] as num?)?.toInt() ?? 0,
      error: m['error'] as String? ?? '',
      mode: m['mode'] as String? ?? '',
    );
  }
}

/// The engine underneath: the embedded Tor on Android, nothing elsewhere.
abstract interface class TorBackend {
  bool get available;

  /// Whether several ways out can be tried at the same time (config
  /// `"race": [...]`): tor.exe on Windows can, the embedded Tor cannot.
  bool get canRace;

  /// Starts Tor in [dir]/tor, going out the way [config] says (JSON:
  /// mode and, for custom, bridges), or changes the way out of a running
  /// one. Returns an error, or null.
  String? start(String dir, String config);
  TorState state();
  void stop();

  /// The last lines Tor logged, to see why it does not connect.
  String log();

  /// The circuits Tor has built: each its relays' nicknames, guard first.
  /// Empty when Tor cannot tell.
  List<List<String>> circuits();

  /// New circuits on a running Tor, which goes out again. Returns an
  /// error, or null.
  String? reconnect();
}

/// The marker in an error that only restarting Kilit cures: Tor runs once
/// per process on Android.
const torNeedsRestart = 'restart Kilit';

/// engine-tor's libkilittor.so, through Dart's FFI. Every call returns at
/// once: Tor bootstraps on its own threads.
class NativeTor implements TorBackend {
  NativeTor._(DynamicLibrary lib)
    : _start = lib
          .lookupFunction<
            Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>),
            Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>)
          >('KilitTorStart'),
      _state = lib
          .lookupFunction<Pointer<Utf8> Function(), Pointer<Utf8> Function()>(
            'KilitTorState',
          ),
      _stop = lib.lookupFunction<Void Function(), void Function()>(
        'KilitTorStop',
      ),
      _log = lib
          .lookupFunction<Pointer<Utf8> Function(), Pointer<Utf8> Function()>(
            'KilitTorLog',
          ),
      _circuits = lib
          .lookupFunction<Pointer<Utf8> Function(), Pointer<Utf8> Function()>(
            'KilitTorCircuits',
          ),
      _reconnect = lib
          .lookupFunction<Pointer<Utf8> Function(), Pointer<Utf8> Function()>(
            'KilitTorReconnect',
          ),
      _free = lib
          .lookupFunction<
            Void Function(Pointer<Utf8>),
            void Function(Pointer<Utf8>)
          >('KilitTorFree');

  /// The engine, or null when this build has none (no libkilittor.so for
  /// this CPU, or not Android).
  static NativeTor? load() {
    if (!Platform.isAndroid) return null;
    try {
      return NativeTor._(DynamicLibrary.open('libkilittor.so'));
    } on ArgumentError {
      return null;
    }
  }

  final Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>) _start;
  final Pointer<Utf8> Function() _state;
  final void Function() _stop;
  final Pointer<Utf8> Function() _log;
  final Pointer<Utf8> Function() _circuits;
  final Pointer<Utf8> Function() _reconnect;
  final void Function(Pointer<Utf8>) _free;

  String _take(Pointer<Utf8> p) {
    try {
      return p.toDartString();
    } finally {
      _free(p);
    }
  }

  @override
  bool get available => true;

  /// One Tor per process.
  @override
  bool get canRace => false;

  @override
  String? start(String dir, String config) {
    final d = dir.toNativeUtf8();
    final c = config.toNativeUtf8();
    try {
      final err = _take(_start(d, c));
      return err.isEmpty ? null : err;
    } finally {
      malloc.free(d);
      malloc.free(c);
    }
  }

  @override
  TorState state() => TorState.fromJson(_take(_state()));

  @override
  void stop() => _stop();

  @override
  String log() => _take(_log());

  @override
  List<List<String>> circuits() => parseCircuits(_take(_circuits()));

  @override
  String? reconnect() {
    final err = _take(_reconnect());
    return err.isEmpty ? null : err;
  }
}

/// engine-tor's circuits JSON: `[{"hops":[{"nickname":"..."}]}]`.
List<List<String>> parseCircuits(String json) {
  try {
    final list = jsonDecode(json);
    if (list is! List) return const [];
    return [
      for (final c in list)
        if (c is Map && c['hops'] is List)
          [
            for (final h in c['hops'] as List)
              if (h is Map) '${h['nickname'] ?? ''}',
          ],
    ];
  } on FormatException {
    return const [];
  }
}

/// A platform without Tor.
class NoTor implements TorBackend {
  const NoTor();

  @override
  bool get available => false;

  @override
  bool get canRace => false;

  @override
  String? start(String dir, String config) => 'unavailable';

  @override
  TorState state() => const TorState(TorPhase.unavailable);

  @override
  void stop() {}

  @override
  String log() => '';

  @override
  List<List<String>> circuits() => const [];

  @override
  String? reconnect() => 'unavailable';
}

/// How Tor reaches the network. Bridges are for where the Tor network is
/// blocked: obfs4 looks like random bytes, snowflake goes out through
/// short-lived WebRTC hops that volunteers run.
enum TorRoute {
  /// Straight first; through obfs4 and then snowflake bridges when Tor
  /// does not come up.
  auto,
  direct,
  obfs4,
  snowflake,

  /// The user's own bridge lines.
  custom,
}

/// The order [TorRoute.auto] tries, and how many seconds each try gets
/// before the next one.
const autoRoutes = [
  (TorRoute.direct, 45),
  (TorRoute.obfs4, 90),
  (TorRoute.snowflake, 120),
];

/// How many seconds a way the user chose gets before Kilit offers bridges.
const blockedAfter = 120;

/// Runs Tor while the user wants it, and tells the UI where it is.
class TorController extends ChangeNotifier {
  TorController(this._backend, this._dir);

  final TorBackend _backend;
  final String _dir;
  Timer? _poll;
  late TorState _state = _backend.available
      ? const TorState(TorPhase.off)
      : const TorState(TorPhase.unavailable);

  TorRoute _route = TorRoute.auto;
  List<String> _bridges = const [];
  // under auto: which of [autoRoutes] is on, and for how many seconds it
  // has not been ready
  int _try = 0;
  int _waited = 0;

  TorState get state => _state;
  bool get available => _backend.available;

  /// Why the last way out failed, even after automatic mode moved on to
  /// the next one: "obfs4: ...". Empty when nothing failed.
  String get lastError => _lastError;
  String _lastError = '';
  bool get running => _poll != null;
  TorRoute get route => _route;

  /// The way out that came up last time, where automatic mode starts: on a
  /// network that blocks Tor, the bridge that worked, without first waiting
  /// on the direct way again.
  TorRoute? lastGood;

  /// Told when a way out came up under automatic mode, to keep it.
  ValueChanged<TorRoute>? onWorked;

  // under auto: how many ways out failed since the start
  int _failed = 0;

  /// Under auto on a backend that can race: the direct way and obfs4 go at
  /// the same time, and get the longer of their waits.
  bool get _racing =>
      _backend.canRace &&
      _route == TorRoute.auto &&
      autoRoutes[_try].$1 == TorRoute.direct;

  int get _limit => _racing ? autoRoutes[1].$2 : autoRoutes[_try].$2;

  /// Tor did not come up any way it tried: every way of automatic mode,
  /// or the one way the user chose. The app then offers bridges.
  bool get blocked => _blocked;
  bool _blocked = false;

  /// Tor has stopped inside Kilit and only a restart of Kilit brings it
  /// back.
  bool get needsRestart =>
      _state.error.contains(torNeedsRestart) ||
      _lastError.contains(torNeedsRestart);

  /// Tor's last log lines.
  String log() => _backend.log();

  /// The circuits Tor uses, when it is ready.
  List<List<String>> circuits() =>
      _state.phase == TorPhase.ready ? _backend.circuits() : const [];

  void _update(TorState s) {
    if (s.phase == _state.phase &&
        s.progress == _state.progress &&
        s.socks == _state.socks &&
        s.error == _state.error &&
        s.mode == _state.mode) {
      return;
    }
    _state = s;
    notifyListeners();
  }

  TorRoute get _now => _route == TorRoute.auto ? autoRoutes[_try].$1 : _route;

  /// Hands the way out to Tor; false when it refused.
  bool _apply() {
    final config = jsonEncode({
      'mode': _now.name,
      if (_now == TorRoute.custom) 'bridges': _bridges,
      if (_racing) 'race': [TorRoute.obfs4.name],
    });
    final err = _backend.start(_dir, config);
    if (err != null) {
      _update(TorState(TorPhase.failed, error: err, mode: _now.name));
      return false;
    }
    return true;
  }

  /// Starts Tor and watches it come up, going out the way [route] says.
  /// Called on a running Tor, it switches it to the new way.
  void start({
    TorRoute route = TorRoute.auto,
    List<String> bridges = const [],
  }) {
    if (!_backend.available) return;
    _route = route;
    _bridges = bridges;
    final first = autoRoutes.indexWhere((r) => r.$1 == lastGood);
    _try = route == TorRoute.auto && first > 0 ? first : 0;
    _waited = 0;
    _failed = 0;
    _blocked = false;
    _poll ??= Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    if (_apply()) _update(_backend.state());
  }

  /// A new way out; a running Tor takes it at once, a stopped one when it
  /// starts.
  void setRoute(TorRoute route, [List<String> bridges = const []]) {
    if (running) {
      start(route: route, bridges: bridges);
    } else {
      _route = route;
      _bridges = bridges;
    }
  }

  /// New circuits, and Tor goes out again the way it is set to; a Tor
  /// that is not running starts.
  void reconnect() {
    if (!_backend.available) return;
    if (!running) {
      start(route: _route, bridges: _bridges);
      return;
    }
    _waited = 0;
    _blocked = false;
    _lastError = '';
    final err = _backend.reconnect();
    if (err != null) {
      if (err.contains(torNeedsRestart)) {
        _lastError = err;
        _update(TorState(TorPhase.failed, error: err, mode: _now.name));
        return;
      }
      // not started in this process yet: start it the usual way
      if (!_apply()) return;
    }
    _update(_backend.state());
  }

  void _tick() {
    final s = _backend.state();
    if (s.phase == TorPhase.failed && s.error.isNotEmpty) {
      _lastError = s.mode.isEmpty ? s.error : '${s.mode}: ${s.error}';
    }
    if (s.phase == TorPhase.failed && s.error.contains(torNeedsRestart)) {
      // no way out helps: only a restart of Kilit
      _update(s);
      return;
    }
    if (s.phase == TorPhase.ready) {
      _waited = 0;
      _lastError = '';
      _blocked = false;
      if (_route == TorRoute.auto) {
        // the way that won, which a race decides
        final worked =
            TorRoute.values.where((r) => r.name == s.mode).firstOrNull ?? _now;
        if (worked != lastGood) {
          lastGood = worked;
          onWorked?.call(worked);
        }
      }
    } else if (_route == TorRoute.auto &&
        (s.phase == TorPhase.failed || ++_waited >= _limit)) {
      // a way out that failed is left at once, not after its full wait;
      // a race tried obfs4 already
      final tried = _racing ? 2 : 1;
      _failed += tried;
      if (_failed >= autoRoutes.length && !_blocked) {
        _blocked = true;
        notifyListeners();
      }
      _try = (_try + tried) % autoRoutes.length;
      _waited = 0;
      if (!_apply()) return;
    } else if (_route != TorRoute.auto &&
        !_blocked &&
        (s.phase == TorPhase.failed || ++_waited >= blockedAfter)) {
      _blocked = true;
      notifyListeners();
    } else if (_state.phase == TorPhase.failed && s.phase == TorPhase.off) {
      return; // keep showing why it did not start
    }
    _update(_backend.state());
  }

  void stop() {
    _poll?.cancel();
    _poll = null;
    _blocked = false;
    _backend.stop();
    _update(
      _backend.available
          ? const TorState(TorPhase.off)
          : const TorState(TorPhase.unavailable),
    );
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }
}
