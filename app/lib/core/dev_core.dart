import 'dart:convert';
import 'dart:typed_data';

import 'kilit_core.dart';

/// An in-memory stand-in for the Rust core, for widget tests.
/// **It encrypts nothing.** Packets it makes are plain base64
/// behind a `KLT1:DEV` marker that the real core will refuse to open.
class DevCore implements KilitCore {
  DevCore({DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;
  String? _pin;
  bool _open = false;
  int _failures = 0;
  DateTime? _retryAt;
  final List<_Item> _items = [];
  int _nextId = 1;

  static const _marker = 'DEV';

  @override
  bool get isDevelopmentStub => true;

  @override
  bool get isHardwareBacked => false;

  @override
  String get pinProtection => 'Yok (geliştirme çekirdeği)';

  @override
  Future<bool> hasVault() async => _pin != null;

  @override
  Future<void> createVault(String pin) async {
    _pin = pin;
    _open = true;
  }

  @override
  Future<UnlockResult> unlock(String pin) async {
    final now = _clock();
    final retryAt = _retryAt;
    if (retryAt != null && now.isBefore(retryAt)) {
      return UnlockResult(
        UnlockOutcome.waitBeforeRetry,
        wait: retryAt.difference(now),
      );
    }
    if (pin == _pin) {
      _failures = 0;
      _retryAt = null;
      _open = true;
      return const UnlockResult(UnlockOutcome.unlocked);
    }
    _failures++;
    // after 5 misses: 30 s, then doubling, as the hardware layer will enforce
    if (_failures >= 5) {
      final wait = Duration(seconds: 30 * (1 << (_failures - 5).clamp(0, 10)));
      _retryAt = now.add(wait);
      return UnlockResult(UnlockOutcome.wrongPin, wait: wait);
    }
    return const UnlockResult(UnlockOutcome.wrongPin);
  }

  @override
  void lock() => _open = false;

  void _requireOpen() {
    if (!_open) throw StateError('vault is locked');
  }

  @override
  Future<String> myFingerprint() async {
    _requireOpen();
    return List.filled(12, '00000').join(' ');
  }

  @override
  Future<List<VaultItem>> items() async {
    _requireOpen();
    return [for (final i in _items.reversed) i.item];
  }

  @override
  Future<VaultItem> addNote(String title, String text) async {
    _requireOpen();
    final bytes = utf8.encode(text);
    final item = VaultItem(
      id: '${_nextId++}',
      name: '$title.txt',
      mime: 'text/plain',
      size: bytes.length,
      added: _clock(),
      signed: true,
    );
    _items.add(_Item(item, bytes));
    return item;
  }

  @override
  Future<String> readText(String id) async {
    _requireOpen();
    return utf8.decode(_items.firstWhere((i) => i.item.id == id).bytes);
  }

  @override
  Future<VaultItem> addFile(String name, String mime, Uint8List bytes) async {
    _requireOpen();
    final item = VaultItem(
      id: '${_nextId++}',
      name: name,
      mime: mime,
      size: bytes.length,
      added: _clock(),
      signed: true,
    );
    _items.add(_Item(item, bytes));
    return item;
  }

  @override
  Future<Uint8List> readFile(String id) async {
    _requireOpen();
    return Uint8List.fromList(_items.firstWhere((i) => i.item.id == id).bytes);
  }

  @override
  Future<ExportedKlt> exportKlt(String id, {String? passphrase}) async {
    final i = _items.firstWhere((i) => i.item.id == id);
    final body = utf8.encode('${i.item.name}\n${i.item.mime}\n') + i.bytes;
    return ExportedKlt(
      'kilit-00000000.klt',
      Uint8List.fromList(utf8.encode('KLT1$_marker') + body),
    );
  }

  @override
  Future<ImportResult> importKlt(Uint8List bytes, {String? passphrase}) async {
    _requireOpen();
    final head = utf8.encode('KLT1$_marker');
    if (bytes.length < head.length ||
        utf8.decode(bytes.sublist(0, 4), allowMalformed: true) != 'KLT1') {
      return const ImportResult(ImportOutcome.notKlt);
    }
    final rest = bytes.sublist(head.length);
    final nl1 = rest.indexOf(10);
    final nl2 = rest.indexOf(10, nl1 + 1);
    if (nl1 < 0 || nl2 < 0) return const ImportResult(ImportOutcome.damaged);
    final item = await addFile(
      utf8.decode(rest.sublist(0, nl1)),
      utf8.decode(rest.sublist(nl1 + 1, nl2)),
      Uint8List.fromList(rest.sublist(nl2 + 1)),
    );
    return ImportResult(
      ImportOutcome.imported,
      item: item,
      signature: SignatureState.verified,
    );
  }

  @override
  Future<void> deleteItem(String id) async {
    _requireOpen();
    _items.removeWhere((i) => i.item.id == id);
  }

  @override
  Future<PacketInfo> inspect(String id) async {
    _requireOpen();
    final i = _items.firstWhere((i) => i.item.id == id);
    return PacketInfo(
      name: i.item.name,
      mime: i.item.mime,
      contentBytes: i.item.size,
      packetBytes: i.bytes.length + 7300,
      recipients: const ['klt-xwing'],
      signature: SignatureState.verified,
      signerFingerprint: await myFingerprint(),
    );
  }

  @override
  Future<String> sealForCarrier(String message, {String? passphrase}) async {
    _requireOpen();
    return 'KLT1:$_marker${base64Url.encode(utf8.encode(message)).replaceAll('=', '')}.';
  }

  @override
  List<FoundPacket> findPackets(String pasted) {
    final found = <FoundPacket>[];
    for (final m in RegExp(
      r'KLT1:([A-Za-z0-9_\-\s]*)(\.?)',
    ).allMatches(pasted).take(16)) {
      if (m.group(2) != '.') {
        found.add(const FoundPacket.bad(FoundProblem.truncated));
      } else {
        found.add(
          FoundPacket.ok(
            Uint8List.fromList(
              utf8.encode(m.group(1)!.replaceAll(RegExp(r'\s'), '')),
            ),
          ),
        );
      }
    }
    return found;
  }

  @override
  Future<OpenedMessage> openMessage(
    Uint8List packet, {
    String? passphrase,
  }) async {
    final body = utf8.decode(packet);
    if (!body.startsWith(_marker)) {
      return const OpenedMessage.failed(OpenFailure.damaged);
    }
    try {
      final b64 = body.substring(_marker.length);
      final text = utf8.decode(base64Url.decode(base64Url.normalize(b64)));
      return OpenedMessage.ok(text, SignatureState.unsigned);
    } on FormatException {
      return const OpenedMessage.failed(OpenFailure.damaged);
    }
  }
}

class _Item {
  _Item(this.item, this.bytes);
  final VaultItem item;
  final List<int> bytes;
}
