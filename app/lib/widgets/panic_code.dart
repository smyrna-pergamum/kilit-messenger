import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/tokens.dart';
import 'pin_pad.dart';

/// A panic code has four digits; a PIN at least six, so they never meet.
const panicCodeLength = 4;

/// Asks for a panic code on the shuffled keypad. With [confirm] the code is
/// asked twice (setting it); without, once (the panic button). Returns the
/// code, or null when cancelled.
Future<String?> askPanicCode(BuildContext context, {required bool confirm}) =>
    showDialog<String>(
      context: context,
      builder: (_) => _PanicCodeDialog(confirm: confirm),
    );

class _PanicCodeDialog extends StatefulWidget {
  const _PanicCodeDialog({required this.confirm});

  final bool confirm;

  @override
  State<_PanicCodeDialog> createState() => _PanicCodeDialogState();
}

class _PanicCodeDialogState extends State<_PanicCodeDialog> {
  List<int> _order = shuffledDigits();
  final List<int> _entered = [];
  String? _first;
  bool _mismatch = false;

  @override
  void dispose() {
    _entered.clear();
    super.dispose();
  }

  void _submit() {
    final code = _entered.join();
    if (!widget.confirm) {
      Navigator.pop(context, code);
      return;
    }
    final first = _first;
    setState(() {
      _entered.clear();
      _order = shuffledDigits();
      if (first == null) {
        _first = code;
        _mismatch = false;
      } else if (first == code) {
        Navigator.pop(context, code);
      } else {
        _first = null;
        _mismatch = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    final title = !widget.confirm
        ? l.panicEnterTitle
        : _first == null
        ? l.panicCreateTitle
        : l.panicConfirmTitle;
    final hint = widget.confirm ? l.panicCreateHint : l.panicEnterHint;
    return AlertDialog(
      title: Text(title, key: const ValueKey('panic-dialog-title')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(hint, style: TextStyle(color: t.textMuted)),
            const SizedBox(height: 16),
            PinDots(
              count: _entered.length,
              slots: panicCodeLength,
              error: _mismatch,
            ),
            SizedBox(
              height: 32,
              child: Center(
                child: Text(
                  _mismatch ? l.panicMismatch : '',
                  style: TextStyle(color: t.danger),
                ),
              ),
            ),
            PinPad(
              order: _order,
              onDigit: (d) {
                if (_entered.length >= panicCodeLength) return;
                setState(() {
                  _entered.add(d);
                  _mismatch = false;
                });
              },
              onBackspace: () {
                if (_entered.isNotEmpty) setState(_entered.removeLast);
              },
              onSubmit: _submit,
              canSubmit: _entered.length == panicCodeLength,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.cancel),
        ),
      ],
    );
  }
}
