import 'package:flutter/material.dart';

import '../core/kilit_core.dart';
import '../l10n/app_localizations.dart';
import '../theme/tokens.dart';
import '../widgets/pin_pad.dart';
import 'lock_screen.dart' show maxPinLength, minPinLength;

/// Changes the vault's PIN: the current one, then the new one twice.
/// Returns true when the PIN was changed.
Future<bool?> changePin(BuildContext context, KilitCore core) =>
    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ChangePinDialog(core: core),
    );

enum _Step { current, fresh, confirm }

class _ChangePinDialog extends StatefulWidget {
  const _ChangePinDialog({required this.core});

  final KilitCore core;

  @override
  State<_ChangePinDialog> createState() => _ChangePinDialogState();
}

class _ChangePinDialogState extends State<_ChangePinDialog> {
  _Step _step = _Step.current;
  List<int> _order = shuffledDigits();
  final List<int> _entered = [];
  String? _current;
  String? _fresh;
  String? Function(L)? _message;
  bool _busy = false;

  @override
  void dispose() {
    _entered.clear();
    _current = null;
    _fresh = null;
    super.dispose();
  }

  void _next(_Step step, {String? Function(L)? message}) {
    _step = step;
    _entered.clear();
    _order = shuffledDigits();
    _message = message;
  }

  Future<void> _submit() async {
    final pin = _entered.join();
    switch (_step) {
      case _Step.current:
        setState(() {
          _current = pin;
          _next(_Step.fresh);
        });
      case _Step.fresh:
        setState(() {
          _fresh = pin;
          _next(_Step.confirm);
        });
      case _Step.confirm:
        if (pin != _fresh) {
          setState(() {
            _fresh = null;
            _next(_Step.fresh, message: (l) => l.lockMismatch);
          });
          return;
        }
        setState(() => _busy = true);
        final r = await widget.core.changePin(_current!, pin);
        if (!mounted) return;
        if (r.outcome == UnlockOutcome.unlocked) {
          Navigator.pop(context, true);
          return;
        }
        // the current PIN was wrong: start over from it
        setState(() {
          _busy = false;
          _current = null;
          _fresh = null;
          final wait = r.wait.inSeconds;
          _next(
            _Step.current,
            message: (l) => wait > 0 ? l.lockWait(wait) : l.lockWrongPin,
          );
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    final (title, hint) = switch (_step) {
      _Step.current => (l.changePinCurrent, null),
      _Step.fresh => (l.changePinNew, l.lockHintCreate(minPinLength)),
      _Step.confirm => (l.lockTitleConfirm, l.lockHintConfirm),
    };
    final message = _message?.call(l);
    return AlertDialog(
      title: Text(title, key: const ValueKey('change-pin-title')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hint != null) ...[
              Text(hint, style: TextStyle(color: t.textMuted)),
              const SizedBox(height: 16),
            ],
            PinDots(count: _entered.length, error: message != null),
            SizedBox(
              height: 32,
              child: Center(
                child: Text(
                  message ?? '',
                  key: const ValueKey('change-pin-message'),
                  style: TextStyle(color: t.danger),
                ),
              ),
            ),
            PinPad(
              order: _order,
              onDigit: (d) {
                if (_entered.length >= maxPinLength) return;
                setState(() {
                  _entered.add(d);
                  _message = null;
                });
              },
              onBackspace: () {
                if (_entered.isNotEmpty) setState(_entered.removeLast);
              },
              onSubmit: _submit,
              canSubmit: _entered.length >= minPinLength && !_busy,
              enabled: !_busy,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context, false),
          child: Text(l.cancel),
        ),
      ],
    );
  }
}
