part of 'chats_screen.dart';

/// How a person shows in a group: "You", the name given here, or their
/// @ID. Someone who has left the group is still found among the contacts.
class _Names {
  _Names(this.l, this.group, List<Contact> contacts)
    : _contacts = {for (final c in contacts) c.id: c};

  final L l;
  final Group group;
  final Map<String, Contact> _contacts;

  String of(String id) {
    final m = group.member(id);
    if (m != null && m.me) return l.groupYou;
    final c = _contacts[id];
    if (c != null && c.name.isNotEmpty) return c.name;
    if (m != null) return m.name.isNotEmpty ? m.name : '@${m.kilitId}';
    if (c != null) return '@${c.kilitId}';
    return '@${id.substring(0, 8)}';
  }

  String noticeText(ChatLine line) {
    final who = of(line.from);
    final whom = line.about.map(of).join(', ');
    return switch (line.notice) {
      GroupNotice.created => l.groupNoticeCreated(who),
      GroupNotice.joined => l.groupNoticeJoined(who),
      GroupNotice.added => l.groupNoticeAdded(who, whom),
      GroupNotice.removed => l.groupNoticeRemoved(who, whom),
      GroupNotice.left => l.groupNoticeLeft(who),
      GroupNotice.renamed => l.groupNoticeRenamed(who, line.text),
      GroupNotice.ended => l.groupNoticeEnded(who),
      _ => l.groupNoticeRemovedYou(who),
    };
  }
}

class _GroupTile extends StatelessWidget {
  const _GroupTile({required this.group, required this.onTap});

  final Group group;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    final g = group;
    final last = g.last;
    final names = _Names(l, g, const []);
    return ListTile(
      key: ValueKey('group-${g.id}'),
      onTap: onTap,
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: t.accent.withValues(alpha: 0.15),
        child: Icon(Icons.groups_2_outlined, color: t.accent),
      ),
      title: Text(
        g.name.isEmpty ? l.newGroup : g.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: t.text, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        last == null
            ? l.groupMembers(g.members.length)
            : last.notice != 0
            ? names.noticeText(last)
            : '${last.outgoing ? '→ ' : '${names.of(last.from)}: '}${last.text}',
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

/// Picks contacts: for a new group, or to add to one.
class _ContactPicker extends StatelessWidget {
  const _ContactPicker({
    required this.contacts,
    required this.chosen,
    required this.room,
    required this.onChanged,
  });

  final List<Contact> contacts;
  final Set<String> chosen;

  /// How many more fit.
  final int room;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Column(
      children: [
        for (final c in contacts)
          CheckboxListTile(
            key: ValueKey('pick-${c.id}'),
            value: chosen.contains(c.id),
            title: Text(contactLabel(c)),
            subtitle: c.name.isEmpty ? null : Text('@${c.kilitId}'),
            onChanged: (on) {
              if (on == true) {
                if (chosen.length >= room) {
                  _say(context, l.groupFull(maxGroup));
                  return;
                }
                chosen.add(c.id);
              } else {
                chosen.remove(c.id);
              }
              onChanged();
            },
          ),
      ],
    );
  }
}

/// A name and the people: makes a group with this vault as its admin.
class NewGroupScreen extends StatefulWidget {
  const NewGroupScreen({
    super.key,
    required this.core,
    required this.chats,
    required this.files,
  });

  final KilitCore core;
  final ChatService chats;
  final FileAccess files;

  @override
  State<NewGroupScreen> createState() => _NewGroupScreenState();
}

class _NewGroupScreenState extends State<NewGroupScreen> {
  late final Future<List<Contact>> _contacts = widget.core.contacts().then(
    (all) => all.where((c) => c.standing == Standing.accepted).toList(),
  );
  final _name = TextEditingController();
  final _chosen = <String>{};
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  bool get _ready => _name.text.trim().isNotEmpty && _chosen.isNotEmpty;

