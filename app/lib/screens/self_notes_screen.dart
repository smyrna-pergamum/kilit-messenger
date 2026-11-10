import 'dart:convert';

import 'package:flutter/material.dart';

import '../core/kilit_core.dart';
import '../l10n/app_localizations.dart';
import '../theme/tokens.dart';
import 'vault_screen.dart' show formatDate;

/// The vault item type of a note to self: plain text, with a mark that
/// keeps it out of the vault's main list.
const selfNoteMime = 'text/plain; charset=utf-8; kilit=self';

bool isSelfNote(VaultItem item) => item.mime == selfNoteMime;

/// A note's title: its name without ".txt".
String selfNoteTitle(VaultItem item) => item.name.endsWith('.txt')
    ? item.name.substring(0, item.name.length - 4)
    : item.name;

/// Notes to self: sealed in the vault like everything else there, and
/// readable only after unlocking.
class SelfNotesScreen extends StatefulWidget {
  const SelfNotesScreen({super.key, required this.core});

  final KilitCore core;

  @override
  State<SelfNotesScreen> createState() => _SelfNotesScreenState();
}

class _SelfNotesScreenState extends State<SelfNotesScreen> {
  late Future<List<VaultItem>> _notes = _load();

  Future<List<VaultItem>> _load() async {
    final items = await widget.core.items();
    final notes = items.where(isSelfNote).toList()
      ..sort((a, b) => b.added.compareTo(a.added));
    return notes;
  }

  void _reload() {
    setState(() {
      _notes = _load();
    });
  }

  Future<void> _open([VaultItem? note]) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => SelfNoteEditor(core: widget.core, note: note),
      ),
    );
    if (changed == true) _reload();
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final t = context.tokens;
    return Scaffold(
      appBar: AppBar(title: Text(l.selfNotes)),
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('self-note-new'),
        onPressed: _open,
        icon: const Icon(Icons.edit_note_rounded),
        label: Text(l.selfNoteNew),
      ),
      body: FutureBuilder<List<VaultItem>>(
        future: _notes,
        builder: (context, snap) {
          final notes = snap.data;
          if (notes == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (notes.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  l.selfNotesEmpty,
                  key: const ValueKey('self-notes-empty'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: t.textMuted),
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            itemCount: notes.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) => Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                key: ValueKey('self-note-${notes[i].id}'),
                leading: Icon(Icons.sticky_note_2_outlined, color: t.accent),
                title: Text(
                  selfNoteTitle(notes[i]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  formatDate(notes[i].added),
                  style: TextStyle(color: t.textMuted),
                ),
                onTap: () => _open(notes[i]),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Writes a new note to self, or reads and changes one. A change seals the
/// new text first and then deletes the old packet.
class SelfNoteEditor extends StatefulWidget {
  const SelfNoteEditor({super.key, required this.core, this.note});

  final KilitCore core;
  final VaultItem? note;

  @override
  State<SelfNoteEditor> createState() => _SelfNoteEditorState();
}

class _SelfNoteEditorState extends State<SelfNoteEditor> {
  final _title = TextEditingController();
  final _text = TextEditingController();
  String _savedTitle = '';
  String _savedText = '';
  bool _loading = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final note = widget.note;
    if (note != null) {
      _loading = true;
      _savedTitle = selfNoteTitle(note);
      _title.text = _savedTitle;
      widget.core.readText(note.id).then((text) {
        if (!mounted) return;
        setState(() {
          _savedText = text;
          _text.text = text;
          _loading = false;
        });
      });
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _text.dispose();
    super.dispose();
  }

  bool get _changed =>
      _title.text.trim() != _savedTitle || _text.text != _savedText;

  Future<void> _save() async {
    final l = L.of(context);
    var title = _title.text.trim();
    if (_text.text.trim().isEmpty) return;
    if (title.isEmpty) {
      title = _text.text.trim().split('\n').first;
      if (title.length > 40) title = '${title.substring(0, 40)}…';
    }
    setState(() => _saving = true);
    await widget.core.addFile(
      '$title.txt',
      selfNoteMime,
      utf8.encode(_text.text),
    );
    final old = widget.note;
    if (old != null) await widget.core.deleteItem(old.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l.selfNoteSaved)));
    Navigator.pop(context, true);
  }

  Future<void> _delete() async {
    final l = L.of(context);
    final note = widget.note;
    if (note == null) return;
    final sure = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.selfNoteDelete),
        content: Text(l.selfNoteDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.cancel),
          ),
          TextButton(
            key: const ValueKey('self-note-delete-confirm'),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.selfNoteDelete),
          ),
        ],
      ),
    );
    if (sure != true) return;
    await widget.core.deleteItem(note.id);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final t = context.tokens;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? l.selfNoteNew : l.selfNotes),
        actions: [
          if (widget.note != null)
            IconButton(
              key: const ValueKey('self-note-delete'),
              tooltip: l.selfNoteDelete,
              onPressed: _saving ? null : _delete,
              icon: Icon(Icons.delete_outline_rounded, color: t.danger),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton.icon(
              key: const ValueKey('self-note-save'),
              onPressed: _loading || _saving ? null : _save,
              icon: const Icon(Icons.lock_outline_rounded),
              label: Text(l.sealAndSave),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : PopScope(
              canPop: !_changed,
              onPopInvokedWithResult: (didPop, _) async {
                if (didPop) return;
                final leave = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    content: Text(l.selfNoteUnsaved),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(l.cancel),
                      ),
                      TextButton(
                        key: const ValueKey('self-note-discard'),
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(l.selfNoteDiscard),
                      ),
                    ],
                  ),
                );
                if (leave == true && context.mounted) {
                  Navigator.pop(context, false);
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      key: const ValueKey('self-note-title'),
                      controller: _title,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(labelText: l.noteTitle),
                      enableIMEPersonalizedLearning: false,
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: TextField(
                        key: const ValueKey('self-note-text'),
                        controller: _text,
                        onChanged: (_) => setState(() {}),
                        expands: true,
                        maxLines: null,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: InputDecoration(
                          hintText: l.noteText,
                          border: const OutlineInputBorder(),
                        ),
                        enableIMEPersonalizedLearning: false,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.lock_outline, size: 14, color: t.safe),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            l.selfNotesHint,
                            style: TextStyle(color: t.textMuted, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
