import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/kilit_core.dart';
import '../platform/tor.dart';

/// Keeps the relays connected while the vault is open and Tor is ready, and
/// does a round of network work every few seconds: what arrived is opened,
/// what waits in the outbox goes. Screens listen for [revision] changes.
class ChatService extends ChangeNotifier {
  ChatService(this.core, this.tor, {this.every = const Duration(seconds: 3)}) {
    tor.addListener(_torChanged);
    _torChanged();
  }

  final KilitCore core;
  final TorController tor;
  final Duration every;

  Timer? _timer;
  bool _online = false;
  bool _busy = false;
  bool _disposed = false;
  NetTick _net = const NetTick();
  final _arrivals = StreamController<Arrived>.broadcast();

  /// Goes up whenever contacts or conversations may have changed.
  int revision = 0;

  /// Connected to the relays (through Tor).
  bool get online => _online;
  NetTick get net => _net;

  /// Each message as it arrives.
  Stream<Arrived> get arrivals => _arrivals.stream;

  void _torChanged() {
    final s = tor.state;
    if (s.phase == TorPhase.ready && s.socks > 0) {
      if (!_online) unawaited(_start(s.socks));
    } else if (_online) {
      _stop();
    }
  }

  Future<void> _start(int socks) async {
    _online = true;
    notifyListeners();
    try {
      await core.netStart(socks);
    } on Object {
      _online = false;
      if (!_disposed) notifyListeners();
      return;
    }
    if (_disposed) return;
    _timer = Timer.periodic(every, (_) => tick());
    await tick();
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
    _online = false;
    core.netStop();
    if (!_disposed) notifyListeners();
  }

  /// One round now; also after the user sends or adds someone.
  Future<void> tick() async {
    if (_busy || _disposed || !_online) return;
    _busy = true;
    try {
      final t = await core.netTick();
      if (_disposed) return;
      final changed =
          t.arrived.isNotEmpty ||
          t.relaysUp != _net.relaysUp ||
          t.queued != _net.queued;
      _net = t;
      for (final a in t.arrived) {
        _arrivals.add(a);
      }
      if (changed) {
        revision++;
        notifyListeners();
      }
    } on Object {
      // a failed round is retried on the next tick
    } finally {
      _busy = false;
    }
  }

  /// Something changed here (a message sent, a contact added).
  void touched() {
    revision++;
    notifyListeners();
    unawaited(tick());
  }

  @override
  void dispose() {
    _disposed = true;
    tor.removeListener(_torChanged);
    _timer?.cancel();
    if (_online) core.netStop();
    _arrivals.close();
    super.dispose();
  }
}
