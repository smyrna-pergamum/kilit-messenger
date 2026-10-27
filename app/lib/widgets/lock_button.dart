import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../state/session.dart';
import '../theme/tokens.dart';
import 'panic_code.dart';

/// Tap: lock. Hold: the panic code, which erases everything.
class LockButton extends StatelessWidget {
  const LockButton({super.key, required this.session});

  final Session session;

  static void _say(BuildContext context, String message) =>
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));

  Future<void> _panic(BuildContext context) async {
    final l = L.of(context);
    if (!await session.core.hasPanicCode()) {
      if (context.mounted) _say(context, l.panicNoCode);
      return;
    }
    if (!context.mounted) return;
    final code = await askPanicCode(context, confirm: false);
    if (code == null) return;
    if (!await session.panicWipe(code) && context.mounted) {
      _say(context, l.panicWrong);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    return Tooltip(
      message: l.panicTooltip,
      child: InkResponse(
        key: const ValueKey('lock-now'),
        radius: 24,
        onTap: session.lock,
        onLongPress: () => _panic(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(
            Icons.gpp_maybe_outlined,
            color: t.danger,
            semanticLabel: l.panicTooltip,
          ),
        ),
      ),
    );
  }
}