  Future<void> _create() async {
    setState(() => _busy = true);
    try {
      final g = await widget.core.createGroup(
        _name.text.trim(),
        _chosen.toList(),
      );
      widget.chats.touched();
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => GroupScreen(
            core: widget.core,
            chats: widget.chats,
            files: widget.files,
            group: g,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.newGroup),
        actions: [
          TextButton(
            key: const ValueKey('group-create'),
            onPressed: _ready && !_busy ? _create : null,
            child: Text(l.groupCreate),
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<Contact>>(
          future: _contacts,
          builder: (context, snap) {
            final all = snap.data ?? const <Contact>[];
            return ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: TextField(
                    key: const ValueKey('group-name'),
                    controller: _name,
                    maxLength: 64,
                    enableIMEPersonalizedLearning: false,
                    decoration: InputDecoration(labelText: l.groupName),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                  child: Text(
                    snap.hasData && all.isEmpty
                        ? l.groupNoContacts
                        : l.groupPick(maxGroup - 1),
                    style: TextStyle(color: t.textMuted),
                  ),
                ),
                _ContactPicker(
                  contacts: all,
                  chosen: _chosen,
                  room: maxGroup - 1,
                  onChanged: () => setState(() {}),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// A group's conversation.
class GroupScreen extends StatefulWidget {
  const GroupScreen({
    super.key,
    required this.core,
    required this.chats,
    required this.files,
    required this.group,
  });

  final KilitCore core;
  final ChatService chats;
  final FileAccess files;
  final Group group;

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  late Group _group = widget.group;
  late Future<List<ChatLine>> _lines = widget.core.groupChat(_group.id);
  List<Contact> _contacts = const [];
  final _input = TextEditingController();
  int _seen = -1;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    widget.chats.addListener(_changed);
    _refresh();
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

  Future<void> _refresh() async {
    final g = await widget.core.group(_group.id);
    final c = await widget.core.contacts();
    if (mounted) {
      setState(() {
        _group = g;
        _contacts = c;
      });
    }
  }

  void _reload() {
    setState(() {
      _seen = widget.chats.revision;
      _lines = widget.core.groupChat(_group.id);
    });
    _refresh();
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    _input.clear();
    await widget.core.sendGroupMessage(_group.id, text);
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
      await widget.core.sendGroupFile(_group.id, name, mime, bytes, text: text);
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
              child: Text(
                '${l.groupDeliveredTo(line.deliveredTo, line.recipients)}. '
                '${line.onRelay ? l.resendHint : l.chatQueued}',
              ),
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
    await widget.core.resendGroupMessage(_group.id, line.id);
    widget.chats.touched();
    _reload();
    if (mounted) _say(context, l.resendDone);
  }

  Future<void> _info() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GroupInfoScreen(
          core: widget.core,
          chats: widget.chats,
          group: _group,
        ),
      ),
    );
    if (!mounted) return;
    // the group may be gone now
    final still = (await widget.core.groups()).any((g) => g.id == _group.id);
    if (!still && mounted) {
      Navigator.of(context).pop();
      return;
    }
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    final names = _Names(l, _group, _contacts);
    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: _info,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_group.name, key: const ValueKey('group-title')),
              Text(
                l.groupMembers(_group.members.length),
                style: TextStyle(fontSize: 12, color: t.textMuted),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            key: const ValueKey('group-info'),
            tooltip: l.groupInfo,
            icon: const Icon(Icons.info_outline),
            onPressed: _info,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_group.closed)
              MaterialBanner(
                key: const ValueKey('group-closed'),
                backgroundColor: t.surfaceRaised,
                leading: Icon(Icons.lock_clock_outlined, color: t.textMuted),
                content: Text(_group.gone ? l.groupGone : l.groupEnded),
                actions: [
                  TextButton(onPressed: _info, child: Text(l.groupInfo)),
                ],
              ),
            Expanded(
              child: FutureBuilder<List<ChatLine>>(
                future: _lines,
                builder: (context, snap) {
                  final lines = snap.data ?? const <ChatLine>[];
                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(12),
                    itemCount: lines.length,
                    itemBuilder: (context, i) {
                      final line = lines[lines.length - 1 - i];
                      if (line.notice != 0) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Center(
                            child: Text(
                              names.noticeText(line),
                              key: const ValueKey('group-notice'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: t.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      }
                      return _Bubble(
                        line: line,
                        core: widget.core,
                        files: widget.files,
                        sender: line.outgoing ? null : names.of(line.from),
                        onResend:
                            line.outgoing && !line.delivered && !_group.closed
                            ? () => _resend(line)
                            : null,
                      );
                    },
                  );
                },
              ),
            ),
            if (_sending) const LinearProgressIndicator(minHeight: 2),
            if (!_group.closed)
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

/// Who is in a group; the admin changes it here, anyone leaves.
class GroupInfoScreen extends StatefulWidget {
  const GroupInfoScreen({
    super.key,
    required this.core,
    required this.chats,
    required this.group,
  });

  final KilitCore core;
  final ChatService chats;
  final Group group;

  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  late Group _group = widget.group;
  List<Contact> _contacts = const [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final g = await widget.core.group(_group.id);
    final c = await widget.core.contacts();
    if (mounted) {
      setState(() {
        _group = g;
        _contacts = c;
      });
    }
  }

  Future<void> _did(Future<void> Function() change) async {
    await change();
    widget.chats.touched();
    await _refresh();
  }

  Future<bool> _confirm(String body, String yes) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(L.of(context).cancel),
            ),
            TextButton(
              key: const ValueKey('confirm-yes'),
              onPressed: () => Navigator.pop(context, true),
              child: Text(yes),
            ),
          ],
        ),
      ) ==
      true;

  Future<void> _rename() async {
    final value = await showDialog<String>(
      context: context,
      builder: (_) => _RenameDialog(initial: _group.name),
    );
    if (value == null || value.trim().isEmpty) return;
    await _did(() => widget.core.renameGroup(_group.id, value));
  }

  Future<void> _add() async {
    final l = L.of(context);
    final room = maxGroup - _group.members.length;
    if (room <= 0) {
      _say(context, l.groupFull(maxGroup));
      return;
    }
    final outside = _contacts
        .where(
          (c) => c.standing == Standing.accepted && _group.member(c.id) == null,
        )
        .toList();
    final chosen = <String>{};
    final go = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, set) => SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                  child: Text(
                    outside.isEmpty ? l.groupNoContacts : l.groupPick(room),
                  ),
                ),
                _ContactPicker(
                  contacts: outside,
                  chosen: chosen,
                  room: room,
                  onChanged: () => set(() {}),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: FilledButton(
                    key: const ValueKey('group-add-go'),
                    onPressed: chosen.isEmpty
                        ? null
                        : () => Navigator.pop(context, true),
                    child: Text(l.groupAddPeople),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (go == true) {
      await _did(() => widget.core.addGroupMembers(_group.id, chosen.toList()));
    }
  }

  Future<void> _remove(GroupMember m, String name) async {
    final l = L.of(context);
    if (await _confirm('${l.groupRemove}: $name?', l.groupRemove)) {
      await _did(() => widget.core.removeGroupMember(_group.id, m.id));
    }
  }

  Future<void> _endOrLeave() async {
    final l = L.of(context);
    final admin = _group.admin;
    final ok = await _confirm(
      admin ? l.groupEndConfirm : l.groupLeaveConfirm,
      admin ? l.groupEnd : l.groupLeave,
    );
    if (!ok) return;
    await _did(
      () => admin
          ? widget.core.endGroup(_group.id)
          : widget.core.leaveGroup(_group.id),
    );
  }

  Future<void> _delete() async {
    await widget.core.deleteGroup(_group.id);
    widget.chats.touched();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    final g = _group;
    final names = _Names(l, g, _contacts);
    final canEdit = g.admin && !g.closed;
    return Scaffold(
      appBar: AppBar(title: Text(l.groupInfo)),
      body: SafeArea(
        child: ListView(
          children: [
            ListTile(
              key: const ValueKey('group-info-name'),
              leading: Icon(Icons.groups_2_outlined, color: t.accent),
              title: Text(g.name),
              subtitle: Text(l.groupMembers(g.members.length)),
              trailing: canEdit
                  ? IconButton(
                      key: const ValueKey('group-rename'),
                      tooltip: l.groupRename,
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: _rename,
                    )
                  : null,
            ),
            const Divider(),
            for (final m in g.members)
              ListTile(
                key: ValueKey('member-${m.id}'),
                leading: const Icon(Icons.person_outline),
                title: Text(names.of(m.id)),
                subtitle: Text(
                  [
                    '@${m.kilitId}',
                    if (m.id == g.adminId) l.groupAdmin,
                  ].join(' · '),
                  style: TextStyle(fontFamily: monoFamily, fontSize: 12),
                ),
                trailing: canEdit && !m.me
                    ? IconButton(
                        key: ValueKey('member-remove-${m.id}'),
                        tooltip: l.groupRemove,
                        icon: const Icon(Icons.person_remove_outlined),
                        onPressed: () => _remove(m, names.of(m.id)),
                      )
                    : null,
              ),
            if (canEdit)
              ListTile(
                key: const ValueKey('group-add'),
                leading: Icon(Icons.person_add_alt_1_outlined, color: t.accent),
                title: Text(l.groupAddPeople),
                onTap: _add,
              ),
            const Divider(),
            if (!g.closed)
              ListTile(
                key: const ValueKey('group-end-or-leave'),
                leading: Icon(
                  g.admin ? Icons.cancel_outlined : Icons.logout,
                  color: t.danger,
                ),
                title: Text(
                  g.admin ? l.groupEnd : l.groupLeave,
                  style: TextStyle(color: t.danger),
                ),
                onTap: _endOrLeave,
              )
            else
              ListTile(
                key: const ValueKey('group-delete'),
                leading: Icon(Icons.delete_outline, color: t.danger),
                title: Text(l.groupDelete, style: TextStyle(color: t.danger)),
                onTap: _delete,
              ),
          ],
        ),
      ),
    );
  }
}
