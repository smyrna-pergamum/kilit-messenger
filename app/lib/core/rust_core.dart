import 'dart:typed_data';

import '../platform/pin_key.dart';
import '../src/rust/api.dart' as rust;
import 'kilit_core.dart';

/// [KilitCore] backed by the Rust core (`core/crates/kilit-ffi`) through
/// flutter_rust_bridge. All cryptography happens in Rust; this class only
/// converts types and fetches the PIN MAC from the hardware key.
///
/// With a platform key (Android Keystore, Windows TPM) the PIN never reaches
/// the vault's Argon2id directly: the platform MACs it first, and only the
/// MAC goes to Rust. Without one, the Rust core uses its software key. A
/// vault made before the hardware key existed moves to it at the next unlock.
class RustCore implements KilitCore {
  RustCore._(this._h, this._key, this._level);

  final rust.KilitHandle _h;
  final PinKey _key;
  final KeyLevel _level;

  /// Opens the store in [dir]. [desktop] picks the larger Argon2id cost.
  static Future<RustCore> open(
    String dir, {
    required bool desktop,
    PinKey? key,
  }) async {
    final k = key ?? PlatformPinKey();
    final h = await rust.KilitHandle.open(dir: dir, desktop: desktop);
    return RustCore._(h, k, await k.level());
  }

  bool get _platformKey => _level != KeyLevel.none;

  Future<Uint8List> _mac(String pin) => _key.mac(rust.pinMacInput(pin: pin));

  @override
  bool get isDevelopmentStub => false;

  @override
  bool get isHardwareBacked =>
      _level.isHardware && _h.keyKind() == rust.PinKeyKind.hardware;

  @override
  String get pinProtection => switch (_h.keyKind()) {
    rust.PinKeyKind.hardware => _level.label,
    rust.PinKeyKind.software => 'Yazılım anahtarı (kasanın yanında)',
    rust.PinKeyKind.none => _platformKey ? _level.label : 'Yok',
  };

  @override
  Future<bool> hasVault() => _h.hasVault();

  @override
  Future<void> createVault(String pin) async {
    if (_platformKey) {
      await _h.createVaultWithMac(mac: await _mac(pin));
    } else {
      await _h.createVault(pin: pin);
    }
  }

  @override
  Future<UnlockResult> unlock(String pin) async {
    final rust.UnlockReply r;
    if (_h.keyKind() == rust.PinKeyKind.hardware) {
      r = await _h.unlockWithMac(mac: await _mac(pin));
    } else {
      r = await _h.unlock(pin: pin);
      // the right PIN for an old software-key vault: move it to the
      // hardware key now, while the PIN is at hand
      if (r.outcome == rust.UnlockOutcome.unlocked && _platformKey) {
        await _h.moveToHardware(mac: await _mac(pin));
      }
    }
    final wait = Duration(seconds: r.waitSecs.toInt());
    return switch (r.outcome) {
      rust.UnlockOutcome.unlocked => const UnlockResult(UnlockOutcome.unlocked),
      rust.UnlockOutcome.wrongPin => UnlockResult(
        UnlockOutcome.wrongPin,
        wait: wait,
      ),
      rust.UnlockOutcome.wait => UnlockResult(
        UnlockOutcome.waitBeforeRetry,
        wait: wait,
      ),
    };
  }

  @override
  void lock() => _h.lock();

  @override
  Future<String> myFingerprint() => _h.fingerprint();

  VaultItem _item(rust.ItemInfo i) => VaultItem(
    id: i.id,
    name: i.name,
    mime: i.mime,
    size: i.size.toInt(),
    added: DateTime.fromMillisecondsSinceEpoch(i.addedUnix.toInt() * 1000),
    signed: i.signed,
  );

  @override
  Future<List<VaultItem>> items() async => [
    for (final i in await _h.items()) _item(i),
  ];

  @override
  Future<VaultItem> addNote(String title, String text) async =>
      _item(await _h.addNote(title: title, text: text));

  @override
  Future<String> readText(String id) => _h.readText(id: id);

  @override
  Future<VaultItem> addFile(String name, String mime, Uint8List bytes) async =>
      _item(await _h.addFile(name: name, mime: mime, data: bytes));

  @override
  Future<Uint8List> readFile(String id) => _h.readFile(id: id);

  @override
  Future<ExportedKlt> exportKlt(String id, {String? passphrase}) async {
    final e = await _h.exportKlt(id: id, passphrase: passphrase);
    return ExportedKlt(e.fileName, e.bytes);
  }

  @override
  Future<ImportResult> importKlt(Uint8List bytes, {String? passphrase}) async {
    final r = await _h.importKlt(bytes: bytes, passphrase: passphrase);
    return switch (r.kind) {
      rust.ImportKind.imported => ImportResult(
        ImportOutcome.imported,
        item: _item(r.item!),
        signature: _sig(r.signedBy),
      ),
      rust.ImportKind.wrongKey => const ImportResult(ImportOutcome.wrongKey),
      rust.ImportKind.notKlt => const ImportResult(ImportOutcome.notKlt),
      rust.ImportKind.damaged => const ImportResult(ImportOutcome.damaged),
    };
  }

  @override
  Future<void> deleteItem(String id) => _h.deleteItem(id: id);

  SignatureState _sig(rust.SignedBy s) => switch (s) {
    rust.SignedBy.nobody => SignatureState.unsigned,
    rust.SignedBy.me || rust.SignedBy.someone => SignatureState.verified,
  };

  @override
  Future<PacketInfo> inspect(String id) async {
    final r = await _h.inspect(id: id);
    return PacketInfo(
      name: r.item.name,
      mime: r.item.mime,
      contentBytes: r.item.size.toInt(),
      packetBytes: r.packetBytes.toInt(),
      recipients: r.recipients,
      signature: _sig(r.signedBy),
      signerFingerprint: r.signedBy == rust.SignedBy.me
          ? await _h.fingerprint()
          : null,
    );
  }

  @override
  Future<String> sealForCarrier(String message, {String? passphrase}) =>
      _h.sealForCarrier(message: message, passphrase: passphrase);

  @override
  List<FoundPacket> findPackets(String pasted) => [
    for (final f in rust.findPackets(text: pasted))
      switch (f.kind) {
        rust.FoundKind.packet => FoundPacket.ok(f.packet),
        rust.FoundKind.truncated => const FoundPacket.bad(
          FoundProblem.truncated,
        ),
        rust.FoundKind.malformed => const FoundPacket.bad(
          FoundProblem.malformed,
        ),
      },
  ];

  @override
  Future<OpenedMessage> openMessage(
    Uint8List packet, {
    String? passphrase,
  }) async {
    final r = await _h.openMessage(packet: packet, passphrase: passphrase);
    return switch (r.kind) {
      rust.MessageKind.text => OpenedMessage.ok(r.text, _sig(r.signedBy)),
      rust.MessageKind.wrongKey => const OpenedMessage.failed(
        OpenFailure.wrongKey,
      ),
      rust.MessageKind.damaged => const OpenedMessage.failed(
        OpenFailure.damaged,
      ),
      rust.MessageKind.notAMessage => const OpenedMessage.failed(
        OpenFailure.notAMessage,
      ),
    };
  }
}
