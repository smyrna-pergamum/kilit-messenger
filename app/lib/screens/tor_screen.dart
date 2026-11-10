import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import '../platform/app_restart.dart';
import '../platform/tor.dart';
import '../state/prefs.dart';
import '../theme/theme.dart';
import '../theme/tokens.dart';

/// Saves a way out and hands it to Tor.
Future<void> useTorRoute(Prefs prefs, TorController tor, TorRoute r) async {
  await prefs.setTorRoute(r);
  tor.setRoute(r, prefs.bridges);
}

/// Offers bridges: when Tor did not come up ([blocked]), or when the user
/// asks. [onOwnBridges] opens the place to paste bridge lines.
Future<void> showTorBridges(
  BuildContext context, {
  required Prefs prefs,
  required TorController tor,
  required VoidCallback onOwnBridges,
  bool blocked = false,
}) {
  final l = L.of(context);
  final t = context.tokens;
  Widget choice(TorRoute r, String title, String? hint) => ListTile(
    key: ValueKey('bridges-${r.name}'),
    contentPadding: EdgeInsets.zero,
    leading: Icon(
      prefs.torRoute == r ? Icons.radio_button_checked : Icons.radio_button_off,
      color: t.accent,
    ),
    title: Text(title),
    subtitle: hint == null ? null : Text(hint),
    onTap: () async {
      Navigator.pop(context);
      await useTorRoute(prefs, tor, r);
    },
  );
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      key: const ValueKey('tor-bridges-dialog'),
      title: Text(blocked ? l.torBlockedTitle : l.settingsBridges),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.torBlockedBody),
              const SizedBox(height: 8),
              choice(TorRoute.auto, l.torRouteAuto, l.torRouteAutoHint),
              choice(TorRoute.obfs4, l.torRouteObfs4, l.torRouteObfs4Hint),
              choice(
                TorRoute.snowflake,
                l.torRouteSnowflake,
                l.torRouteSnowflakeHint,
              ),
              ListTile(
                key: const ValueKey('bridges-own'),
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.edit_note_rounded, color: t.accent),
                title: Text(l.torBlockedOwn),
                subtitle: Text(l.torBlockedOwnHint),
                onTap: () {
                  Navigator.pop(context);
                  onOwnBridges();
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          key: const ValueKey('bridges-later'),
          onPressed: () => Navigator.pop(context),
          child: Text(l.torBlockedLater),
        ),
      ],
    ),
  );
}

/// "Reconnect Tor", or "Restart Kilit" when Tor stopped for good in this
/// process.
class TorReconnectTile extends StatelessWidget {
  const TorReconnectTile({super.key, required this.tor});

  final TorController tor;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final t = context.tokens;
    return ListenableBuilder(
      listenable: tor,
      builder: (context, _) {
        if (tor.needsRestart) {
          return ListTile(
            key: const ValueKey('tor-restart'),
            leading: Icon(Icons.restart_alt_rounded, color: t.danger),
            title: Text(l.torRestartApp),
            subtitle: Text(l.torRestartHint),
            onTap: () async {
              if (!await AppRestart.restart() && context.mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(l.torRestartHint)));
              }
            },
          );
        }
        return ListTile(
          key: const ValueKey('tor-reconnect'),
          leading: Icon(Icons.refresh_rounded, color: t.accent),
          title: Text(l.torReconnect),
          subtitle: Text(l.torReconnectHint),
          onTap: () {
            tor.reconnect();
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(l.torReconnecting)));
          },
        );
      },
    );
  }
}

/// What tapping "Tor ready" opens: that the user's IP is hidden, the route
/// a message takes, a reconnect, bridges, and Tor's own log.
class TorScreen extends StatefulWidget {
  const TorScreen({
    super.key,
    required this.tor,
    required this.prefs,
    required this.onOwnBridges,
  });

  final TorController tor;
  final Prefs prefs;

  /// Opens the place to paste bridge lines.
  final VoidCallback onOwnBridges;

  @override
  State<TorScreen> createState() => _TorScreenState();
}

