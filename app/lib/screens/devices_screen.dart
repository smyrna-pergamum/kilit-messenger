import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../core/kilit_core.dart';
import '../l10n/app_localizations.dart';
import '../platform/tor.dart';
import '../theme/theme.dart';
import '../theme/tokens.dart';
import '../state/chat_service.dart';
import 'chats_screen.dart' show ScanScreen;
import 'tor_screen.dart';

/// The name this device gives itself when it links another.
String _deviceKind() => Platform.isAndroid
    ? 'Android'
    : Platform.isWindows
    ? 'Windows'
    : Platform.operatingSystem;

const _linkPrefix = 'kilit://link?';

/// Settings, Linked devices: this ID's devices; on the phone, linking a
/// computer and taking one off; on a new Kilit, linking it to a phone.
class DevicesSection extends StatefulWidget {
  const DevicesSection({super.key, required this.core, this.tor, this.chats});

  final KilitCore core;

  /// The network rounds, hurried while linking.
  final ChatService? chats;

  /// Linking travels over Tor: shown while it is not ready.
  final TorController? tor;

  @override
  State<DevicesSection> createState() => _DevicesSectionState();
}

class _DevicesSectionState extends State<DevicesSection> {
  List<LinkedDevice> _devices = const [];
  bool _primary = true;
  bool _fresh = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final devices = await widget.core.devices();
    final primary = await widget.core.isPrimary();
    final contacts = await widget.core.contacts();
    if (!mounted) return;
    setState(() {
      _devices = devices;
      _primary = primary;
      _fresh = primary && devices.length <= 1 && contacts.isEmpty;
    });
  }

  String _name(L l, LinkedDevice d) => d.name.isNotEmpty
      ? d.name
      : d.id == 1
      ? l.devicePhone
      : l.deviceNumber(d.id);

  Future<void> _linkComputer() async {
    final l = L.of(context);
    final text = await Navigator.of(context)
        .push<String>(MaterialPageRoute(builder: (_) => const ScanScreen()));
    if (text == null || !mounted) return;
    if (!text.trim().startsWith(_linkPrefix)) {
      _say(l.linkNotCode);
      return;
    }
    final String code;
    try {
      code = await widget.core.linkAccept(text, _deviceKind());
      widget.chats?.hurry();
    } on Object catch (e) {
      // why, not just "not a code": a full device list, or no messaging yet
      if (mounted) _say(l.linkFailed('$e'));
      return;
    }
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LinkProgressScreen(
          core: widget.core,
          code: code,
          tor: widget.tor,
          chats: widget.chats,
        ),
      ),
    );
    await _load();
  }

  /// The phone: waits for a computer to ask by this Kilit ID.
  Future<void> _linkById() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LinkListenScreen(
          core: widget.core,
          tor: widget.tor,
          chats: widget.chats,
        ),
      ),
    );
    await _load();
  }

  Future<void> _linkToPhone() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LinkOfferScreen(
          core: widget.core,
          tor: widget.tor,
          chats: widget.chats,
        ),
      ),
    );
    await _load();
  }

  Future<void> _remove(LinkedDevice d) async {
    final l = L.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l.deviceRemoveConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.cancel),
          ),
          TextButton(
            key: const ValueKey('device-remove-yes'),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.deviceRemove),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await widget.core.unlinkDevice(d.id);
    await _load();
  }

  void _say(String m) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
          child: Text(
            _primary ? l.devicesIntro : l.linkedToPhone,
            style: TextStyle(color: t.textMuted),
          ),
        ),
        for (final d in _devices)
          ListTile(
            key: ValueKey('device-${d.id}'),
            leading: Icon(
              d.id == 1 ? Icons.smartphone_outlined : Icons.computer_outlined,
              color: t.accent,
            ),
            title: Text(_name(l, d)),
            subtitle: d.isThis ? Text(l.deviceThis) : null,
            trailing: _primary && !d.isThis
                ? TextButton(
                    key: ValueKey('device-remove-${d.id}'),
                    onPressed: () => _remove(d),
                    child: Text(l.deviceRemove),
                  )
                : null,
          ),
        if (_primary && !_fresh)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  key: const ValueKey('device-link-id'),
                  onPressed: _linkById,
                  icon: const Icon(Icons.alternate_email_rounded),
                  label: Text(l.deviceLinkById),
                ),
                OutlinedButton.icon(
                  key: const ValueKey('device-link'),
                  onPressed: _linkComputer,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: Text(l.deviceLink),
                ),
              ],
            ),
          ),
        if (_fresh)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OutlinedButton.icon(
                  key: const ValueKey('device-link-to-phone'),
                  onPressed: _linkToPhone,
                  icon: const Icon(Icons.phonelink_outlined),
                  label: Text(l.linkToPhone),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  key: const ValueKey('device-link-id'),
                  onPressed: _linkById,
                  icon: const Icon(Icons.alternate_email_rounded),
                  label: Text(l.deviceLinkById),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  key: const ValueKey('device-link'),
                  onPressed: _linkComputer,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: Text(l.deviceLink),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Waits for linking to finish, polling the core; [onCode] shows the code
/// once there is one.
mixin _LinkPoll<T extends StatefulWidget> on State<T> {
  Timer? _poll;
  LinkStatus status = const LinkStatus();

  KilitCore get core;

  void startPolling() {
    _poll ??= Timer.periodic(const Duration(seconds: 2), (_) => _check());
    unawaited(_check());
  }

  Future<void> _check() async {
    final s = await core.linkState();
    if (!mounted) return;
    setState(() => status = s);
    if (s.done) _poll?.cancel();
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }
}

/// A new device: the QR code the phone scans, then the code to compare.
class LinkOfferScreen extends StatefulWidget {
  const LinkOfferScreen({super.key, required this.core, this.tor, this.chats});

  final KilitCore core;
  final TorController? tor;
  final ChatService? chats;

  @override
  State<LinkOfferScreen> createState() => _LinkOfferScreenState();
}

class _LinkOfferScreenState extends State<LinkOfferScreen>
    with _LinkPoll<LinkOfferScreen> {
  // the phone's Kilit ID typed in, or the QR code to scan
  bool _byId = true;
  String? _offer;
  bool _refused = false;
  final _id = TextEditingController();
  bool _sending = false;
  String? _sent;
  String? Function(L)? _error;

  @override
  KilitCore get core => widget.core;

  @override
  void dispose() {
    _id.dispose();
    super.dispose();
  }

  Future<void> _showQr() async {
    if (_offer != null) return;
    try {
      final o = await widget.core.linkOffer();
      if (!mounted) return;
      setState(() => _offer = o);
      // the key goes to the relays, and the package comes, without waiting
      widget.chats?.hurry();
      startPolling();
    } on Object {
      if (mounted) setState(() => _refused = true);
    }
  }

  Future<void> _request() async {
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      final code = await widget.core.linkRequest(_id.text);
      if (!mounted) return;
      setState(() => _sent = code);
      widget.chats?.hurry();
      startPolling();
    } on Offline {
      if (mounted) setState(() => _error = (l) => l.addOffline);
    } on ContactRefused {
      if (mounted) setState(() => _error = (l) => l.addNotFound);
    } on NotNewKilit {
      if (mounted) setState(() => _refused = true);
    } on Object catch (e) {
      if (mounted) setState(() => _error = (l) => l.linkFailed('$e'));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Widget _waiting(KilitTokens t, L l) => Row(
    children: [
      const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(l.linkWaiting, style: TextStyle(color: t.textMuted)),
      ),
    ],
  );

  List<Widget> _byIdPanel(KilitTokens t, L l) {
    final sent = _sent;
    if (sent != null) {
      final qr = status.offer;
      return [
        Text(l.linkIdSent, style: TextStyle(color: t.textMuted)),
        const SizedBox(height: 12),
        _Code(sent),
        const SizedBox(height: 16),
        _waiting(t, l),
        _TorWait(tor: widget.tor),
        // the same request in a small code: the phone scans it instead
        if (qr != null) ...[
          const SizedBox(height: 24),
          Text(l.linkIdOrScan, style: TextStyle(color: t.textMuted)),
          const SizedBox(height: 12),
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: QrImageView(
                key: const ValueKey('link-id-qr'),
                data: qr,
                size: 200,
                errorCorrectionLevel: QrErrorCorrectLevel.M,
              ),
            ),
          ),
        ],
      ];
    }
    final error = _error?.call(l);
    return [
      Text(l.linkIdHelp, style: TextStyle(color: t.textMuted)),
      const SizedBox(height: 16),
      TextField(
        key: const ValueKey('link-id-field'),
        controller: _id,
        autocorrect: false,
        enableSuggestions: false,
        enableIMEPersonalizedLearning: false,
        style: const TextStyle(fontFamily: monoFamily),
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: l.linkIdField,
          hintText: '@word-word-word-word',
          errorText: error,
          errorMaxLines: 3,
        ),
        onSubmitted: (_) => _sending ? null : _request(),
      ),
      const SizedBox(height: 12),
      Align(
        alignment: AlignmentDirectional.centerEnd,
        child: FilledButton.icon(
          key: const ValueKey('link-id-send'),
          onPressed: _sending ? null : _request,
          icon: _sending
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.send_rounded),
          label: Text(l.linkIdSend),
        ),
      ),
      _TorWait(tor: widget.tor),
    ];
  }

  List<Widget> _qrPanel(KilitTokens t, L l) => [
    Text(l.linkToPhoneHint, style: TextStyle(color: t.textMuted)),
    const SizedBox(height: 16),
    if (_offer != null)
      Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          // a short code (the key's hash): few, large squares
          child: QrImageView(
            key: const ValueKey('link-qr'),
            data: _offer!,
            size: 280,
            errorCorrectionLevel: QrErrorCorrectLevel.M,
          ),
        ),
      ),
    const SizedBox(height: 16),
    _waiting(t, l),
    _TorWait(tor: widget.tor),
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.linkToPhone)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            if (_refused)
              Text(l.linkOnlyNew, key: const ValueKey('link-refused'))
            else if (status.done)
              _LinkDone(
                code: status.code,
                onClose: () => Navigator.pop(context),
              )
            else ...[
              if (_sent == null) ...[
                SegmentedButton<bool>(
                  key: const ValueKey('link-way'),
                  segments: [
                    ButtonSegment(
                      value: true,
                      icon: const Icon(Icons.alternate_email_rounded),
                      label: Text(l.linkById),
                    ),
                    ButtonSegment(
                      value: false,
                      icon: const Icon(Icons.qr_code_2_rounded),
                      label: Text(l.linkByQr),
                    ),
                  ],
                  selected: {_byId},
                  onSelectionChanged: (v) {
                    setState(() => _byId = v.first);
                    if (!_byId) _showQr();
                  },
                ),
                const SizedBox(height: 20),
              ],
              ...(_byId ? _byIdPanel(t, l) : _qrPanel(t, l)),
            ],
          ],
        ),
      ),
    );
  }
}

