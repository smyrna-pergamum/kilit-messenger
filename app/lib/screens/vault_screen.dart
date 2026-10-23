import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/kilit_core.dart';
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
  const VaultScreen({super.key, required this.core});

  final KilitCore core;

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  late Future<List<VaultItem>> _items = widget.core.items();

  void _reload() {
    setState(() {
      _items = widget.core.items();
    });
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
      builder: (_) => _CarrierComposeSheet(core: widget.core),
    );
  }

  Future<void> _openPasted() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _PasteSheet(core: widget.core),
    );
  }

  Future<void> _details(VaultItem item) async {
    final deleted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _PacketSheet(core: widget.core, item: item),
    );
    if (deleted == true) _reload();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
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
                key: const ValueKey('add-note'),
                onPressed: _addNote,
                icon: const Icon(Icons.note_add_outlined),
                label: const Text('Not ekle'),
              ),
              OutlinedButton.icon(
                key: const ValueKey('compose-carrier'),
                onPressed: _compose,
                icon: const Icon(Icons.send_outlined),
                label: const Text('Taşıyıcı mesajı'),
              ),
              OutlinedButton.icon(
                key: const ValueKey('open-pasted'),
                onPressed: _openPasted,
                icon: const Icon(Icons.content_paste_search_outlined),
                label: const Text('Yapıştırılanı aç'),
              ),
              Tooltip(
                message: 'Dosya seçici bir sonraki adımda geliyor',
                child: OutlinedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.upload_file_outlined),
                  label: const Text('Dosya şifrele'),
                ),
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
                      'Kasan boş. Bir not ekle ya da bir dosya şifrele; hepsi `.klt` paketi olarak saklanır.',
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
                message: 'İmzalı',
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
    return AlertDialog(
      title: const Text('Yeni not'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const ValueKey('note-title'),
              controller: _title,
              decoration: const InputDecoration(labelText: 'Başlık'),
              enableIMEPersonalizedLearning: false,
            ),
            const SizedBox(height: 12),
            TextField(
              key: const ValueKey('note-text'),
              controller: _text,
              decoration: const InputDecoration(labelText: 'Not'),
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
          child: const Text('Vazgeç'),
        ),
        FilledButton(
          key: const ValueKey('note-save'),
          onPressed: _save,
          child: const Text('Şifrele ve kaydet'),
        ),
      ],
    );
  }
}

/// Writes a message, seals it and shows the `KLT1:` text to paste elsewhere.
class _CarrierComposeSheet extends StatefulWidget {
  const _CarrierComposeSheet({required this.core});

  final KilitCore core;

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
    final sealed = _sealed;
    return _SheetFrame(
      title: 'Taşıyıcı mesajı',
      children: sealed == null
          ? [
              Text(
                'Mesaj şifrelenir ve WhatsApp gibi bir uygulamaya yapıştırılacak metne çevrilir.',
                style: TextStyle(color: t.textMuted),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const ValueKey('carrier-message'),
                controller: _message,
                minLines: 3,
                maxLines: 8,
                decoration: const InputDecoration(labelText: 'Mesaj'),
                enableIMEPersonalizedLearning: false,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _usePassphrase,
                onChanged: (v) => setState(() => _usePassphrase = v),
                title: const Text('Ortak parola ile'),
                subtitle: const Text(
                  'Karşı taraf aynı parolayla açar. Kapalıysa yalnızca sen açabilirsin.',
                ),
              ),
              if (_usePassphrase)
                TextField(
                  key: const ValueKey('carrier-passphrase'),
                  controller: _passphrase,
                  obscureText: true,
                  enableIMEPersonalizedLearning: false,
                  decoration: const InputDecoration(
                    labelText: 'Ortak parola',
                    helperText: 'En az 12 karakter. Parolayı bu mesajla aynı kanaldan gönderme.',
                  ),
                ),
              const SizedBox(height: 16),
              FilledButton(
                key: const ValueKey('carrier-seal'),
                onPressed: _seal,
                child: const Text('Şifrele'),
              ),
            ]
          : [
              Text(
                'Bu metni kopyalayıp gönder. Kanal yalnızca şifreli veriyi görür.',
                style: TextStyle(color: t.textMuted),
              ),
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
                '${sealed.length} karakter',
                style: TextStyle(color: t.textMuted),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                key: const ValueKey('carrier-copy'),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: sealed));
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('Kopyalandı')));
                  }
                },
                icon: const Icon(Icons.copy_rounded),
                label: const Text('Kopyala'),
              ),
            ],
    );
  }
}