class _TorScreenState extends State<TorScreen> {
  String? _log;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final t = context.tokens;
    final tor = widget.tor;
    return Scaffold(
      appBar: AppBar(title: Text(l.torDetailsTitle)),
      body: ListenableBuilder(
        listenable: tor,
        builder: (context, _) {
          final s = tor.state;
          final ready = s.phase == TorPhase.ready;
          final circuits = tor.circuits();
          final hops = circuits.isNotEmpty ? circuits.first : const <String>[];
          final mode = s.mode.isEmpty || s.mode == 'direct'
              ? ''
              : ' (${s.mode})';
          final status = switch (s.phase) {
            TorPhase.off => l.torOff,
            TorPhase.starting => l.torStarting(s.progress),
            TorPhase.ready => l.torReady,
            TorPhase.failed => l.torFailed,
            TorPhase.unavailable => l.torUnavailable,
          };
          final color = switch (s.phase) {
            TorPhase.ready => t.safe,
            TorPhase.failed => t.danger,
            TorPhase.starting => t.accent,
            _ => t.textMuted,
          };
          final error = s.error.isNotEmpty ? s.error : tor.lastError;
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Card(
                  key: const ValueKey('tor-anon-card'),
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.shield_moon_outlined,
                          color: ready ? t.safe : t.textMuted,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l.torAnonTitle,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(l.torAnonBody),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ListTile(
                key: const ValueKey('tor-details-status'),
                leading: Icon(Icons.circle, size: 12, color: color),
                title: Text('$status$mode'),
                subtitle: !ready && error.isNotEmpty
                    ? Text(error, style: TextStyle(color: t.textMuted))
                    : null,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text(
                  l.torRouteTitle,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: _RouteDiagram(ready: ready, hops: hops),
              ),
              if (!ready)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    l.torNotReadyDiagram,
                    style: TextStyle(color: t.textMuted),
                  ),
                ),
              const Divider(),
              if (tor.available) TorReconnectTile(tor: tor),
              if (tor.available)
                ListTile(
                  key: const ValueKey('tor-details-bridges'),
                  leading: Icon(Icons.alt_route_rounded, color: t.accent),
                  title: Text(l.settingsBridges),
                  subtitle: Text(switch (widget.prefs.torRoute) {
                    TorRoute.auto => l.torRouteAuto,
                    TorRoute.direct => l.torRouteDirect,
                    TorRoute.obfs4 => l.torRouteObfs4,
                    TorRoute.snowflake => l.torRouteSnowflake,
                    TorRoute.custom => l.torRouteCustom,
                  }),
                  onTap: () => showTorBridges(
                    context,
                    prefs: widget.prefs,
                    tor: tor,
                    onOwnBridges: () {
                      Navigator.pop(context);
                      widget.onOwnBridges();
                    },
                  ),
                ),
              ExpansionTile(
                key: const ValueKey('tor-log'),
                leading: Icon(Icons.receipt_long_outlined, color: t.accent),
                title: Text(l.torLog),
                onExpansionChanged: (open) {
                  if (open) setState(() => _log = tor.log());
                },
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(maxHeight: 320),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: t.surfaceRaised,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SingleChildScrollView(
                            reverse: true,
                            child: SelectableText(
                              (_log ?? '').isEmpty ? l.torLogEmpty : _log!,
                              key: const ValueKey('tor-log-text'),
                              style: const TextStyle(
                                fontFamily: monoFamily,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton.icon(
                              onPressed: () => setState(() => _log = tor.log()),
                              icon: const Icon(Icons.refresh_rounded),
                              label: Text(l.torLogRefresh),
                            ),
                            TextButton.icon(
                              key: const ValueKey('tor-log-copy'),
                              onPressed: () async {
                                await Clipboard.setData(
                                  ClipboardData(text: tor.log()),
                                );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(l.torLogCopied)),
                                  );
                                }
                              },
                              icon: const Icon(Icons.copy_rounded),
                              label: Text(l.copy),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

/// You, three Tor relays, the Kilit relays: who sees what.
class _RouteDiagram extends StatelessWidget {
  const _RouteDiagram({required this.ready, required this.hops});

  final bool ready;

  /// The relays' nicknames, guard first; empty when Tor cannot tell.
  final List<String> hops;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final t = context.tokens;
    final on = ready ? t.safe : t.textMuted;
    String hop(int i) {
      final name = i < hops.length ? hops[i] : '';
      return name.isEmpty || name == 'Unnamed' ? l.torHopUnknown : name;
    }

    final nodes = <(IconData, String, String, Color)>[
      (Icons.smartphone_rounded, l.torRouteYou, l.torRouteYouHint, t.accent),
      (Icons.shield_outlined, hop(0), l.torHopGuard, on),
      (Icons.hub_outlined, hop(1), l.torHopMiddle, on),
      (Icons.logout_rounded, hop(2), l.torHopExit, on),
      (Icons.dns_outlined, l.torRouteRelays, l.torRouteRelaysHint, t.accent),
    ];
    return Column(
      key: const ValueKey('tor-route'),
      children: [
        for (var i = 0; i < nodes.length; i++) ...[
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: nodes[i].$4.withValues(alpha: 0.6)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              dense: true,
              leading: Icon(nodes[i].$1, color: nodes[i].$4),
              title: Text(
                nodes[i].$2,
                style: i > 0 && i < 4
                    ? const TextStyle(fontFamily: monoFamily, fontSize: 13)
                    : null,
              ),
              subtitle: Text(nodes[i].$3, style: TextStyle(color: t.textMuted)),
            ),
          ),
          if (i < nodes.length - 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.south_rounded, size: 18, color: on),
                  if (i == 0) ...[
                    const SizedBox(width: 6),
                    Icon(Icons.lock_outline_rounded, size: 14, color: on),
                    const SizedBox(width: 4),
                    Text(
                      l.torRouteLayers,
                      style: TextStyle(fontSize: 11, color: t.textMuted),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ],
    );
  }
}
