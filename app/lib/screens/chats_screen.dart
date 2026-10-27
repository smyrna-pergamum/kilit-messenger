import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_zxing/flutter_zxing.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../core/kilit_core.dart';
import '../l10n/app_localizations.dart';
import '../platform/files.dart';
import '../platform/tor.dart';
import '../state/chat_service.dart';
import '../state/session.dart';
import '../theme/theme.dart';
import '../theme/tokens.dart';
import '../widgets/lock_button.dart';
import 'camera_screen.dart';
import 'vault_screen.dart' show formatDate;

/// A contact's name, or their Kilit ID until they get one.
String contactLabel(Contact c) => c.name.isNotEmpty ? c.name : '@${c.kilitId}';

void _say(BuildContext context, String message) => ScaffoldMessenger.of(context)
  ..hideCurrentSnackBar()
  ..showSnackBar(SnackBar(content: Text(message)));

String _clock(DateTime d) {
  final now = DateTime.now();
  String two(int v) => v.toString().padLeft(2, '0');
  return d.year == now.year && d.month == now.month && d.day == now.day
      ? '${two(d.hour)}:${two(d.minute)}'
      : '${two(d.day)}.${two(d.month)}';
}

/// The conversations: who you talk to, and who asked to talk to you.
class ChatsScreen extends StatefulWidget {
  const ChatsScreen({
    super.key,
    required this.session,
    required this.files,
    required this.chats,
    required this.tor,
    this.link,
  });

  final Session session;
  final FileAccess files;
  final ChatService chats;
  final TorController tor;

  /// A kilit:// link opened from another app, waiting to be added.
  final ValueNotifier<String?>? link;

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  KilitCore get core => widget.session.core;
  late Future<List<Contact>> _contacts = core.contacts();
  late Future<MyKilit> _me = core.myKilit();
  int _seen = -1;
  String? _search;

  @override
  void initState() {
    super.initState();
    widget.chats.addListener(_changed);
    widget.link?.addListener(_takeLink);
    WidgetsBinding.instance.addPostFrameCallback((_) => _takeLink());
  }

  @override
  void dispose() {
    widget.chats.removeListener(_changed);
    widget.link?.removeListener(_takeLink);
    super.dispose();
  }

  /// A link only fills in the sheet: adding still takes a tap, so a web
  /// page cannot add contacts behind the user's back.
  void _takeLink() {
    final link = widget.link?.value;
    if (link == null || !mounted) return;
    widget.link!.value = null;
    _add(initial: link);
  }

  void _changed() {
    if (widget.chats.revision != _seen) _reload();
  }

  void _reload() => setState(() {
    _seen = widget.chats.revision;
    _contacts = core.contacts();
  });

