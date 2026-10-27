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

  /// Starts Tor in [dir]/tor, going out the way [config] says (JSON:
  /// mode and, for custom, bridges), or changes the way out of a running
  /// one. Returns an error, or null.
  String? start(String dir, String config);
  TorState state();
  void stop();
}

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
}

/// A platform without Tor.
class NoTor implements TorBackend {
  const NoTor();

  @override
  bool get available => false;

  @override
  String? start(String dir, String config) => 'unavailable';

  @override
  TorState state() => const TorState(TorPhase.unavailable);

  @override
  void stop() {}
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
  bool get running => _poll != null;
  TorRoute get route => _route;

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
    _try = 0;
    _waited = 0;
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

  void _tick() {
    final s = _backend.state();
    if (s.phase == TorPhase.ready) {
      _waited = 0;
    } else if (_route == TorRoute.auto && ++_waited >= autoRoutes[_try].$2) {
      _try = (_try + 1) % autoRoutes.length;
      _waited = 0;
      if (!_apply()) return;
    } else if (_state.phase == TorPhase.failed && s.phase == TorPhase.off) {
      return; // keep showing why it did not start
    }
    _update(_backend.state());
  }

  void stop() {
    _poll?.cancel();
    _poll = null;
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