/// The phone: listens for a computer asking by this Kilit ID, and links it
/// once the user saw the same code on both screens.
class LinkListenScreen extends StatefulWidget {
  const LinkListenScreen({super.key, required this.core, this.tor, this.chats});

  final KilitCore core;
  final TorController? tor;
  final ChatService? chats;

  @override
  State<LinkListenScreen> createState() => _LinkListenScreenState();
}

class _LinkListenScreenState extends State<LinkListenScreen>
    with _LinkPoll<LinkListenScreen> {
  String? _me;
  String? _failed;
  bool _approving = false;

  @override
  KilitCore get core => widget.core;

  @override
  void initState() {
    super.initState();
    _listen();
  }

  Future<void> _listen() async {
    try {
      await widget.core.linkListen();
      final me = await widget.core.myKilit();
      if (!mounted) return;
      setState(() => _me = me.id);
      widget.chats?.hurry(const Duration(minutes: 15));
      startPolling();
    } on Object catch (e) {
      if (mounted) setState(() => _failed = '$e');
    }
  }

  /// The computer's QR code, scanned: its request, approved; or, from a
  /// computer showing only a code, linking the usual way.
  Future<void> _scan() async {
    final l = L.of(context);
    final text = await Navigator.of(context)
        .push<String>(MaterialPageRoute(builder: (_) => const ScanScreen()));
    if (text == null || !mounted) return;
    if (!text.trim().startsWith(_linkPrefix)) {
      setState(() => _failed = l.linkNotCode);
      return;
    }
    final String code;
    try {
      code = await widget.core.linkAccept(text, _deviceKind());
      widget.chats?.hurry();
    } on Object catch (e) {
      if (mounted) setState(() => _failed = '$e');
      return;
    }
    if (!mounted) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => LinkProgressScreen(
          core: widget.core,
          code: code,
          tor: widget.tor,
          chats: widget.chats,
        ),
      ),
    );
  }

  Future<void> _approve(LinkRequest r) async {
    setState(() => _approving = true);
    try {
      await widget.core.linkApprove(r.tag, _deviceKind());
      widget.chats?.hurry();
    } on Object catch (e) {
      if (mounted) {
        setState(() {
          _approving = false;
          _failed = '$e';
        });
      }
      return;
    }
    if (!mounted) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => LinkProgressScreen(
          core: widget.core,
          code: r.code,
          tor: widget.tor,
          chats: widget.chats,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    final me = _me;
    final failed = _failed;
    return Scaffold(
      appBar: AppBar(title: Text(l.deviceLinkById)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            if (failed != null)
              Text(
                l.linkFailed(failed),
                key: const ValueKey('link-listen-failed'),
                style: TextStyle(color: t.danger),
              )
            else ...[
              Text(l.linkListenHelp, style: TextStyle(color: t.textMuted)),
              if (me != null) ...[
                const SizedBox(height: 12),
                SelectableText(
                  '@$me',
                  key: const ValueKey('link-listen-id'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: monoFamily,
                    fontSize: 18,
                    color: t.accent,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              if (status.requests.isEmpty)
                Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l.linkListenWaiting,
                        style: TextStyle(color: t.textMuted),
                      ),
                    ),
                  ],
                )
              else ...[
                Text(l.linkRequestCode),
                const SizedBox(height: 8),
                for (final r in status.requests)
                  Card(
                    key: ValueKey('link-request-${r.tag}'),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _Code(r.code),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            key: ValueKey('link-approve-${r.tag}'),
                            onPressed: _approving ? null : () => _approve(r),
                            icon: const Icon(Icons.check_rounded),
                            label: Text(l.linkRequestApprove),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Text(l.linkRequestOther, style: TextStyle(color: t.textMuted)),
              ],
              const SizedBox(height: 16),
              OutlinedButton.icon(
                key: const ValueKey('link-listen-scan'),
                onPressed: _approving ? null : _scan,
                icon: const Icon(Icons.qr_code_scanner),
                label: Text(l.linkListenScan),
              ),
              _TorWait(tor: widget.tor),
              const SizedBox(height: 24),
              TextButton(
                key: const ValueKey('link-listen-cancel'),
                onPressed: () async {
                  await widget.core.linkCancel();
                  if (context.mounted) Navigator.pop(context);
                },
                child: Text(l.cancel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The phone, after scanning: the code to compare, until the new device
/// has answered.
class LinkProgressScreen extends StatefulWidget {
  const LinkProgressScreen({
    super.key,
    required this.core,
    required this.code,
    this.tor,
    this.chats,
  });

  final KilitCore core;

  /// The code to compare; empty until the computer's key came from the
  /// relays, then [LinkStatus.code].
  final String code;
  final TorController? tor;
  final ChatService? chats;

  @override
  State<LinkProgressScreen> createState() => _LinkProgressScreenState();
}

class _LinkProgressScreenState extends State<LinkProgressScreen>
    with _LinkPoll<LinkProgressScreen> {
  @override
  KilitCore get core => widget.core;

  @override
  void initState() {
    super.initState();
    startPolling();
  }

  String get _code => widget.code.isNotEmpty ? widget.code : status.code ?? '';

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.deviceLink)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            if (status.done)
              _LinkDone(code: _code, onClose: () => Navigator.pop(context))
            else if (_code.isEmpty) ...[
              Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l.linkFetchingKey,
                      key: const ValueKey('link-fetching'),
                      style: TextStyle(color: t.textMuted),
                    ),
                  ),
                ],
              ),
              _TorWait(tor: widget.tor),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () async {
                  await widget.core.linkCancel();
                  if (context.mounted) Navigator.pop(context);
                },
                child: Text(l.cancel),
              ),
            ] else ...[
              Text(l.linkCompare, style: TextStyle(color: t.textMuted)),
              const SizedBox(height: 12),
              _Code(_code),
              const SizedBox(height: 24),
              Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l.linkWaiting,
                      style: TextStyle(color: t.textMuted),
                    ),
                  ),
                ],
              ),
              _TorWait(tor: widget.tor),
              const SizedBox(height: 24),
              TextButton(
                key: const ValueKey('link-cancel'),
                onPressed: () async {
                  await widget.core.linkCancel();
                  if (context.mounted) Navigator.pop(context);
                },
                child: Text(l.cancel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// While Tor is not ready, linking cannot travel: says so, with a way to
/// reconnect.
class _TorWait extends StatelessWidget {
  const _TorWait({required this.tor});

  final TorController? tor;

  @override
  Widget build(BuildContext context) {
    final tor = this.tor;
    if (tor == null || !tor.available) return const SizedBox.shrink();
    final t = context.tokens;
    final l = L.of(context);
    return ListenableBuilder(
      listenable: tor,
      builder: (context, _) {
        if (tor.state.phase == TorPhase.ready) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Card(
            key: const ValueKey('link-tor-wait'),
            margin: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ListTile(
                  leading: Icon(Icons.wifi_off_rounded, color: t.danger),
                  title: Text(l.linkTorWait),
                ),
                TorReconnectTile(tor: tor),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Code extends StatelessWidget {
  const _Code(this.code);

  final String code;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Center(
      child: Text(
        code,
        key: const ValueKey('link-code'),
        style: TextStyle(
          fontFamily: monoFamily,
          fontSize: 40,
          fontWeight: FontWeight.w600,
          color: t.accent,
          letterSpacing: 4,
        ),
      ),
    );
  }
}

class _LinkDone extends StatelessWidget {
  const _LinkDone({required this.code, required this.onClose});

  final String? code;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    return Column(
      key: const ValueKey('link-done'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.check_circle_outline, size: 56, color: t.safe),
        const SizedBox(height: 12),
        Text(l.linkDone, textAlign: TextAlign.center),
        if (code != null) ...[
          const SizedBox(height: 24),
          Text(l.linkCompare, style: TextStyle(color: t.textMuted)),
          const SizedBox(height: 8),
          _Code(code!),
        ],
        const SizedBox(height: 24),
        FilledButton(onPressed: onClose, child: Text(l.close)),
      ],
    );
  }
}
