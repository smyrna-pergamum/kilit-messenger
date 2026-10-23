import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/kilit_core.dart';
import '../l10n/app_localizations.dart';
import '../platform/files.dart';
import '../state/prefs.dart';
import '../theme/theme.dart';
import '../theme/tokens.dart';

String formatBytes(int n) {
  if (n < 1024) return '$n B';
  if (n < 1024 * 1024) return '${(n / 1024).toStringAsFixed(1)} KB';
  return '${(n / (1024 * 1024)).toStringAsFixed(1)} MB';
}

String formatDate(DateTime d) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(d.day)}.${two(d.month)}.${d.year} ${two(d.hour)}:${two(d.minute)}';
}

/// Kasa: the vault's packets, and carrier mode in and out.
class VaultScreen extends StatefulWidget {
  const VaultScreen({
    super.key,
    required this.core,
    required this.files,
    required this.prefs,
  });

  final KilitCore core;
  final FileAccess files;
  final Prefs prefs;

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  late Future<List<VaultItem>> _items = widget.core.items();
  StreamSubscription<void>? _incoming;
  String? _clipboardPacket;

  @override
  void initState() {
    super.initState();
    // things shared or opened into Kilit wait until the vault is open
    _incoming = widget.files.incomingReady.listen((_) => _takeIncoming());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _takeIncoming();
      if (widget.prefs.clipboardHint) _checkClipboard();
    });
  }

  @override
  void dispose() {
    _incoming?.cancel();
    super.dispose();
  }

  void _reload() {
    setState(() {
      _items = widget.core.items();
    });
  }

  void _say(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  /// The clipboard's text when it holds a KLT1: packet. Reading it is what
  /// makes Android show its "pasted from clipboard" notice.
  static Future<String?> _clipboardWithPacket() async {
    final text = (await Clipboard.getData(Clipboard.kTextPlain))?.text;
    return text != null && text.contains('KLT1:') ? text : null;
  }

  /// Offered at unlock when the user turned it on in settings.
  Future<void> _checkClipboard() async {
    final text = await _clipboardWithPacket();
    if (mounted && text != null) setState(() => _clipboardPacket = text);
  }

  /// The one-tap path for WhatsApp, which cannot share a message's text to
  /// other apps: copy it there, tap this here.
  Future<void> _openFromClipboard() async {
    final text = await _clipboardWithPacket();
    if (!mounted) return;
    if (text == null) {
      _say(L.of(context).clipboardEmpty);
      return;
    }
    await _openPasted(initial: text, fromClipboard: true);
  }

  Future<void> _takeIncoming() async {
    final got = await widget.files.takeIncoming();
    if (got == null || !mounted) return;
    final text = got.text;
    final file = got.file;
    if (text != null) {
      await _openPasted(initial: text);
    } else if (file != null) {
      await _import(file);
    }
  }

  Future<PickedFile?> _pick() async {
    try {
      return await widget.files.pick();
    } on FileTooLarge {
      if (mounted) _say(L.of(context).vaultFileTooLarge);
      return null;
    }
  }

  /// Pictures lose their metadata (location, camera, author) before they
  /// are sealed, so a later export or share cannot give it away.
  Future<void> _sealFile() async {
    final f = await _pick();
    if (f == null) return;
    final c = await widget.core.cleanMetadata(f.bytes);
    if (!mounted) return;
    if (c.outcome == CleanOutcome.damaged && await _sealDamaged() != true) {
      return;
    }
    await widget.core.addFile(f.name, f.mime, c.bytes ?? f.bytes);
    _reload();
    if (!mounted) return;
    final l = L.of(context);
    _say(switch (c.outcome) {
      CleanOutcome.cleaned when c.removed.isNotEmpty => l.vaultFileCleaned(
        f.name,
        _hiddenList(l, c.removed),
      ),
      CleanOutcome.unsupported => l.vaultFileUnchecked(f.name),
      _ => l.vaultFileSealed(f.name),
    });
  }

  Future<bool?> _sealDamaged() {
    final l = L.of(context);
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.damagedPictureTitle),
        content: Text(l.damagedPictureBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.cancel),
          ),
          TextButton(
            key: const ValueKey('confirm-seal-damaged'),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.damagedPictureSeal),
          ),
        ],
      ),
    );
  }

  /// What was removed, in words, most revealing first.
  static String _hiddenList(L l, Set<HiddenData> removed) {
    final words = <String>[
      if (removed.contains(HiddenData.location)) l.hiddenLocation,
      if (removed.contains(HiddenData.exif)) l.hiddenCamera,
      if (removed.any(
        (k) => const {
          HiddenData.xmp,
          HiddenData.iptc,
          HiddenData.comment,
          HiddenData.text,
        }.contains(k),
      ))
        l.hiddenAuthorNotes,
      if (removed.contains(HiddenData.extraImages)) l.hiddenExtraImages,
      if (removed.contains(HiddenData.other)) l.hiddenOther,
    ];
    return words.join(l.hiddenListSeparator);
  }

  Future<void> _openKlt() async {
    final f = await _pick();
    if (f != null) await _import(f);
  }

  Future<void> _import(PickedFile f) async {
    final imported = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ImportSheet(core: widget.core, file: f),
    );
    if (imported == true) _reload();
  }

  Future<void> _addNote() async {
    final added = await showDialog<bool>(
      context: context,
      builder: (_) => _NoteDialog(core: widget.core),
    );
    if (added == true) _reload();
  }

  Future<void> _compose() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          _CarrierComposeSheet(core: widget.core, files: widget.files),
    );
  }

  Future<void> _openPasted({
    String? initial,
    bool fromClipboard = false,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _PasteSheet(
        core: widget.core,
        initial: initial,
        fromClipboard: fromClipboard,
      ),
    );
    // opened messages were kept
    if (mounted) _reload();
  }

  Future<void> _details(VaultItem item) async {
    final deleted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          _PacketSheet(core: widget.core, files: widget.files, item: item),
    );
    if (deleted == true) _reload();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    final clipboard = _clipboardPacket;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (clipboard != null)
          MaterialBanner(
            key: const ValueKey('clipboard-banner'),
            backgroundColor: t.surfaceRaised,
            leading: Icon(Icons.content_paste_go_rounded, color: t.accent),
            content: Text(l.clipboardBanner),
            actions: [
              TextButton(
                onPressed: () => setState(() => _clipboardPacket = null),
                child: Text(l.clipboardBannerDismiss),
              ),
              TextButton(
                key: const ValueKey('clipboard-banner-open'),
                onPressed: () {
                  setState(() => _clipboardPacket = null);
                  _openPasted(initial: clipboard, fromClipboard: true);
                },
                child: Text(l.clipboardBannerOpen),
              ),
            ],
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                key: const ValueKey('add-note'),
                onPressed: _addNote,
                icon: const Icon(Icons.note_add_outlined),
                label: Text(l.vaultAddNote),
              ),
              OutlinedButton.icon(
                key: const ValueKey('compose-carrier'),
                onPressed: _compose,
                icon: const Icon(Icons.send_outlined),
                label: Text(l.vaultCompose),
              ),
              OutlinedButton.icon(
                key: const ValueKey('open-clipboard'),
                onPressed: _openFromClipboard,
                icon: const Icon(Icons.content_paste_go_rounded),
                label: Text(l.vaultOpenClipboard),
              ),
              OutlinedButton.icon(
                key: const ValueKey('open-pasted'),
                onPressed: _openPasted,
                icon: const Icon(Icons.content_paste_search_outlined),
                label: Text(l.vaultOpenPasted),
              ),
              OutlinedButton.icon(
                key: const ValueKey('seal-file'),
                onPressed: _sealFile,
                icon: const Icon(Icons.upload_file_outlined),
                label: Text(l.vaultSealFile),
              ),
              OutlinedButton.icon(
                key: const ValueKey('open-klt'),
                onPressed: _openKlt,
                icon: const Icon(Icons.file_open_outlined),
                label: Text(l.vaultOpenKlt),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<VaultItem>>(
            future: _items,
            builder: (context, snap) {
              final items = snap.data;
              if (items == null) {
                return const Center(child: CircularProgressIndicator());
              }
              if (items.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      l.vaultEmpty,
                      key: const ValueKey('vault-empty'),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: t.textMuted),
                    ),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, i) =>
                    _ItemTile(item: items[i], onTap: () => _details(items[i])),
              );
            },
          ),
        ),
      ],
    );
  }
}

