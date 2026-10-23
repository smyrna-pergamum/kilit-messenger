import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/kilit_core.dart';
import '../l10n/app_localizations.dart';
import '../platform/files.dart';
import '../theme/theme.dart';
import '../theme/tokens.dart';
import 'vault_screen.dart' show formatDate;

/// A contact's name, or a placeholder with the start of their address.
String contactLabel(L l, Contact c) => c.name.isNotEmpty
    ? c.name
    : '${l.contactUnnamed} · ${c.id.substring(0, 6)}';

void _say(BuildContext context, String message) => ScaffoldMessenger.of(context)
  ..hideCurrentSnackBar()
  ..showSnackBar(SnackBar(content: Text(message)));

/// The contact list. Until the network arrives, cards and messages travel
/// as text through any chat app; Signal's protocol does the rest.
class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key, required this.core, required this.files});

  final KilitCore core;
  final FileAccess files;

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  late Future<List<Contact>> _contacts = widget.core.contacts();

  void _reload() => setState(() {
    _contacts = widget.core.contacts();
  });

  Future<void> _showCard() => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _CardSheet(core: widget.core, files: widget.files),
  );

  Future<void> _add({String? card}) async {
    final c = await showModalBottomSheet<Contact>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddContactSheet(core: widget.core, initial: card),
    );
    _reload();
    if (c != null && mounted) await _open(c);
  }

  Future<void> _open(Contact c) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            ChatScreen(core: widget.core, files: widget.files, contact: c),
      ),
    );
    _reload();
  }

  /// A card or messages copied in another app.
  Future<void> _fromClipboard() async {
    final l = L.of(context);
    final text = (await Clipboard.getData(Clipboard.kTextPlain))?.text ?? '';
    if (!mounted) return;
    if (text.contains('KLC1:')) {
      await _add(card: text);
      return;
    }
    if (!text.contains('KLM1:')) {
      _say(context, l.chatsNothingOnClipboard);
      return;
    }
    final got = await widget.core.receive(text);
    if (!mounted) return;
    final opened = got.where((m) => m.kind == IncomingKind.opened).toList();
    if (opened.isEmpty) {
      _say(context, incomingProblem(l, got.first.kind));
      return;
    }
    // read: the ciphertext does not stay on the clipboard
    await Clipboard.setData(const ClipboardData(text: ''));
    final contacts = await widget.core.contacts();
    _reload();
    final c = contacts.where((c) => c.id == opened.last.contact).firstOrNull;
    if (c != null && mounted) await _open(c);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                key: const ValueKey('add-contact'),
                onPressed: _add,
                icon: const Icon(Icons.person_add_alt_1_outlined),
                label: Text(l.chatsAddContact),
              ),
              OutlinedButton.icon(
                key: const ValueKey('share-card'),
                onPressed: _showCard,
                icon: const Icon(Icons.badge_outlined),
                label: Text(l.chatsShareCard),
              ),
              OutlinedButton.icon(
                key: const ValueKey('chat-open-clipboard'),
                onPressed: _fromClipboard,
                icon: const Icon(Icons.content_paste_go_rounded),
                label: Text(l.chatsOpenClipboard),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Contact>>(
            future: _contacts,
            builder: (context, snap) {
              final contacts = snap.data;
              if (contacts == null) {
                return const Center(child: CircularProgressIndicator());
              }
              if (contacts.isEmpty) {
                return Center(
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
                          l.chatsEmpty,
                          key: const ValueKey('chats-empty'),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: t.text),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l.chatsIntro,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: t.textMuted),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                itemCount: contacts.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final c = contacts[i];
                  final last = c.last;
                  return Card(
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      key: ValueKey('contact-${c.id}'),
                      onTap: () => _open(c),
                      leading: CircleAvatar(
                        backgroundColor: t.accent.withValues(alpha: 0.15),
                        child: Text(
                          c.name.isEmpty ? '?' : c.name.characters.first,
                          style: TextStyle(color: t.accent),
                        ),
                      ),
                      title: Text(
                        contactLabel(l, c),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        last == null
                            ? formatDate(c.added)
                            : '${last.outgoing ? '→ ' : ''}${last.text}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: t.textMuted),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Words for a message that could not be opened.
String incomingProblem(L l, IncomingKind kind) => switch (kind) {
  IncomingKind.duplicate => l.chatDuplicate,
  IncomingKind.unknown => l.chatUnknown,
  IncomingKind.truncated => l.pasteTruncated,
  IncomingKind.damaged || IncomingKind.opened => l.chatDamaged,
};

/// Text with Copy and Share, for a card or a sealed message.
class _SendableText extends StatelessWidget {
  const _SendableText({
    required this.text,
    required this.files,
    required this.prefix,
  });

  final String text;
  final FileAccess files;

  /// Keys the widgets, so tests find them.
  final String prefix;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          constraints: const BoxConstraints(maxHeight: 160),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: t.surfaceRaised,
            borderRadius: BorderRadius.circular(10),
          ),
          child: SingleChildScrollView(
            child: SelectableText(
              text,
              key: ValueKey('$prefix-text'),
              style: TextStyle(
                fontFamily: monoFamily,
                fontSize: 12,
                color: t.text,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                key: ValueKey('$prefix-copy'),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: text));
                  if (context.mounted) _say(context, l.copied);
                },
                icon: const Icon(Icons.copy_rounded),
                label: Text(l.copy),
              ),
            ),
            if (files.canShare) ...[
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  key: ValueKey('$prefix-share'),
                  onPressed: () => files.shareText(text),
                  icon: const Icon(Icons.share_rounded),
                  label: Text(l.share),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _Sheet extends StatelessWidget {
  const _Sheet({required this.title, required this.children});

  final String title;
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
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(color: t.text),
              ),
              const SizedBox(height: 12),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class _CardSheet extends StatefulWidget {
  const _CardSheet({required this.core, required this.files});

  final KilitCore core;
  final FileAccess files;

  @override
  State<_CardSheet> createState() => _CardSheetState();
}

class _CardSheetState extends State<_CardSheet> {
  final _name = TextEditingController();
  String? _card;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _make() async {
    final card = await widget.core.myCard(_name.text);
    if (mounted) setState(() => _card = card);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    final card = _card;
    return _Sheet(
      title: l.cardTitle,
      children: [
        Text(l.cardHint, style: TextStyle(color: t.textMuted)),
        const SizedBox(height: 12),
        TextField(
          key: const ValueKey('card-name'),
          controller: _name,
          enableIMEPersonalizedLearning: false,
          decoration: InputDecoration(labelText: l.cardName),
          onChanged: (_) {
            if (_card != null) setState(() => _card = null);
          },
        ),
        const SizedBox(height: 12),
        if (card == null)
          FilledButton(
            key: const ValueKey('card-make'),
            onPressed: _make,
            child: Text(l.cardShow),
          )
        else
          _SendableText(text: card, files: widget.files, prefix: 'card'),
      ],
    );
  }
}

class _AddContactSheet extends StatefulWidget {
  const _AddContactSheet({required this.core, this.initial});

  final KilitCore core;
  final String? initial;

  @override
  State<_AddContactSheet> createState() => _AddContactSheetState();
}

class _AddContactSheetState extends State<_AddContactSheet> {
  late final _card = TextEditingController(text: widget.initial);
  final _name = TextEditingController();
  bool _refused = false;
  bool _busy = false;

  @override
  void dispose() {
    _card.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _paste() async {
    final text = (await Clipboard.getData(Clipboard.kTextPlain))?.text;
    if (text != null) _card.text = text;
  }

  Future<void> _go() async {
    setState(() {
      _busy = true;
      _refused = false;
    });
    try {
      final c = await widget.core.addContact(_card.text, name: _name.text);
      if (mounted) Navigator.pop(context, c);
    } on ContactRefused {
      if (mounted) setState(() => _refused = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    return _Sheet(
      title: l.addContactTitle,
      children: [
        TextField(
          key: const ValueKey('contact-card'),
          controller: _card,
          minLines: 2,
          maxLines: 4,
          enableIMEPersonalizedLearning: false,
          decoration: InputDecoration(
            labelText: l.addContactCard,
            errorText: _refused ? l.addContactRefused : null,
            suffixIcon: IconButton(
              tooltip: l.pasteFromClipboard,
              icon: const Icon(Icons.content_paste_rounded),
              onPressed: _paste,
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const ValueKey('contact-name'),
          controller: _name,
          enableIMEPersonalizedLearning: false,
          decoration: InputDecoration(labelText: l.addContactName),
        ),
        const SizedBox(height: 16),
        FilledButton(
          key: const ValueKey('contact-add'),
          onPressed: _busy ? null : _go,
          child: Text(l.addContactGo),
        ),
        const SizedBox(height: 8),
        Text(l.cardHint, style: TextStyle(color: t.textMuted, fontSize: 12)),
      ],
    );
  }
}

/// One conversation.
class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.core,
    required this.files,
    required this.contact,
  });

  final KilitCore core;
  final FileAccess files;
  final Contact contact;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late Contact _contact = widget.contact;
  late Future<List<ChatLine>> _lines = widget.core.chat(_contact.id);
  final _input = TextEditingController();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _reload() => setState(() {
    _lines = widget.core.chat(_contact.id);
  });

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    final sealed = await widget.core.sendMessage(_contact.id, text);
    if (!mounted) return;
    _input.clear();
    _reload();
    final l = L.of(context);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _Sheet(
        title: l.chatSealedTitle,
        children: [
          Text(
            l.chatSealedHint(contactLabel(l, _contact)),
            style: TextStyle(color: context.tokens.textMuted),
          ),
          const SizedBox(height: 12),
          _SendableText(text: sealed, files: widget.files, prefix: 'sealed'),
        ],
      ),
    );
  }

  Future<void> _paste() async {
    final l = L.of(context);
    final text = (await Clipboard.getData(Clipboard.kTextPlain))?.text ?? '';
    if (!text.contains('KLM1:')) {
      if (mounted) _say(context, l.chatsNothingOnClipboard);
      return;
    }
    final got = await widget.core.receive(text);
    if (!mounted) return;
    if (got.any((m) => m.kind == IncomingKind.opened)) {
      await Clipboard.setData(const ClipboardData(text: ''));
      _reload();
      final other = got.where(
        (m) => m.kind == IncomingKind.opened && m.contact != _contact.id,
      );
      if (other.isNotEmpty && mounted) _say(context, l.chatOtherContact);
    } else if (mounted) {
      _say(context, incomingProblem(l, got.first.kind));
    }
  }

  Future<void> _rename() async {
    final value = await showDialog<String>(
      context: context,
      builder: (_) => _RenameDialog(initial: _contact.name),
    );
    if (value == null) return;
    await widget.core.renameContact(_contact.id, value);
    if (!mounted) return;
    setState(() {
      _contact = Contact(
        id: _contact.id,
        name: value,
        added: _contact.added,
        last: _contact.last,
      );
    });
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
    if (mounted) Navigator.pop(context);
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
              l.safetyHint(contactLabel(l, _contact)),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          contactLabel(l, _contact),
          key: const ValueKey('chat-title'),
        ),
        actions: [
          IconButton(
            key: const ValueKey('chat-safety'),
            tooltip: l.safetyTitle,
            icon: const Icon(Icons.verified_user_outlined),
            onPressed: _safety,
          ),
          PopupMenuButton<String>(
            key: const ValueKey('chat-menu'),
            onSelected: (v) => v == 'rename' ? _rename() : _remove(),
            itemBuilder: (_) => [
              PopupMenuItem(
                key: const ValueKey('menu-rename'),
                value: 'rename',
                child: Text(l.contactRename),
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
            if (_contact.name.isEmpty)
              MaterialBanner(
                key: const ValueKey('new-contact-banner'),
                backgroundColor: t.surfaceRaised,
                leading: Icon(Icons.person_search_outlined, color: t.accent),
                content: Text(l.chatNewContact),
                actions: [
                  TextButton(onPressed: _safety, child: Text(l.safetyTitle)),
                  TextButton(onPressed: _rename, child: Text(l.contactRename)),
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
                    itemBuilder: (context, i) =>
                        _Bubble(line: lines[lines.length - 1 - i]),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: Row(
                children: [
                  IconButton(
                    key: const ValueKey('chat-paste'),
                    tooltip: l.chatPaste,
                    icon: const Icon(Icons.content_paste_go_rounded),
                    onPressed: _paste,
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
                    icon: Icon(Icons.lock_outline, color: t.accent),
                    onPressed: _send,
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
  const _Bubble({required this.line});

  final ChatLine line;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final mine = line.outgoing;
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
            SelectableText(line.text, style: TextStyle(color: t.text)),
            const SizedBox(height: 2),
            Text(
              formatDate(line.at),
              style: TextStyle(color: t.textMuted, fontSize: 11),
            ),
          ],
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
