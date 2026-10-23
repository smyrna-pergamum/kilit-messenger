import 'package:flutter/material.dart';

import '../core/kilit_core.dart';
import '../l10n/app_localizations.dart';
import '../platform/files.dart';
import '../state/prefs.dart';
import '../state/session.dart';
import '../theme/theme.dart';
import '../theme/tokens.dart';

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
  });

  final Session session;
  final Prefs prefs;
  final FileAccess files;

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
              _Status(
                key: const ValueKey('status-tor'),
                ok: null,
                title: l.protNetwork,
                value: l.protNetworkValue,
              ),
            ],
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