IconData _iconFor(String mime) {
  if (mime.startsWith('image/')) return Icons.image_outlined;
  if (mime.startsWith('video/')) return Icons.movie_outlined;
  if (mime == 'application/pdf') return Icons.picture_as_pdf_outlined;
  if (mime.startsWith('text/')) return Icons.description_outlined;
  return Icons.insert_drive_file_outlined;
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({required this.item, required this.onTap});

  final VaultItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        leading: Icon(_iconFor(item.mime), color: t.accent),
        title: Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '${formatBytes(item.size)} · ${formatDate(item.added)}',
          style: TextStyle(color: t.textMuted),
        ),
        trailing: item.signed
            ? Tooltip(
                message: L.of(context).vaultSigned,
                child: Icon(Icons.verified_outlined, color: t.safe, size: 20),
              )
            : null,
      ),
    );
  }
}

class _NoteDialog extends StatefulWidget {
  const _NoteDialog({required this.core});

  final KilitCore core;

  @override
  State<_NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<_NoteDialog> {
  final _title = TextEditingController();
  final _text = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _text.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    if (title.isEmpty || _text.text.isEmpty) return;
    await widget.core.addNote(title, _text.text);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return AlertDialog(
      title: Text(l.noteNew),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const ValueKey('note-title'),
              controller: _title,
              decoration: InputDecoration(labelText: l.noteTitle),
              enableIMEPersonalizedLearning: false,
            ),
            const SizedBox(height: 12),
            TextField(
              key: const ValueKey('note-text'),
              controller: _text,
              decoration: InputDecoration(labelText: l.noteText),
              minLines: 3,
              maxLines: 8,
              enableIMEPersonalizedLearning: false,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l.cancel),
        ),
        FilledButton(
          key: const ValueKey('note-save'),
          onPressed: _save,
          child: Text(l.sealAndSave),
        ),
      ],
    );
  }
}

