import 'package:flutter/foundation.dart';

import '../core/kilit_core.dart';

enum SessionPhase { starting, needsSetup, locked, unlocked }

/// Whether the vault is open. The only app-wide state; screens read the
/// core directly for everything else.
class Session extends ChangeNotifier {
  Session(this.core, {this.onWiped});

  final KilitCore core;

  /// After the panic code: puts app settings back as a new install has them.
  final Future<void> Function()? onWiped;
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
    switch (r.outcome) {
      case UnlockOutcome.unlocked:
        _set(SessionPhase.unlocked);
      case UnlockOutcome.wiped:
        await _reset();
      case UnlockOutcome.wrongPin || UnlockOutcome.waitBeforeRetry:
        break;
    }
    return r;
  }

  /// Everything was erased: start over as a new install, choosing a PIN.
  Future<void> _reset() async {
    await onWiped?.call();
    _set(SessionPhase.needsSetup);
  }

  /// The panic button. When [code] is the panic code everything is erased
  /// and Kilit starts over as if newly installed.
  Future<bool> panicWipe(String code) async {
    final wiped = await core.panicWipe(code);
    if (wiped) await _reset();
    return wiped;
  }

  /// Locks at once: on request, and whenever the app leaves the screen.
  void lock() {
    if (_phase != SessionPhase.unlocked) return;
    core.lock();
    _set(SessionPhase.locked);
  }
}
