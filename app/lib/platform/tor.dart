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
  });

  final TorPhase phase;

  /// Bootstrap percentage, 0 to 100.
  final int progress;

  /// Tor's own words for the step it is on.
  final String summary;

  /// The local SOCKS5 port; 0 until Tor listens.
  final int socks;
  final String error;

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
    );
  }
}

/// The engine underneath: the embedded Tor on Android, nothing elsewhere.
abstract interface class TorBackend {
  bool get available;

  /// Starts Tor in [dir]/tor; returns an error, or null.
  String? start(String dir);
  TorState state();
  void stop();
}

/// engine-tor's libkilittor.so, through Dart's FFI. Every call returns at
/// once: Tor bootstraps on its own threads.
class NativeTor implements TorBackend {
  NativeTor._(DynamicLibrary lib)
    : _start = lib
          .lookupFunction<
            Pointer<Utf8> Function(Pointer<Utf8>),
            Pointer<Utf8> Function(Pointer<Utf8>)
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

  final Pointer<Utf8> Function(Pointer<Utf8>) _start;
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
  String? start(String dir) {
    final d = dir.toNativeUtf8();
    try {
      final err = _take(_start(d));
      return err.isEmpty ? null : err;
    } finally {
      malloc.free(d);
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
  String? start(String dir) => 'unavailable';

  @override
  TorState state() => const TorState(TorPhase.unavailable);

  @override
  void stop() {}
}

/// Runs Tor while the user wants it, and tells the UI where it is.
class TorController extends ChangeNotifier {
  TorController(this._backend, this._dir);

  final TorBackend _backend;
  final String _dir;
  Timer? _poll;
  late TorState _state = _backend.available
      ? const TorState(TorPhase.off)
      : const TorState(TorPhase.unavailable);

  TorState get state => _state;
  bool get available => _backend.available;

  void _update(TorState s) {
    if (s.phase == _state.phase &&
        s.progress == _state.progress &&
        s.socks == _state.socks &&
        s.error == _state.error) {
      return;
    }
    _state = s;
    notifyListeners();
  }

  /// Starts Tor and watches it come up.
  void start() {
    if (!_backend.available) return;
    final err = _backend.start(_dir);
    if (err != null) {
      _update(TorState(TorPhase.failed, error: err));
      return;
    }
    _poll ??= Timer.periodic(
      const Duration(seconds: 1),
      (_) => _update(_backend.state()),
    );
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