/// Writes a message, seals it and shows the `KLT1:` text to paste elsewhere.
class _CarrierComposeSheet extends StatefulWidget {
  const _CarrierComposeSheet({required this.core, required this.files});

  final KilitCore core;
  final FileAccess files;

  @override
  State<_CarrierComposeSheet> createState() => _CarrierComposeSheetState();
}

class _CarrierComposeSheetState extends State<_CarrierComposeSheet> {
  final _message = TextEditingController();
  final _passphrase = TextEditingController();
  bool _usePassphrase = true;
  String? _sealed;

  @override
  void dispose() {
    _message.dispose();
    _passphrase.dispose();
    super.dispose();
  }

  Future<void> _seal() async {
    if (_message.text.isEmpty) return;
    if (_usePassphrase && _passphrase.text.length < 12) return;
    final sealed = await widget.core.sealForCarrier(
      _message.text,
      passphrase: _usePassphrase ? _passphrase.text : null,
    );
    if (mounted) setState(() => _sealed = sealed);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    final sealed = _sealed;
    return _SheetFrame(
      title: l.carrierTitle,
      children: sealed == null
          ? [
              Text(l.carrierIntro, style: TextStyle(color: t.textMuted)),
              const SizedBox(height: 12),
              TextField(
                key: const ValueKey('carrier-message'),
                controller: _message,
                minLines: 3,
                maxLines: 8,
                decoration: InputDecoration(labelText: l.carrierMessage),
                enableIMEPersonalizedLearning: false,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _usePassphrase,
                onChanged: (v) => setState(() => _usePassphrase = v),
                title: Text(l.withPassphrase),
                subtitle: Text(l.carrierWithPassphraseHint),
              ),
              if (_usePassphrase)
                TextField(
                  key: const ValueKey('carrier-passphrase'),
                  controller: _passphrase,
                  obscureText: true,
                  enableIMEPersonalizedLearning: false,
                  decoration: InputDecoration(
                    labelText: l.passphrase,
                    helperText: l.carrierPassphraseHelper,
                  ),
                ),
              const SizedBox(height: 16),
              FilledButton(
                key: const ValueKey('carrier-seal'),
                onPressed: _seal,
                child: Text(l.carrierSeal),
              ),
            ]
          : [
              Text(l.carrierResultIntro, style: TextStyle(color: t.textMuted)),
              const SizedBox(height: 12),
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: t.surfaceRaised,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    sealed,
                    key: const ValueKey('carrier-result'),
                    style: TextStyle(
                      fontFamily: monoFamily,
                      fontSize: 12,
                      color: t.text,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l.carrierChars(sealed.length),
                style: TextStyle(color: t.textMuted),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      key: const ValueKey('carrier-copy'),
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: sealed));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(l.copied)));
                        }
                      },
                      icon: const Icon(Icons.copy_rounded),
                      label: Text(l.copy),
                    ),
                  ),
                  if (widget.files.canShare) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.icon(
                        key: const ValueKey('carrier-share'),
                        onPressed: () => widget.files.shareText(sealed),
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

/// Finds `KLT1:` packets in pasted text and opens the messages among them.
class _PasteSheet extends StatefulWidget {
  const _PasteSheet({
    required this.core,
    this.initial,
    this.fromClipboard = false,
  });

  final KilitCore core;

  /// Text from the clipboard, or shared into Kilit from another app.
  final String? initial;

  /// [initial] came from the clipboard, which is emptied once a message in
  /// it is kept.
  final bool fromClipboard;

  @override
  State<_PasteSheet> createState() => _PasteSheetState();
}

/// A note's name from a message: its first line, shortened.
String keptTitle(String text, String fallback) {
  final line = text.trim().split('\n').first.trim();
  if (line.isEmpty) return fallback;
  final chars = line.characters;
  return chars.length <= 40 ? line : '${chars.take(40)}…';
}

class _PasteSheetState extends State<_PasteSheet> {
  late final _pasted = TextEditingController(text: widget.initial);
  final _passphrase = TextEditingController();
  late bool _fromClipboard = widget.fromClipboard;

  /// Each result, and under an opened message whether it was kept.
  List<(String, String?)>? _results;

  @override
  void initState() {
    super.initState();
    // text that arrived from outside opens at once; a passphrase can follow
    if (widget.initial != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _open());
    }
  }

  @override
  void dispose() {
    _pasted.dispose();
    _passphrase.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      _pasted.text = data!.text!;
      _fromClipboard = true;
    }
  }

  Future<void> _open() async {
    final l = L.of(context);
    final found = widget.core.findPackets(_pasted.text);
    final results = <(String, String?)>[];
    var kept = false;
    if (found.isEmpty) results.add((l.pasteNone, null));
    for (final f in found) {
      final packet = f.packet;
      if (packet == null) {
        results.add((
          f.problem == FoundProblem.truncated
              ? l.pasteTruncated
              : l.pasteMalformed,
          null,
        ));
        continue;
      }
      final opened = await widget.core.openMessage(
        packet,
        passphrase: _passphrase.text.isEmpty ? null : _passphrase.text,
      );
      final text = opened.text;
      if (text == null) {
        results.add((
          switch (opened.failure) {
            OpenFailure.wrongKey => l.openWrongKey,
            OpenFailure.notAMessage => l.openIsFile,
            _ => l.openDamaged,
          },
          null,
        ));
        continue;
      }
      // read messages stay in the vault, once each
      final k = await widget.core.keepMessage(
        packet,
        keptTitle(text, l.keptTitleFallback),
        text,
      );
      kept = true;
      results.add((text, k.already ? l.alreadyInVault : l.keptInVault));
    }
    // the ciphertext has done its job; it does not stay on the clipboard
    if (kept && _fromClipboard) {
      await Clipboard.setData(const ClipboardData(text: ''));
      _fromClipboard = false;
    }
    if (mounted) setState(() => _results = results);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    final results = _results;
    return _SheetFrame(
      title: l.pasteTitle,
      children: [
        TextField(
          key: const ValueKey('paste-input'),
          controller: _pasted,
          minLines: 3,
          maxLines: 6,
          enableIMEPersonalizedLearning: false,
          decoration: InputDecoration(
            labelText: l.pasteInput,
            suffixIcon: IconButton(
              tooltip: l.pasteFromClipboard,
              icon: const Icon(Icons.content_paste_rounded),
              onPressed: _pasteFromClipboard,
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const ValueKey('paste-passphrase'),
          controller: _passphrase,
          obscureText: true,
          enableIMEPersonalizedLearning: false,
          decoration: InputDecoration(labelText: l.passphraseIfAny),
        ),
        const SizedBox(height: 16),
        FilledButton(
          key: const ValueKey('paste-open'),
          onPressed: _open,
          child: Text(l.pasteOpen),
        ),
        if (results != null) ...[
          const SizedBox(height: 16),
          for (final (text, note) in results)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(text, style: TextStyle(color: t.text)),
                    if (note != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 16,
                            color: t.safe,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              note,
                              key: const ValueKey('kept-note'),
                              style: TextStyle(color: t.textMuted),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ],
    );
  }
}

/// "Paket analizi": how an item is protected. Never shows key material.
class _PacketSheet extends StatelessWidget {
  const _PacketSheet({
    required this.core,
    required this.files,
    required this.item,
  });

  final KilitCore core;
  final FileAccess files;
  final VaultItem item;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    return FutureBuilder<PacketInfo>(
      future: core.inspect(item.id),
      builder: (context, snap) {
        final info = snap.data;
        Widget row(String k, String v, {Color? color}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 130,
                child: Text(k, style: TextStyle(color: t.textMuted)),
              ),
              Expanded(
                child: Text(v, style: TextStyle(color: color ?? t.text)),
              ),
            ],
          ),
        );
        return _SheetFrame(
          title: l.packetTitle,
          children: info == null
              ? [const Center(child: CircularProgressIndicator())]
              : [
                  row(l.packetFile, info.name),
                  row(l.packetType, info.mime),
                  row(
                    l.packetSize,
                    l.packetSizeValue(
                      formatBytes(info.contentBytes),
                      formatBytes(info.packetBytes),
                    ),
                  ),
                  row(l.packetFormat, l.packetFormatValue),
                  row(
                    l.packetRecipients,
                    info.recipients
                        .map(
                          (tag) => switch (tag) {
                            'klt-xwing' => l.recipientXwing,
                            'klt-argon2id' => l.recipientPassphrase,
                            _ => tag,
                          },
                        )
                        .join('\n'),
                  ),
                  row(l.packetContent, l.packetContentValue),
                  row(
                    l.packetSignature,
                    switch (info.signature) {
                      SignatureState.verified => l.sigVerified,
                      SignatureState.unsigned => l.sigUnsigned,
                      SignatureState.invalid => l.sigInvalid,
                    },
                    color: switch (info.signature) {
                      SignatureState.verified => t.safe,
                      SignatureState.unsigned => t.textMuted,
                      SignatureState.invalid => t.danger,
                    },
                  ),
                  if (info.signerFingerprint != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        info.signerFingerprint!,
                        style: TextStyle(
                          fontFamily: monoFamily,
                          fontSize: 12,
                          color: t.textMuted,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  if (info.mime.startsWith('text/')) ...[
                    FilledButton.icon(
                      key: const ValueKey('item-open'),
                      onPressed: () async {
                        final text = await core.readText(item.id);
                        if (!context.mounted) return;
                        await showDialog<void>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text(info.name),
                            content: SingleChildScrollView(child: Text(text)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(l.close),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.lock_open_outlined),
                      label: Text(l.itemOpen),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (info.mime.startsWith('image/')) ...[
                    FilledButton.icon(
                      key: const ValueKey('item-view-image'),
                      onPressed: () async {
                        final bytes = await core.readFile(item.id);
                        if (!context.mounted) return;
                        await showDialog<void>(
                          context: context,
                          builder: (_) => Dialog(
                            child: InteractiveViewer(
                              child: Image.memory(bytes, gaplessPlayback: true),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.image_outlined),
                      label: Text(l.itemView),
                    ),
                    const SizedBox(height: 8),
                  ],
                  OutlinedButton.icon(
                    key: const ValueKey('item-export'),
                    onPressed: () => showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) =>
                          _ExportSheet(core: core, files: files, item: item),
                    ),
                    icon: const Icon(Icons.ios_share_outlined),
                    label: Text(l.itemExport),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    key: const ValueKey('item-save-plain'),
                    onPressed: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(l.savePlainTitle),
                          content: Text(l.savePlainBody),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(l.cancel),
                            ),
                            TextButton(
                              key: const ValueKey('confirm-save-plain'),
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(l.itemSavePlain),
                            ),
                          ],
                        ),
                      );
                      if (ok != true) return;
                      final bytes = await core.readFile(item.id);
                      await files.save(info.name, info.mime, bytes);
                    },
                    icon: const Icon(Icons.lock_open_outlined),
                    label: Text(l.itemSavePlain),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    key: const ValueKey('item-delete'),
                    style: OutlinedButton.styleFrom(foregroundColor: t.danger),
                    onPressed: () async {
                      await core.deleteItem(item.id);
                      if (context.mounted) Navigator.pop(context, true);
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: Text(l.itemDelete),
                  ),
                ],
        );
      },
    );
  }
}

/// Seals an item again as a `.klt` file and saves it where the user picks.
class _ExportSheet extends StatefulWidget {
  const _ExportSheet({
    required this.core,
    required this.files,
    required this.item,
  });

  final KilitCore core;
  final FileAccess files;
  final VaultItem item;

  @override
  State<_ExportSheet> createState() => _ExportSheetState();
}

class _ExportSheetState extends State<_ExportSheet> {
  final _passphrase = TextEditingController();
  bool _usePassphrase = true;
  bool _tooShort = false;

  @override
  void dispose() {
    _passphrase.dispose();
    super.dispose();
  }

  Future<void> _export() async {
    if (_usePassphrase && _passphrase.text.length < 12) {
      setState(() => _tooShort = true);
      return;
    }
    final klt = await widget.core.exportKlt(
      widget.item.id,
      passphrase: _usePassphrase ? _passphrase.text : null,
    );
    final saved = await widget.files.save(
      klt.fileName,
      'application/x-kilit',
      klt.bytes,
    );
    if (mounted && saved) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    return _SheetFrame(
      title: l.exportTitle,
      children: [
        Text(l.exportIntro, style: TextStyle(color: t.textMuted)),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _usePassphrase,
          onChanged: (v) => setState(() => _usePassphrase = v),
          title: Text(l.withPassphrase),
          subtitle: Text(l.exportWithPassphraseHint),
        ),
        if (_usePassphrase)
          TextField(
            key: const ValueKey('export-passphrase'),
            controller: _passphrase,
            obscureText: true,
            enableIMEPersonalizedLearning: false,
            decoration: InputDecoration(
              labelText: l.passphrase,
              helperText: l.exportPassphraseHelper,
              errorText: _tooShort ? l.passphraseTooShort : null,
            ),
          ),
        const SizedBox(height: 16),
        FilledButton(
          key: const ValueKey('export-go'),
          onPressed: _export,
          child: Text(l.sealAndSave),
        ),
      ],
    );
  }
}

