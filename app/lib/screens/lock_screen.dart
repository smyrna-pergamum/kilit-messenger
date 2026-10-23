import 'dart:async';

import 'package:flutter/material.dart';

import '../core/kilit_core.dart';
import '../state/session.dart';
import '../theme/tokens.dart';
import '../widgets/pin_pad.dart';

const minPinLength = 6;
const maxPinLength = 12;

/// Creating a PIN on first run, and unlocking afterwards.
class LockScreen extends StatefulWidget {
  const LockScreen({super.key, required this.session});

  final Session session;

  @override
  State<LockScreen> createState() => _LockScreenState();
}

enum _Step { unlock, create, confirm }

class _LockScreenState extends State<LockScreen> {
  late _Step _step = widget.session.phase == SessionPhase.needsSetup
      ? _Step.create
      : _Step.unlock;
  List<int> _order = shuffledDigits();
  final List<int> _entered = [];
  String? _firstPin;
  String? _message;
  bool _error = false;
  bool _busy = false;
  DateTime? _retryAt;
  Timer? _ticker;

  @override
  void dispose() {
    _ticker?.cancel();
    _entered.clear();
    super.dispose();
  }

  String get _title => switch (_step) {
    _Step.unlock => 'Kilidi aç',
    _Step.create => 'Bir PIN belirle',
    _Step.confirm => 'PIN\'i tekrar gir',
  };

  String get _hint => switch (_step) {
    _Step.unlock => 'Kasanı açmak için PIN\'ini gir.',
    _Step.create =>
      'En az $minPinLength rakam. Unutursan kasan açılamaz: kurtarma yolu yok.',
    _Step.confirm => 'Aynı PIN\'i bir kez daha gir.',
  };

  bool get _waiting => _retryAt != null && DateTime.now().isBefore(_retryAt!);

  void _digit(int d) {
    if (_entered.length >= maxPinLength) return;
    setState(() {
      _entered.add(d);
      _error = false;
    });
  }

  void _backspace() {
    if (_entered.isEmpty) return;
    setState(() => _entered.removeLast());
  }

  void _reset({String? message, bool error = false}) {
    _entered.clear();
    _order = shuffledDigits();
    _message = message;
    _error = error;
  }

  void _startWait(Duration wait) {
    _retryAt = DateTime.now().add(wait);
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      if (!_waiting) {
        t.cancel();
        _retryAt = null;
      }
      setState(() {});
    });
  }

  Future<void> _submit() async {
    if (_entered.length < minPinLength || _busy || _waiting) return;
    final pin = _entered.join();
    setState(() => _busy = true);
    try {
      switch (_step) {
        case _Step.create:
          setState(() {
            _firstPin = pin;
            _step = _Step.confirm;
            _reset();
          });
        case _Step.confirm:
          if (pin != _firstPin) {
            setState(() {
              _firstPin = null;
              _step = _Step.create;
              _reset(message: 'PIN\'ler eşleşmedi. Baştan başla.', error: true);
            });
            return;
          }
          _firstPin = null;
          _entered.clear();
          await widget.session.create(pin);
        case _Step.unlock:
          final r = await widget.session.unlock(pin);
          if (!mounted) return;
          if (r.outcome == UnlockOutcome.unlocked) {
            _entered.clear();
            return;
          }
          setState(() {
            if (r.wait > Duration.zero) _startWait(r.wait);
            _reset(
              message: r.outcome == UnlockOutcome.waitBeforeRetry
                  ? null
                  : 'PIN yanlış.',
              error: true,
            );
          });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final waitLeft = _waiting
        ? _retryAt!.difference(DateTime.now()).inSeconds + 1
        : 0;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.session.core.isDevelopmentStub) const _DevBanner(),
                Icon(Icons.lock_rounded, size: 48, color: t.accent),
                const SizedBox(height: 16),
                Text(
                  _title,
                  key: const ValueKey('lock-title'),
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(color: t.text),
                ),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 340),
                  child: Text(
                    _hint,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: t.textMuted),
                  ),
                ),
                const SizedBox(height: 28),
                PinDots(count: _entered.length, error: _error),
                SizedBox(
                  height: 40,
                  child: Center(
                    child: Text(
                      _waiting
                          ? 'Tekrar denemek için $waitLeft sn bekle.'
                          : (_message ?? ''),
                      key: const ValueKey('lock-message'),
                      style: TextStyle(color: t.danger),
                    ),
                  ),
                ),
                PinPad(
                  order: _order,
                  onDigit: _digit,
                  onBackspace: _backspace,
                  onSubmit: _submit,
                  canSubmit: _entered.length >= minPinLength && !_busy,
                  enabled: !_busy && !_waiting,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DevBanner extends StatelessWidget {
  const _DevBanner();

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: t.danger.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: t.danger),
      ),
      child: Text(
        'Geliştirme çekirdeği: gerçek şifreleme yok.',
        key: const ValueKey('dev-banner'),
        style: TextStyle(color: t.text),
      ),
    );
  }
}
