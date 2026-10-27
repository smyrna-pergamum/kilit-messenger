import 'package:flutter/material.dart';

import '../core/kilit_core.dart';
import '../l10n/app_localizations.dart';
import '../platform/files.dart';
import '../platform/tor.dart';
import '../state/prefs.dart';
import '../state/session.dart';
import '../theme/theme.dart';
import '../theme/tokens.dart';
import '../widgets/panic_code.dart';
import 'change_pin_dialog.dart';

/// Shown in "About"; kept in step with pubspec.yaml's version.
const appVersion = '0.1.0-alpha';

String pinProtectionName(L l, PinProtection p) => switch (p) {
  PinProtection.strongbox => l.hwStrongbox,
  PinProtection.tee => l.hwTee,
  PinProtection.tpm => l.hwTpm,
  PinProtection.osSoftware => l.hwOsSoftware,
  PinProtection.softwareFile => l.hwSoftwareFile,
  PinProtection.none => l.hwNone,
  PinProtection.dev => l.hwDev,
};

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.session,
    required this.prefs,
    required this.files,
    required this.tor,
  });

  final Session session;
  final Prefs prefs;
  final FileAccess files;
  final TorController tor;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    final core = session.core;
    return ListenableBuilder(
      listenable: prefs,
      builder: (context, _) => ListView(
        key: const ValueKey('settings-list'),
        padding: const EdgeInsets.all(16),
        children: [
          _Section(
            open: prefs.openSections,
            id: 'protections',
            icon: Icons.shield_outlined,
            title: l.settingsProtections,
            children: [
              _Status(
                key: const ValueKey('status-pin'),
                ok: core.isHardwareBacked,
                title: l.protPin,
                value: pinProtectionName(l, core.pinProtection),
                detail: core.isHardwareBacked
                    ? l.hwBoundHint
                    : l.hwNotBoundHint,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: OutlinedButton.icon(
                    key: const ValueKey('change-pin'),
                    onPressed: () async {
                      final done = await changePin(context, core);
                      if (done == true && context.mounted) {
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(content: Text(l.changePinDone)),
                          );
                      }
                    },
                    icon: const Icon(Icons.password_rounded),
                    label: Text(l.settingsChangePin),
                  ),
                ),
              ),
              _Status(
                ok: true,
                title: l.protScreenshots,
                value: l.protScreenshotsValue,
              ),
              _Status(
                ok: true,
                title: l.protAutoLock,
                value: l.protAutoLockValue,
              ),
              ListenableBuilder(
                listenable: tor,
                builder: (context, _) {
                  final s = tor.state;
                  return _Status(
                    key: const ValueKey('status-tor'),
                    ok: switch (s.phase) {
                      TorPhase.ready => true,
                      TorPhase.failed => false,
                      _ => null,
                    },
                    title: l.protNetwork,
                    value: switch (s.phase) {
                      TorPhase.off => l.torOff,
                      TorPhase.starting => l.torStarting(s.progress),
                      TorPhase.ready =>
                        s.mode.isEmpty || s.mode == 'direct'
                            ? l.torReady
                            : '${l.torReady} (${s.mode})',
                      TorPhase.failed => l.torFailed,
                      TorPhase.unavailable => l.torUnavailable,
                    },
                  );
                },
              ),
              if (tor.available)
                SwitchListTile(
                  key: const ValueKey('tor-switch'),
                  value: prefs.tor,
                  onChanged: (on) async {
                    await prefs.setTor(on);
                    on ? tor.start() : tor.stop();
                  },
                  title: Text(l.torSwitch),
                  subtitle: Text(l.torSwitchHint),
                ),
            ],
          ),
          if (tor.available)
            _Section(
              open: prefs.openSections,
              id: 'bridges',
              icon: Icons.alt_route_rounded,
              title: l.settingsBridges,
              children: [_TorRoutes(prefs: prefs, tor: tor)],
            ),
          _Section(
            open: prefs.openSections,
            id: 'panic',
            icon: Icons.gpp_maybe_outlined,
            title: l.settingsPanic,
            children: [_PanicSettings(core: core)],
          ),
          _Section(
            open: prefs.openSections,
            id: 'fingerprint',
            icon: Icons.fingerprint,
            title: l.settingsFingerprint,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.settingsFingerprintHint,
                      style: TextStyle(color: t.textMuted),
                    ),
                    const SizedBox(height: 12),
                    FutureBuilder<String>(
                      future: core.myFingerprint(),
                      builder: (context, snap) => SelectableText(
                        snap.data ?? '…',
                        key: const ValueKey('fingerprint'),
                        style: TextStyle(
                          fontFamily: monoFamily,
                          fontSize: 16,
                          color: t.text,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          _Section(
            open: prefs.openSections,
            id: 'appearance',
            icon: Icons.palette_outlined,
            title: l.settingsAppearance,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SegmentedButton<ThemeMode>(
                  key: const ValueKey('theme-choice'),
                  segments: [
                    ButtonSegment(
                      value: ThemeMode.system,
                      icon: const Icon(Icons.brightness_auto_outlined),
                      label: Text(l.themeSystem),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      icon: const Icon(Icons.light_mode_outlined),
                      label: Text(l.themeLight),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      icon: const Icon(Icons.dark_mode_outlined),
                      label: Text(l.themeDark),
                    ),
                  ],
                  selected: {prefs.themeMode},
                  onSelectionChanged: (s) => prefs.setThemeMode(s.first),
                ),
              ),
            ],
          ),
          _Section(
            open: prefs.openSections,
            id: 'language',
            icon: Icons.translate,
            title: l.settingsLanguage,
            children: [
              RadioGroup<String>(
                groupValue: prefs.language ?? '',
                onChanged: (v) =>
                    prefs.setLanguage(v == null || v.isEmpty ? null : v),
                child: Column(
                  children: [
                    RadioListTile<String>(
                      value: '',
                      title: Text(l.languageSystem),
                    ),
                    for (final e in supportedLanguages.entries)
                      RadioListTile<String>(
                        key: ValueKey('language-${e.key}'),
                        value: e.key,
                        title: Text(e.value),
                      ),
                  ],
                ),
              ),
            ],
          ),
          _Section(
            open: prefs.openSections,
            id: 'privacy',
            icon: Icons.visibility_off_outlined,
            title: l.settingsPrivacy,
            children: [
              SwitchListTile(
                key: const ValueKey('clipboard-hint'),
                value: prefs.clipboardHint,
                onChanged: prefs.setClipboardHint,
                title: Text(l.clipboardCheck),
                subtitle: Text(l.clipboardCheckHint),
              ),
            ],
          ),
          _Section(
            open: prefs.openSections,
            id: 'permissions',
            icon: Icons.admin_panel_settings_outlined,
            title: l.settingsPermissions,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                child: Text(l.permIntro, style: TextStyle(color: t.textMuted)),
              ),
              _Status(ok: null, title: l.permCamera, value: l.permCameraValue),
              _Status(
                ok: null,
                title: l.permNotifications,
                value: l.permNotificationsValue,
              ),
              _Status(
                ok: null,
                title: l.permInternet,
                value: l.permInternetValue,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: OutlinedButton.icon(
                  key: const ValueKey('open-permissions'),
                  onPressed: files.openAppSettings,
                  icon: const Icon(Icons.admin_panel_settings_outlined),
                  label: Text(l.permOpenSystem),
                ),
              ),
            ],
          ),
          _Section(
            open: prefs.openSections,
            id: 'about',
            icon: Icons.info_outline,
            title: l.settingsAbout,
            children: [
              ListTile(
                title: Text(l.aboutVersion),
                trailing: const Text(appVersion),
              ),
              ListTile(
                title: Text(l.aboutLicense),
                trailing: const Text('GPL-3.0-or-later'),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(l.aboutAlpha, style: TextStyle(color: t.textMuted)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          FilledButton.icon(
            onPressed: session.lock,
            icon: const Icon(Icons.lock_outline),
            label: Text(l.lockNow),
          ),
        ],
      ),
    );
  }
}