  Future<void> _open(Contact c) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChatScreen(
          core: core,
          chats: widget.chats,
          files: widget.files,
          contact: c,
        ),
      ),
    );
    _reload();
  }

  Future<void> _add({String? initial}) async {
    final c = await showModalBottomSheet<Contact>(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddSheet(
        core: core,
        files: widget.files,
        chats: widget.chats,
        initial: initial,
      ),
    );
    _reload();
    if (c != null && mounted) await _open(c);
  }

  Future<void> _requests() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RequestsScreen(core: core, chats: widget.chats),
      ),
    );
    _reload();
  }

  Future<void> _mine(MyKilit me) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MyKilitScreen(core: core, me: me, files: widget.files),
      ),
    );
    // the ID may have been renewed there
    if (!mounted) return;
    setState(() {
      _me = core.myKilit();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final now = DateTime.now();
    final big = Theme.of(context).textTheme.headlineMedium;
    return SafeArea(
      child: FutureBuilder<List<Contact>>(
        future: _contacts,
        builder: (context, snap) {
          final all = snap.data ?? const <Contact>[];
          final waiting = all.where((c) => c.standing == Standing.request);
          final q = _search?.trim().toLowerCase() ?? '';
          final talking = all
              .where((c) => c.standing == Standing.accepted)
              .where(
                (c) =>
                    q.isEmpty ||
                    c.name.toLowerCase().contains(q) ||
                    c.kilitId.contains(q),
              )
              .toList();
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${DateFormat.EEEE(locale).format(now)},',
                              style: big?.copyWith(color: t.text),
                            ),
                            Text(
                              DateFormat.MMMMd(locale).format(now),
                              style: big?.copyWith(
                                color: t.accent,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              l.chatsYourKilit,
                              style: TextStyle(
                                fontFamily: monoFamily,
                                fontSize: 12,
                                color: t.textMuted,
                              ),
                            ),
                            FutureBuilder<MyKilit>(
                              future: _me,
                              builder: (context, me) => InkWell(
                                key: const ValueKey('my-id'),
                                onTap: me.data == null
                                    ? null
                                    : () => _mine(me.data!),
                                child: Text(
                                  me.data == null ? '…' : '@${me.data!.id}',
                                  style: TextStyle(
                                    fontFamily: monoFamily,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: t.accent,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: _TorChip(
                              tor: widget.tor,
                              chats: widget.chats,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                key: const ValueKey('chats-search'),
                                tooltip: l.chatsSearch,
                                icon: const Icon(Icons.search),
                                onPressed: () => setState(
                                  () => _search = _search == null ? '' : null,
                                ),
                              ),
                              IconButton.outlined(
                                key: const ValueKey('add-contact'),
                                tooltip: l.addTitle,
                                icon: Icon(Icons.add, color: t.accent),
                                onPressed: _add,
                              ),
                              LockButton(session: widget.session),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (_search != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: TextField(
                      key: const ValueKey('chats-search-input'),
                      autofocus: true,
                      enableIMEPersonalizedLearning: false,
                      decoration: InputDecoration(
                        hintText: l.chatsSearch,
                        prefixIcon: const Icon(Icons.search),
                      ),
                      onChanged: (v) => setState(() => _search = v),
                    ),
                  ),
                ),
              if (waiting.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: Card(
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        key: const ValueKey('requests'),
                        leading: Icon(
                          Icons.mark_email_unread_outlined,
                          color: t.accent,
                        ),
                        title: Text(l.requestsTitle),
                        trailing: CircleAvatar(
                          radius: 12,
                          backgroundColor: t.accent,
                          child: Text(
                            '${waiting.length}',
                            style: TextStyle(color: t.surface, fontSize: 12),
                          ),
                        ),
                        onTap: _requests,
                      ),
                    ),
                  ),
                ),
              if (snap.hasData && talking.isEmpty && waiting.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.forum_outlined,
                            size: 40,
                            color: t.textMuted,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l.chatsEmptyNew,
                            key: const ValueKey('chats-empty'),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: t.textMuted),
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: _add,
                            icon: const Icon(Icons.person_add_alt_1_outlined),
                            label: Text(l.addTitle),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                  sliver: SliverList.builder(
                    itemCount: talking.length,
                    itemBuilder: (context, i) => _ContactTile(
                      contact: talking[i],
                      onTap: () => _open(talking[i]),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({required this.contact, required this.onTap});

  final Contact contact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final c = contact;
    final last = c.last;
    final label = contactLabel(c);
    return ListTile(
      key: ValueKey('contact-${c.id}'),
      onTap: onTap,
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: t.accent.withValues(alpha: 0.15),
        child: Text(
          label.replaceFirst('@', '').characters.first.toUpperCase(),
          style: TextStyle(color: t.accent, fontWeight: FontWeight.w600),
        ),
      ),
      title: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: t.text, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        last == null
            ? '@${c.kilitId}'
            : '${last.outgoing ? '→ ' : ''}${last.text}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: t.textMuted),
      ),
      trailing: last == null
          ? null
          : Text(
              _clock(last.at),
              style: TextStyle(color: t.textMuted, fontSize: 12),
            ),
    );
  }
}

/// Tor at a glance, and how many relays answer through it.
class _TorChip extends StatelessWidget {
  const _TorChip({required this.tor, required this.chats});

  final TorController tor;
  final ChatService chats;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    return ListenableBuilder(
      listenable: Listenable.merge([tor, chats]),
      builder: (context, _) {
        final s = tor.state;
        final net = chats.net;
        final relays = net.relays > 0 ? ' · ${net.relaysUp}/${net.relays}' : '';
        final (text, color) = switch (s.phase) {
          TorPhase.ready => ('${l.torChipReady}$relays', t.safe),
          TorPhase.starting => (l.torChipStarting(s.progress), t.accent),
          _ => (l.torChipOff, t.textMuted),
        };
        return Row(
          key: const ValueKey('tor-chip'),
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.radio_button_checked, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                fontFamily: monoFamily,
                fontSize: 12,
                color: color,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Sheet extends StatelessWidget {
  const _Sheet({required this.title, this.intro, required this.children});

  final String title;
  final String? intro;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          8,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(color: t.text, fontStyle: FontStyle.italic),
              ),
              if (intro != null) ...[
                const SizedBox(height: 8),
                Text(intro!, style: TextStyle(color: t.textMuted)),
              ],
              const SizedBox(height: 16),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

/// "Add someone": scan their code, or paste their link or @ID.
class AddSheet extends StatefulWidget {
  const AddSheet({
    super.key,
    required this.core,
    required this.files,
    required this.chats,
    this.initial,
  });

  final KilitCore core;
  final FileAccess files;
  final ChatService chats;

  /// Filled in from a kilit:// link.
  final String? initial;

  @override
  State<AddSheet> createState() => _AddSheetState();
}

class _AddSheetState extends State<AddSheet> {
  late final _text = TextEditingController(text: widget.initial);
  String? Function(L)? _error;
  bool _busy = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _go([String? scanned]) async {
    final text = scanned ?? _text.text;
    if (!widget.core.isInvite(text)) {
      setState(() => _error = (l) => l.addNotInvite);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final c = await widget.core.addContact(text);
      widget.chats.touched();
      if (mounted) Navigator.pop(context, c);
    } on Offline {
      if (mounted) setState(() => _error = (l) => l.addOffline);
    } on ContactRefused {
      if (mounted) setState(() => _error = (l) => l.addNotFound);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _scan() async {
    final text = await Navigator.of(context)
        .push<String>(MaterialPageRoute(builder: (_) => const ScanScreen()));
    if (text != null && mounted) {
      _text.text = text;
      await _go(text);
    }
  }

  Future<void> _mine() async {
    final me = await widget.core.myKilit();
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            MyKilitScreen(core: widget.core, me: me, files: widget.files),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    return _Sheet(
      title: l.addTitle,
      intro: l.addHint,
      children: [
        FilledButton.icon(
          key: const ValueKey('add-scan'),
          onPressed: _busy ? null : _scan,
          icon: const Icon(Icons.qr_code_scanner),
          label: Text(l.addScan),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const ValueKey('add-input'),
          controller: _text,
          enableIMEPersonalizedLearning: false,
          autocorrect: false,
          style: TextStyle(fontFamily: monoFamily, color: t.text),
          decoration: InputDecoration(
            hintText: l.addField,
            errorText: _error?.call(l),
            errorMaxLines: 3,
          ),
          onSubmitted: (_) => _go(),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          key: const ValueKey('add-go'),
          onPressed: _busy ? null : _go,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
          child: _busy
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 10),
                    Text(l.addSearching),
                  ],
                )
              : Text(l.addGo),
        ),
        const SizedBox(height: 16),
        Card(
          margin: EdgeInsets.zero,
          child: ListTile(
            key: const ValueKey('add-mine'),
            leading: Icon(Icons.qr_code_2, color: t.accent),
            title: Text(l.addShowMine),
            subtitle: Text(
              l.addShowMineHint,
              style: TextStyle(color: t.textMuted),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _mine,
          ),
        ),
      ],
    );
  }
}

/// This vault's QR code, link and @ID, and renewing the ID.
class MyKilitScreen extends StatefulWidget {
  const MyKilitScreen({
    super.key,
    required this.core,
    required this.me,
    required this.files,
  });

  final KilitCore core;
  final MyKilit me;
  final FileAccess files;

  @override
  State<MyKilitScreen> createState() => _MyKilitScreenState();
}

class _MyKilitScreenState extends State<MyKilitScreen> {
  late MyKilit _me = widget.me;

  Future<void> _renew() async {
    final l = L.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.renewTitle),
        content: Text(l.renewBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.cancel),
          ),
          TextButton(
            key: const ValueKey('renew-go'),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.renewGo),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final me = await widget.core.renewKilitId();
    if (!mounted) return;
    setState(() => _me = me);
    _say(context, l.renewDone(me.id));
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    final me = _me;
    final files = widget.files;
    return Scaffold(
      appBar: AppBar(title: Text(l.myTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  // a QR code reads best dark on light, whatever the theme
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: QrImageView(
                  key: const ValueKey('my-qr'),
                  data: me.link,
                  size: 240,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SelectableText(
              '@${me.id}',
              key: const ValueKey('my-kilit-id'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: monoFamily,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: t.accent,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l.myHint,
              textAlign: TextAlign.center,
              style: TextStyle(color: t.textMuted),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    key: const ValueKey('my-copy'),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: me.link));
                      if (context.mounted) _say(context, l.copied);
                    },
                    icon: const Icon(Icons.link),
                    label: Text(l.myCopyLink),
                  ),
                ),
                if (files.canShare) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      key: const ValueKey('my-share'),
                      onPressed: () =>
                          files.shareText(l.myShareText(me.id, me.link)),
                      icon: const Icon(Icons.share_rounded),
                      label: Text(l.share),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 28),
            TextButton.icon(
              key: const ValueKey('my-renew'),
              onPressed: _renew,
              icon: const Icon(Icons.autorenew),
              label: Text(l.renewTitle),
            ),
          ],
        ),
      ),
    );
  }
}

/// The camera, reading QR codes; returns the first one's text. Frames stay
/// in memory and are never saved.
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.scanTitle)),
      body: Stack(
        children: [
          ReaderWidget(
            codeFormat: Format.qrCode,
            showGallery: false,
            showToggleCamera: false,
            // decode nearly the whole frame: the default 50% crop misses a
            // code held close enough to fill the screen. tryHarder and
            // tryInverted read it in poorer light and from dark themes.
            cropPercent: 0.9,
            tryHarder: true,
            tryInverted: true,
            scanDelay: const Duration(milliseconds: 500),
            onScan: (code) {
              final text = code.text;
              if (_done || !code.isValid || text == null) return;
              _done = true;
              Navigator.pop(context, text);
            },
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 96,
            child: Text(
              l.scanHint,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

/// People who wrote without being added.
class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key, required this.core, required this.chats});

  final KilitCore core;
  final ChatService chats;

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  late Future<List<Contact>> _waiting = _load();

  Future<List<Contact>> _load() async => [
    for (final c in await widget.core.contacts())
      if (c.standing == Standing.request) c,
  ];

  Future<void> _do(Future<void> Function() f) async {
    await f();
    widget.chats.touched();
    if (mounted) {
      setState(() {
        _waiting = _load();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.requestsTitle)),
      body: FutureBuilder<List<Contact>>(
        future: _waiting,
        builder: (context, snap) {
          final list = snap.data ?? const <Contact>[];
          if (snap.hasData && list.isEmpty) {
            return Center(
              child: Text(
                l.requestsEmpty,
                key: const ValueKey('requests-empty'),
                style: TextStyle(color: t.textMuted),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(l.requestHint, style: TextStyle(color: t.textMuted)),
              const SizedBox(height: 12),
              for (final c in list)
                Card(
                  key: ValueKey('request-${c.id}'),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '@${c.kilitId}',
                          style: TextStyle(
                            fontFamily: monoFamily,
                            color: t.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (c.last != null) ...[
                          const SizedBox(height: 6),
                          Text(c.last!.text, style: TextStyle(color: t.text)),
                        ],
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            FilledButton(
                              key: ValueKey('accept-${c.id}'),
                              onPressed: () =>
                                  _do(() => widget.core.acceptContact(c.id)),
                              child: Text(l.requestAccept),
                            ),
                            OutlinedButton(
                              key: ValueKey('decline-${c.id}'),
                              onPressed: () =>
                                  _do(() => widget.core.removeContact(c.id)),
                              child: Text(l.requestDecline),
                            ),
                            TextButton(
                              key: ValueKey('block-${c.id}'),
                              onPressed: () =>
                                  _do(() => widget.core.blockContact(c.id)),
                              child: Text(
                                l.requestBlock,
                                style: TextStyle(color: t.danger),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// The disappearing-message times on offer.
const timerChoices = [
  Duration.zero,
  Duration(minutes: 5),
  Duration(hours: 1),
  Duration(days: 1),
  Duration(days: 7),
];

String timerLabel(L l, Duration d) => switch (d.inMinutes) {
  0 => l.timerOff,
  5 => l.timer5m,
  60 => l.timer1h,
  1440 => l.timer1d,
  _ => l.timer1w,
};

/// Picks a contact, then sends them [jpeg]; from the Camera tab.
Future<void> sendPhotoToSomeone(
  BuildContext context,
  KilitCore core,
  ChatService chats,
  Uint8List jpeg,
) async {
  final l = L.of(context);
  final contacts = [
    for (final c in await core.contacts())
      if (c.standing == Standing.accepted) c,
  ];
  if (!context.mounted) return;
  if (contacts.isEmpty) {
    _say(context, l.cameraNoContacts);
    return;
  }
  final to = await showModalBottomSheet<Contact>(
    context: context,
    builder: (context) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              l.cameraSendTo,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          for (final c in contacts)
            ListTile(
              key: ValueKey('send-to-${c.id}'),
              leading: const Icon(Icons.person_outline),
              title: Text(contactLabel(c)),
              onTap: () => Navigator.pop(context, c),
            ),
        ],
      ),
    ),
  );
  if (to == null) return;
  await core.sendFile(to.id, _photoName(), 'image/jpeg', jpeg);
  chats.touched();
  if (context.mounted) _say(context, l.cameraSent(contactLabel(to)));
}

String _photoName() {
  final n = DateTime.now();
  String two(int v) => v.toString().padLeft(2, '0');
  return 'kilit-${n.year}${two(n.month)}${two(n.day)}-'
      '${two(n.hour)}${two(n.minute)}${two(n.second)}.jpg';
}

String _size(int n) {
  if (n < 1024) return '$n B';
  if (n < 1024 * 1024) return '${(n / 1024).toStringAsFixed(0)} KB';
  return '${(n / (1024 * 1024)).toStringAsFixed(1)} MB';
}

/// One conversation.
class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.core,
    required this.chats,
    required this.files,
    required this.contact,
  });

  final KilitCore core;
  final ChatService chats;
  final FileAccess files;
  final Contact contact;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late Contact _contact = widget.contact;
  late Future<List<ChatLine>> _lines = widget.core.chat(_contact.id);
  final _input = TextEditingController();
  int _seen = -1;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    widget.chats.addListener(_changed);
  }

  @override
  void dispose() {
    widget.chats.removeListener(_changed);
    _input.dispose();
    super.dispose();
  }

  void _changed() {
    if (widget.chats.revision != _seen) _reload();
  }

  void _reload() => setState(() {
    _seen = widget.chats.revision;
    _lines = widget.core.chat(_contact.id);
  });

  /// A message not delivered yet: says what Kilit does about it, and sends
  /// it again now if asked.
  Future<void> _resend(ChatLine line) async {
    final l = L.of(context);
    final go = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Text(line.onRelay ? l.resendHint : l.chatQueued),
            ),
            ListTile(
              key: const ValueKey('line-resend'),
              leading: const Icon(Icons.refresh_rounded),
              title: Text(l.resend),
              onTap: () => Navigator.pop(context, true),
            ),
          ],
        ),
      ),
    );
    if (go != true || !mounted) return;
    await widget.core.resendMessage(_contact.id, line.id);
    widget.chats.touched();
    _reload();
    if (mounted) _say(context, l.resendDone);
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    _input.clear();
    await widget.core.sendMessage(_contact.id, text);
    widget.chats.touched();
    if (mounted) _reload();
  }

  Future<void> _sendFile(String name, String mime, Uint8List bytes) async {
    final l = L.of(context);
    if (bytes.length > maxChatFileBytes) {
      _say(context, l.chatFileTooLarge);
      return;
    }
    setState(() => _sending = true);
    try {
      final text = _input.text.trim();
      _input.clear();
      await widget.core.sendFile(_contact.id, name, mime, bytes, text: text);
      widget.chats.touched();
    } finally {
      if (mounted) {
        setState(() => _sending = false);
        _reload();
      }
    }
  }

  Future<void> _attach() async {
    final l = L.of(context);
    final what = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              key: const ValueKey('attach-camera'),
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l.attachCamera),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
            ListTile(
              key: const ValueKey('attach-file'),
              leading: const Icon(Icons.attach_file),
              title: Text(l.attachFile),
              onTap: () => Navigator.pop(context, 'file'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || what == null) return;
    if (what == 'camera') {
      final jpeg = await Navigator.of(context).push<Uint8List>(
        MaterialPageRoute(builder: (_) => CameraCapture(core: widget.core)),
      );
      if (jpeg != null) await _sendFile(_photoName(), 'image/jpeg', jpeg);
    } else {
      final PickedFile? f;
      try {
        f = await widget.files.pick();
      } on FileTooLarge {
        if (mounted) _say(context, l.chatFileTooLarge);
        return;
      }
      if (f != null) await _sendFile(f.name, f.mime, f.bytes);
    }
  }

  Future<void> _timer() async {
    final l = L.of(context);
    final chosen = await showDialog<Duration>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l.timerTitle),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(l.timerHint),
          ),
          RadioGroup<Duration>(
            groupValue: _contact.timer,
            onChanged: (v) => Navigator.pop(context, v),
            child: Column(
              children: [
                for (final d in timerChoices)
                  RadioListTile<Duration>(
                    key: ValueKey('timer-${d.inMinutes}'),
                    value: d,
                    title: Text(timerLabel(l, d)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    if (chosen == null) return;
    await widget.core.setTimer(_contact.id, chosen);
    widget.chats.touched();
    if (mounted) setState(() => _contact = _contact.withTimer(chosen));
  }

  Future<void> _rename() async {
    final value = await showDialog<String>(
      context: context,
      builder: (_) => _RenameDialog(initial: _contact.name),
    );
    if (value == null) return;
    await widget.core.renameContact(_contact.id, value);
    widget.chats.touched();
    if (mounted) setState(() => _contact = _contact.named(value));
  }

  Future<void> _remove() async {
    final l = L.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.contactRemoveTitle),
        content: Text(l.contactRemoveBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.cancel),
          ),
          TextButton(
            key: const ValueKey('remove-contact-go'),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.contactRemoveGo),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await widget.core.removeContact(_contact.id);
    widget.chats.touched();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _block() async {
    await widget.core.blockContact(_contact.id);
    widget.chats.touched();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _accept() async {
    await widget.core.acceptContact(_contact.id);
    widget.chats.touched();
    if (!mounted) return;
    setState(() {
      _contact = Contact(
        id: _contact.id,
        kilitId: _contact.kilitId,
        name: _contact.name,
        added: _contact.added,
        timer: _contact.timer,
      );
    });
  }

  Future<void> _safety() async {
    final l = L.of(context);
    final number = await widget.core.safetyNumber(_contact.id);
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.safetyTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.safetyHint(contactLabel(_contact)),
              style: TextStyle(color: context.tokens.textMuted),
            ),
            const SizedBox(height: 16),
            SelectableText(
              number,
              key: const ValueKey('safety-number'),
              style: TextStyle(
                fontFamily: monoFamily,
                fontSize: 16,
                height: 1.6,
                color: context.tokens.text,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.close),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    final timed = _contact.timer != Duration.zero;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(contactLabel(_contact), key: const ValueKey('chat-title')),
            if (_contact.name.isNotEmpty)
              Text(
                '@${_contact.kilitId}',
                style: TextStyle(
                  fontFamily: monoFamily,
                  fontSize: 12,
                  color: t.textMuted,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            key: const ValueKey('chat-timer'),
            tooltip: '${l.timerTitle}: ${timerLabel(l, _contact.timer)}',
            icon: Icon(
              timed ? Icons.timer : Icons.timer_outlined,
              color: timed ? t.accent : null,
            ),
            onPressed: _timer,
          ),
          IconButton(
            key: const ValueKey('chat-safety'),
            tooltip: l.safetyTitle,
            icon: const Icon(Icons.verified_user_outlined),
            onPressed: _safety,
          ),
          PopupMenuButton<String>(
            key: const ValueKey('chat-menu'),
            onSelected: (v) => switch (v) {
              'rename' => _rename(),
              'block' => _block(),
              _ => _remove(),
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                key: const ValueKey('menu-rename'),
                value: 'rename',
                child: Text(l.contactRename),
              ),
              PopupMenuItem(
                key: const ValueKey('menu-block'),
                value: 'block',
                child: Text(l.requestBlock),
              ),
              PopupMenuItem(
                key: const ValueKey('menu-remove'),
                value: 'remove',
                child: Text(l.contactRemove),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_contact.standing == Standing.request)
              MaterialBanner(
                key: const ValueKey('request-banner'),
                backgroundColor: t.surfaceRaised,
                leading: Icon(Icons.person_search_outlined, color: t.accent),
                content: Text(l.chatNewContact),
                actions: [
                  TextButton(onPressed: _accept, child: Text(l.requestAccept)),
                  TextButton(onPressed: _block, child: Text(l.requestBlock)),
                ],
              ),
            Expanded(
              child: FutureBuilder<List<ChatLine>>(
                future: _lines,
                builder: (context, snap) {
                  final lines = snap.data ?? const <ChatLine>[];
                  if (snap.hasData && lines.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          l.chatEmpty,
                          key: const ValueKey('chat-empty'),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: t.textMuted),
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(12),
                    itemCount: lines.length,
                    itemBuilder: (context, i) {
                      final line = lines[lines.length - 1 - i];
                      return _Bubble(
                        line: line,
                        core: widget.core,
                        files: widget.files,
                        onResend: line.outgoing && !line.delivered
                            ? () => _resend(line)
                            : null,
                      );
                    },
                  );
                },
              ),
            ),
            if (_sending) const LinearProgressIndicator(minHeight: 2),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 8, 8),
              child: Row(
                children: [
                  IconButton(
                    key: const ValueKey('chat-attach'),
                    tooltip: l.attachFile,
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: _sending ? null : _attach,
                  ),
                  Expanded(
                    child: TextField(
                      key: const ValueKey('chat-input'),
                      controller: _input,
                      minLines: 1,
                      maxLines: 5,
                      enableIMEPersonalizedLearning: false,
                      decoration: InputDecoration(hintText: l.chatInput),
                    ),
                  ),
                  IconButton(
                    key: const ValueKey('chat-send'),
                    tooltip: l.chatSend,
                    icon: Icon(Icons.send_rounded, color: t.accent),
                    onPressed: _sending ? null : _send,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.line,
    required this.core,
    required this.files,
    this.onResend,
  });

  final ChatLine line;
  final KilitCore core;
  final FileAccess files;

  /// For an outgoing message not delivered yet.
  final VoidCallback? onResend;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    final mine = line.outgoing;
    final file = line.file;
    final (IconData icon, String tip, String key, Color color) = !mine
        ? (Icons.done, '', '', t.textMuted)
        : line.delivered
        ? (Icons.done_all, l.chatDelivered, 'line-delivered', t.accent)
        : line.onRelay
        ? (Icons.done, l.chatOnRelay, 'line-sent', t.textMuted)
        : (Icons.schedule, l.chatQueued, 'line-queued', t.textMuted);
    return Align(
      alignment: mine
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: mine ? t.accent.withValues(alpha: 0.16) : t.surfaceRaised,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (file != null) _FileView(file: file, core: core, files: files),
            if (line.text.isNotEmpty)
              SelectableText(line.text, style: TextStyle(color: t.text)),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (line.expires != null) ...[
                  Icon(
                    Icons.timer_outlined,
                    key: const ValueKey('line-timed'),
                    size: 12,
                    color: t.textMuted,
                  ),
                  const SizedBox(width: 3),
                ],
                Text(
                  formatDate(line.at),
                  style: TextStyle(color: t.textMuted, fontSize: 11),
                ),
                if (mine) ...[
                  const SizedBox(width: 4),
                  Tooltip(
                    message: tip,
                    child: InkWell(
                      onTap: onResend,
                      customBorder: const CircleBorder(),
                      child: Icon(
                        icon,
                        key: ValueKey(key),
                        size: 14,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A picture shown in the bubble, or a file with its name; while its pieces
/// are still coming, a line that says so.
class _FileView extends StatelessWidget {
  const _FileView({
    required this.file,
    required this.core,
    required this.files,
  });

  final ChatFile file;
  final KilitCore core;
  final FileAccess files;

  Future<void> _actions(BuildContext context) async {
    final l = L.of(context);
    final what = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              key: const ValueKey('file-to-vault'),
              leading: const Icon(Icons.lock_outline),
              title: Text(l.fileToVault),
              onTap: () => Navigator.pop(context, 'vault'),
            ),
            ListTile(
              key: const ValueKey('file-save'),
              leading: const Icon(Icons.save_alt),
              title: Text(l.itemSavePlain),
              onTap: () => Navigator.pop(context, 'save'),
            ),
          ],
        ),
      ),
    );
    if (what == null || !context.mounted) return;
    final bytes = await core.readAttachment(file.blob);
    if (what == 'vault') {
      await core.addFile(file.name, file.mime, bytes);
      if (context.mounted) _say(context, l.fileSavedVault);
    } else {
      if (!context.mounted) return;
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l.savePlainTitle),
          content: Text(l.savePlainBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l.itemSavePlain),
            ),
          ],
        ),
      );
      if (ok == true) await files.save(file.name, file.mime, bytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    if (!file.ready) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          key: const ValueKey('file-coming'),
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                '${l.fileComing} · ${file.name} · ${_size(file.size)}',
                style: TextStyle(color: t.textMuted),
              ),
            ),
          ],
        ),
      );
    }
    if (file.isImage) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: GestureDetector(
          key: const ValueKey('file-image'),
          onLongPress: () => _actions(context),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => _PhotoView(file: file, core: core),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: FutureBuilder<Uint8List>(
              future: core.readAttachment(file.blob),
              builder: (context, snap) => snap.data == null
                  ? const SizedBox(
                      width: 180,
                      height: 120,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : Image.memory(
                      snap.data!,
                      width: 220,
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                    ),
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        key: const ValueKey('file-tile'),
        onTap: () => _actions(context),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.insert_drive_file_outlined, color: t.accent),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                '${file.name} · ${_size(file.size)}',
                style: TextStyle(color: t.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoView extends StatelessWidget {
  const _PhotoView({required this.file, required this.core});

  final ChatFile file;
  final KilitCore core;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(file.name),
      ),
      body: Center(
        child: FutureBuilder<Uint8List>(
          future: core.readAttachment(file.blob),
          builder: (context, snap) => snap.data == null
              ? const CircularProgressIndicator()
              : InteractiveViewer(child: Image.memory(snap.data!)),
        ),
      ),
    );
  }
}

/// Owns its text field, so the field lives as long as the dialog's closing
/// animation. Returns the new name, or null when cancelled.
class _RenameDialog extends StatefulWidget {
  const _RenameDialog({required this.initial});

  final String initial;

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  late final _name = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return AlertDialog(
      title: Text(l.contactRename),
      content: TextField(
        key: const ValueKey('rename-input'),
        controller: _name,
        autofocus: true,
        enableIMEPersonalizedLearning: false,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.cancel),
        ),
        TextButton(
          key: const ValueKey('rename-save'),
          onPressed: () => Navigator.pop(context, _name.text.trim()),
          child: Text(l.save),
        ),
      ],
    );
  }
}
