import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../platform/files.dart';
import '../platform/tor.dart';
import '../state/prefs.dart';
import '../state/session.dart';
import '../theme/tokens.dart';
import '../state/chat_service.dart';
import '../widgets/lock_button.dart';
import 'camera_screen.dart';
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
    required this.tor,
  });

  final Session session;
  final FileAccess files;
  final Prefs prefs;
  final TorController tor;

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
  // conversations first, as in any messenger
  int _index = 0;

  late final ChatService _chats = ChatService(widget.session.core, widget.tor);

  @override
  void dispose() {
    _chats.dispose();
    super.dispose();
  }

  Widget _page(L l) => switch (_index) {
    0 => ChatsScreen(
      session: widget.session,
      files: widget.files,
      chats: _chats,
      tor: widget.tor,
    ),
    1 => VaultScreen(
      core: widget.session.core,
      files: widget.files,
      prefs: widget.prefs,
    ),
    2 => CameraTab(
      core: widget.session.core,
      onSend: (context, jpeg) =>
          sendPhotoToSomeone(context, widget.session.core, _chats, jpeg),
    ),
    _ => SettingsScreen(
      session: widget.session,
      prefs: widget.prefs,
      files: widget.files,
      tor: widget.tor,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    final wide = MediaQuery.sizeOf(context).width >= wideLayoutWidth;
    // the chats page draws its own header, with the lock button in it
    final appBar = _index == 0
        ? null
        : AppBar(
            title: Text(_destinations[_index].label(l)),
            actions: [
              LockButton(session: widget.session),
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
