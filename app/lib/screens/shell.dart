import 'package:flutter/material.dart';

import '../state/session.dart';
import '../theme/tokens.dart';
import 'settings_screen.dart';
import 'vault_screen.dart';

/// Phones get a bottom bar; wide windows (Windows, tablets) a side rail.
const wideLayoutWidth = 720.0;

class Shell extends StatefulWidget {
  const Shell({super.key, required this.session});

  final Session session;

  @override
  State<Shell> createState() => _ShellState();
}

class _Destination {
  const _Destination(this.label, this.icon, this.selectedIcon);
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

const _destinations = [
  _Destination('Sohbetler', Icons.chat_bubble_outline, Icons.chat_bubble),
  _Destination('Kasa', Icons.lock_outline, Icons.lock),
  _Destination('Kamera', Icons.photo_camera_outlined, Icons.photo_camera),
  _Destination('Ayarlar', Icons.settings_outlined, Icons.settings),
];

class _ShellState extends State<Shell> {
  // the vault is what Aşama 1 can do, so it opens first
  int _index = 1;

  Widget _page() => switch (_index) {
    0 => const _ComingLater(
      title: 'Sohbetler',
      text: 'Tor üzerinden mesajlaşma Aşama 2\'de geliyor.',
    ),
    1 => VaultScreen(core: widget.session.core),
    2 => const _ComingLater(
      title: 'Kamera',
      text: 'Diske şifresiz yazmayan kamera Aşama 2\'de geliyor.',
    ),
    _ => SettingsScreen(session: widget.session),
  };

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final wide = MediaQuery.sizeOf(context).width >= wideLayoutWidth;
    final appBar = AppBar(
      title: Text(_destinations[_index].label),
      actions: [
        IconButton(
          key: const ValueKey('lock-now'),
          tooltip: 'Şimdi kilitle',
          icon: Icon(Icons.lock_clock_outlined, color: t.accent),
          onPressed: widget.session.lock,
        ),
      ],
    );
    if (!wide) {
      return Scaffold(
        appBar: appBar,
        body: _page(),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: [
            for (final d in _destinations)
              NavigationDestination(
                icon: Icon(d.icon),
                selectedIcon: Icon(d.selectedIcon),
                label: d.label,
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
                  label: Text(d.label),
                ),
            ],
          ),
          VerticalDivider(width: 1, color: t.outline),
          Expanded(
            child: Scaffold(appBar: appBar, body: _page()),
          ),
        ],
      ),
    );
  }
}

class _ComingLater extends StatelessWidget {
  const _ComingLater({required this.title, required this.text});

  final String title;
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
