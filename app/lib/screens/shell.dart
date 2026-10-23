import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../platform/files.dart';
import '../state/prefs.dart';
import '../state/session.dart';
import '../theme/tokens.dart';
import '../widgets/panic_code.dart';
import 'chats_screen.dart';
import 'settings_screen.dart';
import 'vault_screen.dart';

/// Phones get a bottom bar; wide windows (Windows, tablets) a side rail.
const wideLayoutWidth = 720.0;

class Shell extends StatefulWidget {
  const Shell({
    super.key,
    required this.session,
    required this.files,
    required this.prefs,
  });

  final Session session;
  final FileAccess files;
  final Prefs prefs;

  @override
  State<Shell> createState() => _ShellState();
}

class _Destination {
  const _Destination(this.label, this.icon, this.selectedIcon);
  final String Function(L) label;
  final IconData icon;
  final IconData selectedIcon;
}

final _destinations = [
  _Destination((l) => l.navChats, Icons.chat_bubble_outline, Icons.chat_bubble),
  _Destination((l) => l.navVault, Icons.lock_outline, Icons.lock),
  _Destination(
    (l) => l.navCamera,
    Icons.photo_camera_outlined,
    Icons.photo_camera,
  ),
  _Destination((l) => l.navSettings, Icons.settings_outlined, Icons.settings),
];

class _ShellState extends State<Shell> {
  // the vault is what Aşama 1 can do, so it opens first
  int _index = 1;

  /// A new message replaces the one on screen instead of queueing.
  void _say(String message) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));

  /// Held down: the panic code erases everything.
  Future<void> _panic() async {
    final l = L.of(context);
    final session = widget.session;
    if (!await session.core.hasPanicCode()) {
      if (mounted) _say(l.panicNoCode);
      return;
    }
    if (!mounted) return;
    final code = await askPanicCode(context, confirm: false);
    if (code == null) return;
    if (!await session.panicWipe(code) && mounted) _say(l.panicWrong);
  }

  Widget _page(L l) => switch (_index) {
    0 => ChatsScreen(core: widget.session.core, files: widget.files),
    1 => VaultScreen(
      core: widget.session.core,
      files: widget.files,
      prefs: widget.prefs,
    ),
    2 => _ComingLater(text: l.cameraLater),
    _ => SettingsScreen(
      session: widget.session,
      prefs: widget.prefs,
      files: widget.files,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    final wide = MediaQuery.sizeOf(context).width >= wideLayoutWidth;
    final appBar = AppBar(
      title: Text(_destinations[_index].label(l)),
      actions: [
        // tap: lock; hold: the panic code
        Tooltip(
          message: l.panicTooltip,
          child: InkResponse(
            key: const ValueKey('lock-now'),
            radius: 24,
            onTap: widget.session.lock,
            onLongPress: _panic,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(
                Icons.gpp_maybe_outlined,
                color: t.danger,
                semanticLabel: l.panicTooltip,
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
    if (!wide) {
      return Scaffold(
        appBar: appBar,
        body: _page(l),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: [
            for (final d in _destinations)
              NavigationDestination(
                icon: Icon(d.icon),
                selectedIcon: Icon(d.selectedIcon),
                label: d.label(l),
              ),
          ],
        ),
      );
    }
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            labelType: NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Icon(Icons.lock_rounded, color: t.accent, size: 32),
            ),
            destinations: [
              for (final d in _destinations)
                NavigationRailDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.selectedIcon),
                  label: Text(d.label(l)),
                ),
            ],
          ),
          VerticalDivider(width: 1, color: t.outline),
          Expanded(
            child: Scaffold(appBar: appBar, body: _page(l)),
          ),
        ],
      ),
    );
  }
}

class _ComingLater extends StatelessWidget {
  const _ComingLater({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.hourglass_empty_rounded, size: 40, color: t.textMuted),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(color: t.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