/// Opens a `.klt` file and seals its content into the vault.
class _ImportSheet extends StatefulWidget {
  const _ImportSheet({required this.core, required this.file});

  final KilitCore core;
  final PickedFile file;

  @override
  State<_ImportSheet> createState() => _ImportSheetState();
}

class _ImportSheetState extends State<_ImportSheet> {
  final _passphrase = TextEditingController();
  ImportOutcome? _failed;
  bool _busy = false;

  @override
  void dispose() {
    _passphrase.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    final l = L.of(context);
    setState(() => _busy = true);
    final r = await widget.core.importKlt(
      widget.file.bytes,
      passphrase: _passphrase.text.isEmpty ? null : _passphrase.text,
    );
    if (!mounted) return;
    if (r.outcome == ImportOutcome.imported) {
      final name = r.item!.name;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            r.signature == SignatureState.verified
                ? l.importAddedSigned(name)
                : l.importAddedUnsigned(name),
          ),
        ),
      );
      Navigator.pop(context, true);
      return;
    }
    setState(() {
      _busy = false;
      _failed = r.outcome;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    final failed = _failed;
    return _SheetFrame(
      title: l.importTitle,
      children: [
        Text(
          '${widget.file.name} · ${formatBytes(widget.file.bytes.length)}',
          style: TextStyle(color: t.textMuted),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const ValueKey('import-passphrase'),
          controller: _passphrase,
          obscureText: true,
          enableIMEPersonalizedLearning: false,
          decoration: InputDecoration(
            labelText: l.passphraseIfAny,
            helperText: l.importPassphraseHelper,
          ),
        ),
        if (failed != null) ...[
          const SizedBox(height: 12),
          Text(
            switch (failed) {
              ImportOutcome.wrongKey => l.importWrongKey,
              ImportOutcome.notKlt => l.importNotKlt,
              _ => l.importDamaged,
            },
            key: const ValueKey('import-result'),
            style: TextStyle(color: t.danger),
          ),
        ],
        const SizedBox(height: 16),
        FilledButton(
          key: const ValueKey('import-go'),
          onPressed: _busy ? null : _open,
          child: Text(l.importGo),
        ),
      ],
    );
  }
}

class _SheetFrame extends StatelessWidget {
  const _SheetFrame({required this.title, required this.children});

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