/// The panic code: what it does, whether it is set, and setting it.
/// How Tor reaches the network: straight, through built-in bridges, or
/// through the user's own lines.
class _TorRoutes extends StatefulWidget {
  const _TorRoutes({required this.prefs, required this.tor});

  final Prefs prefs;
  final TorController tor;

  @override
  State<_TorRoutes> createState() => _TorRoutesState();
}

class _TorRoutesState extends State<_TorRoutes> {
  late final TextEditingController _lines = TextEditingController(
    text: widget.prefs.bridges.join('\n'),
  );
  late TorRoute _shown = widget.prefs.torRoute;

  @override
  void dispose() {
    _lines.dispose();
    super.dispose();
  }

  List<String> get _typed => [
    for (final line in _lines.text.split('\n'))
      if (line.trim().isNotEmpty) line.trim(),
  ];

  Future<void> _use(TorRoute r) async {
    setState(() => _shown = r);
    // own bridges take effect once some are saved
    if (r == TorRoute.custom && _typed.isEmpty) return;
    await widget.prefs.setTorRoute(r, r == TorRoute.custom ? _typed : null);
    widget.tor.setRoute(r, widget.prefs.bridges);
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    String? hint(TorRoute r) => switch (r) {
      TorRoute.auto => l.torRouteAutoHint,
      TorRoute.direct => null,
      TorRoute.obfs4 => l.torRouteObfs4Hint,
      TorRoute.snowflake => l.torRouteSnowflakeHint,
      TorRoute.custom => l.torRouteCustomHint,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RadioGroup<TorRoute>(
          groupValue: _shown,
          onChanged: (r) {
            if (r != null) _use(r);
          },
          child: Column(
            children: [
              for (final r in TorRoute.values)
                RadioListTile<TorRoute>(
                  key: ValueKey('route-${r.name}'),
                  value: r,
                  title: Text(switch (r) {
                    TorRoute.auto => l.torRouteAuto,
                    TorRoute.direct => l.torRouteDirect,
                    TorRoute.obfs4 => l.torRouteObfs4,
                    TorRoute.snowflake => l.torRouteSnowflake,
                    TorRoute.custom => l.torRouteCustom,
                  }),
                  subtitle: hint(r) == null ? null : Text(hint(r)!),
                ),
            ],
          ),
        ),
        if (_shown == TorRoute.custom)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextField(
                  key: const ValueKey('bridge-lines'),
                  controller: _lines,
                  minLines: 3,
                  maxLines: 8,
                  autocorrect: false,
                  enableSuggestions: false,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: l.torRouteLinesHint,
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  key: const ValueKey('bridge-save'),
                  onPressed: () => _use(TorRoute.custom),
                  child: Text(l.save),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _PanicSettings extends StatefulWidget {
  const _PanicSettings({required this.core});

  final KilitCore core;

  @override
  State<_PanicSettings> createState() => _PanicSettingsState();
}

class _PanicSettingsState extends State<_PanicSettings> {
  late Future<bool> _set = widget.core.hasPanicCode();

  /// A new message replaces the one on screen instead of queueing.
  void _say(String message) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));

  Future<void> _choose() async {
    final l = L.of(context);
    final code = await askPanicCode(context, confirm: true);
    if (code == null) return;
    try {
      await widget.core.setPanicCode(code);
      if (mounted) _say(l.panicSaved);
    } on Object {
      if (mounted) _say(l.panicRejected);
    }
    if (!mounted) return;
    setState(() {
      _set = widget.core.hasPanicCode();
    });
  }

  Future<void> _remove() async {
    final l = L.of(context);
    await widget.core.clearPanicCode();
    if (!mounted) return;
    _say(l.panicRemoved);
    setState(() {
      _set = widget.core.hasPanicCode();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    return FutureBuilder<bool>(
      future: _set,
      builder: (context, snap) {
        final on = snap.data ?? false;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Text(l.panicExplain, style: TextStyle(color: t.textMuted)),
            ),
            _Status(
              key: const ValueKey('status-panic'),
              ok: on ? true : null,
              title: l.settingsPanic,
              value: on ? l.panicStatusOn : l.panicStatusOff,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    key: const ValueKey('panic-set'),
                    onPressed: snap.hasData ? _choose : null,
                    icon: const Icon(Icons.pin_outlined),
                    label: Text(on ? l.panicChange : l.panicSet),
                  ),
                  if (on)
                    OutlinedButton(
                      key: const ValueKey('panic-remove'),
                      onPressed: _remove,
                      child: Text(l.panicRemove),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// A card that opens and closes.
///
/// Which ones are open lives in [Prefs.openSections] for as long as the app
/// runs, so a trip to another tab leaves them as they were. Not PageStorage:
/// a PageStorageKey on the tile made the scrollable inside the safety
/// number's SelectableText read the tile's bool as a scroll offset, and the
/// section crashed when opened.
class _Section extends StatelessWidget {
  const _Section({
    required this.open,
    required this.id,
    required this.icon,
    required this.title,
    required this.children,
  });

  final Set<String> open;
  final String id;
  final IconData icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: ExpansionTile(
          initiallyExpanded: open.contains(id),
          onExpansionChanged: (isOpen) =>
              isOpen ? open.add(id) : open.remove(id),
          leading: Icon(icon, color: t.accent),
          title: Text(
            title,
            key: ValueKey('section-$id'),
            style: TextStyle(color: t.text, fontWeight: FontWeight.w600),
          ),
          iconColor: t.accent,
          collapsedIconColor: t.textMuted,
          // the card draws the frame; no extra lines when open
          shape: const Border(),
          collapsedShape: const Border(),
          expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
          childrenPadding: const EdgeInsets.only(bottom: 4),
          children: children,
        ),
      ),
    );
  }
}

/// One line of state with a dot: green on, red off, grey not in use.
class _Status extends StatelessWidget {
  const _Status({
    super.key,
    required this.ok,
    required this.title,
    required this.value,
    this.detail,
  });

  final bool? ok;
  final String title;
  final String value;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final color = switch (ok) {
      true => t.safe,
      false => t.danger,
      null => t.textMuted,
    };
    return ListTile(
      leading: Icon(Icons.circle, size: 12, color: color),
      title: Text(title),
      subtitle: Text(
        detail == null ? value : '$value\n$detail',
        style: TextStyle(color: t.textMuted),
      ),
      isThreeLine: detail != null,
    );
  }
}