/// Finds `KLT1:` packets in pasted text and opens the messages among them.
class _PasteSheet extends StatefulWidget {
  const _PasteSheet({required this.core});

  final KilitCore core;

  @override
  State<_PasteSheet> createState() => _PasteSheetState();
}

class _PasteSheetState extends State<_PasteSheet> {
  final _pasted = TextEditingController();
  final _passphrase = TextEditingController();
  List<String>? _results;

  @override
  void dispose() {
    _pasted.dispose();
    _passphrase.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) _pasted.text = data!.text!;
  }

  Future<void> _open() async {
    final found = widget.core.findPackets(_pasted.text);
    final results = <String>[];
    if (found.isEmpty) results.add('Metinde KLT1 paketi bulunamadı.');
    for (final f in found) {
      final packet = f.packet;
      if (packet == null) {
        results.add(
          f.problem == FoundProblem.truncated
              ? 'Bir paket kesilmiş: gönderen uygulama mesajı kısaltmış olabilir.'
              : 'Bir paket bozuk.',
        );
        continue;
      }
      final opened = await widget.core.openMessage(
        packet,
        passphrase: _passphrase.text.isEmpty ? null : _passphrase.text,
      );
      results.add(switch (opened.failure) {
        null => opened.text!,
        OpenFailure.wrongKey =>
          'Bu paket bu parolayla ya da anahtarla açılmıyor.',
        OpenFailure.damaged => 'Bu paket bozuk ya da değiştirilmiş.',
        OpenFailure.notAMessage =>
          'Bu paket bir dosya; Kasa\'ya kaydederek aç.',
      });
    }
    if (mounted) setState(() => _results = results);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final results = _results;
    return _SheetFrame(
      title: 'Yapıştırılanı aç',
      children: [
        TextField(
          key: const ValueKey('paste-input'),
          controller: _pasted,
          minLines: 3,
          maxLines: 6,
          enableIMEPersonalizedLearning: false,
          decoration: InputDecoration(
            labelText: 'Sohbetten kopyaladığın metin',
            suffixIcon: IconButton(
              tooltip: 'Panodan yapıştır',
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
          decoration: const InputDecoration(labelText: 'Ortak parola (varsa)'),
        ),
        const SizedBox(height: 16),
        FilledButton(
          key: const ValueKey('paste-open'),
          onPressed: _open,
          child: const Text('Bul ve aç'),
        ),
        if (results != null) ...[
          const SizedBox(height: 16),
          for (final r in results)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SelectableText(r, style: TextStyle(color: t.text)),
              ),
            ),
        ],
      ],
    );
  }
}

/// "Paket analizi": how an item is protected. Never shows key material.
class _PacketSheet extends StatelessWidget {
  const _PacketSheet({required this.core, required this.item});

  final KilitCore core;
  final VaultItem item;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
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
          title: 'Paket analizi',
          children: info == null
              ? [const Center(child: CircularProgressIndicator())]
              : [
                  row('Dosya', info.name),
                  row('Tür', info.mime),
                  row(
                    'Boyut',
                    '${formatBytes(info.contentBytes)} (paket ${formatBytes(info.packetBytes)})',
                  ),
                  row('Biçim', 'KLT1 (age v1 üzerine)'),
                  row(
                    'Alıcılar',
                    info.recipients.map(_describeRecipient).join('\n'),
                  ),
                  row('İçerik', 'ChaCha20-Poly1305, 64 KiB parçalar'),
                  row(
                    'İmza',
                    switch (info.signature) {
                      SignatureState.verified =>
                        'Ed25519 + ML-DSA-65, doğrulandı',
                      SignatureState.unsigned => 'İmzasız',
                      SignatureState.invalid => 'GEÇERSİZ',
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
                  OutlinedButton.icon(
                    key: const ValueKey('item-delete'),
                    style: OutlinedButton.styleFrom(foregroundColor: t.danger),
                    onPressed: () async {
                      await core.deleteItem(item.id);
                      if (context.mounted) Navigator.pop(context, true);
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Kasadan sil'),
                  ),
                ],
        );
      },
    );
  }
}

String _describeRecipient(String tag) => switch (tag) {
  'klt-xwing' => 'klt-xwing (ML-KEM-768 + X25519)',
  'klt-argon2id' => 'klt-argon2id (ortak parola)',
  _ => tag,
};

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
