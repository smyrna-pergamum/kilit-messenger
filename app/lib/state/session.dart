import 'package:flutter/foundation.dart';

import '../core/kilit_core.dart';

enum SessionPhase { starting, needsSetup, locked, unlocked }

/// Whether the vault is open. The only app-wide state; screens read the
/// core directly for everything else.
class Session extends ChangeNotifier {
  Session(this.core);

  final KilitCore core;
  SessionPhase _phase = SessionPhase.starting;

  SessionPhase get phase => _phase;

  void _set(SessionPhase p) {
    _phase = p;
    notifyListeners();
  }

  Future<void> start() async {
    _set(await core.hasVault() ? SessionPhase.locked : SessionPhase.needsSetup);
  }

  Future<void> create(String pin) async {
    await core.createVault(pin);
    _set(SessionPhase.unlocked);
  }

  Future<UnlockResult> unlock(String pin) async {
    final r = await core.unlock(pin);
    if (r.outcome == UnlockOutcome.unlocked) _set(SessionPhase.unlocked);
    return r;
  }

  /// Locks at once: on request, and whenever the app leaves the screen.
  void lock() {
    if (_phase != SessionPhase.unlocked) return;
    core.lock();
    _set(SessionPhase.locked);
  }
}
