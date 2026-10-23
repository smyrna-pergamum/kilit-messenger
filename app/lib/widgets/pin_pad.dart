import 'dart:math';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/tokens.dart';

/// The ten digits in a fresh random order. Shuffled on every lock screen
/// and after every failed attempt, so finger smudges and shoulder surfers
/// learn nothing about where the PIN's digits are.
List<int> shuffledDigits([Random? random]) =>
    List<int>.generate(10, (i) => i)..shuffle(random ?? Random.secure());

/// A 4×3 keypad: nine digits, then backspace, the tenth digit, and OK.
class PinPad extends StatelessWidget {
  const PinPad({
    super.key,
    required this.order,
    required this.onDigit,
    required this.onBackspace,
    required this.onSubmit,
    required this.canSubmit,
    this.enabled = true,
  });

  final List<int> order;
  final ValueChanged<int> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback onSubmit;
  final bool canSubmit;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    Widget key(Widget child, VoidCallback? onTap, {String? label, Key? k}) {
      return Padding(
        padding: const EdgeInsets.all(6),
        child: Semantics(
          button: true,
          label: label,
          child: Material(
            color: t.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: t.outline),
            ),
            child: InkWell(
              key: k,
              borderRadius: BorderRadius.circular(16),
              onTap: enabled ? onTap : null,
              child: SizedBox(height: 64, child: Center(child: child)),
            ),
          ),
        ),
      );
    }

    Widget digit(int d) => key(
      Text(
        '$d',
        style: TextStyle(
          fontSize: 26,
          color: t.text,
          fontWeight: FontWeight.w500,
        ),
      ),
      () => onDigit(d),
      label: '$d',
      k: ValueKey('pin-digit-$d'),
    );

    final rows = <Widget>[
      for (var r = 0; r < 3; r++)
        Row(
          children: [
            for (var c = 0; c < 3; c++)
              Expanded(child: digit(order[r * 3 + c])),
          ],
        ),
      Row(
        children: [
          Expanded(
            child: key(
              Icon(Icons.backspace_outlined, color: t.textMuted),
              onBackspace,
              label: L.of(context).pinDelete,
              k: const ValueKey('pin-backspace'),
            ),
          ),
          Expanded(child: digit(order[9])),
          Expanded(
            child: key(
              Icon(
                Icons.arrow_forward_rounded,
                color: canSubmit ? t.accent : t.outline,
              ),
              canSubmit ? onSubmit : null,
              label: L.of(context).pinOk,
              k: const ValueKey('pin-submit'),
            ),
          ),
        ],
      ),
    ];
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Column(mainAxisSize: MainAxisSize.min, children: rows),
    );
  }
}

/// Filled and empty dots for the digits entered so far.
class PinDots extends StatelessWidget {
  const PinDots({
    super.key,
    required this.count,
    this.error = false,
    this.slots = 6,
  });

  final int count;
  final bool error;

  /// Empty dots shown before any digit is entered.
  final int slots;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final shown = max(count, slots);
    return Semantics(
      label: L.of(context).pinDigitsEntered(count),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < shown; i++)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < count
                    ? (error ? t.danger : t.accent)
                    : Colors.transparent,
                border: Border.all(
                  color: error ? t.danger : t.outline,
                  width: 2,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
