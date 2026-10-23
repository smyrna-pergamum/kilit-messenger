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
  bool get isHardwareBacked => pinProtection.isHardware;

  PinProtection get _platform => switch (_level) {
    KeyLevel.strongbox => PinProtection.strongbox,
    KeyLevel.tee => PinProtection.tee,
    KeyLevel.tpm => PinProtection.tpm,
    KeyLevel.osSoftware => PinProtection.osSoftware,
    KeyLevel.none => PinProtection.none,
  };

  @override
  PinProtection get pinProtection => switch (_h.keyKind()) {
    rust.PinKeyKind.hardware => _platform,
    rust.PinKeyKind.software => PinProtection.softwareFile,
    rust.PinKeyKind.none => _platform,
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

  bool get _hardwareVault => _h.keyKind() == rust.PinKeyKind.hardware;

  /// After a panic: the platform key goes too, so old copies of the vault
  /// file that flash storage may keep can never be opened.
  Future<void> _destroyKey() async {
    if (_platformKey) await _key.destroy();
  }

  @override
  Future<UnlockResult> unlock(String pin) async {
    final rust.UnlockReply r;
    if (_hardwareVault) {
      r = await _h.unlockWithMac(mac: await _mac(pin));
    } else {
      r = await _h.unlock(pin: pin);
      // the right PIN for an old software-key vault: move it to the
      // hardware key now, while the PIN is at hand
      if (r.outcome == rust.UnlockOutcome.unlocked && _platformKey) {
        await _h.moveToHardware(mac: await _mac(pin));
      }
    }
    if (r.outcome == rust.UnlockOutcome.wiped) await _destroyKey();
    return _result(r);
  }

  static UnlockResult _result(rust.UnlockReply r) {
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
      rust.UnlockOutcome.wiped => const UnlockResult(UnlockOutcome.wiped),
    };
  }

  @override
  Future<UnlockResult> changePin(String current, String fresh) async => _result(
    _hardwareVault
        ? await _h.changePinWithMac(
            current: await _mac(current),
            fresh: await _mac(fresh),
          )
        : await _h.changePin(current: current, fresh: fresh),
  );

  @override
  Future<bool> hasPanicCode() => _h.panicSet();

  @override
  Future<void> setPanicCode(String code) async {
    if (_hardwareVault) {
      await _h.setPanicWithMac(mac: await _mac(code));
    } else {
      await _h.setPanic(code: code);
    }
  }

  @override
  Future<void> clearPanicCode() => _h.clearPanic();

  @override
  Future<bool> panicWipe(String code) async {
    final wiped = _hardwareVault
        ? await _h.panicWipeWithMac(mac: await _mac(code))
        : await _h.panicWipe(code: code);
    if (wiped) await _destroyKey();
    return wiped;
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
  Future<CleanedFile> cleanMetadata(Uint8List bytes) async {
    final r = await rust.cleanMetadata(data: bytes);
    return switch (r.outcome) {
      rust.CleanOutcome.cleaned => CleanedFile.cleaned(r.data, {
        for (final k in r.removed)
          switch (k) {
            rust.RemovedKind.exif => HiddenData.exif,
            rust.RemovedKind.location => HiddenData.location,
            rust.RemovedKind.xmp => HiddenData.xmp,
            rust.RemovedKind.iptc => HiddenData.iptc,
            rust.RemovedKind.comment => HiddenData.comment,
            rust.RemovedKind.extraImages => HiddenData.extraImages,
            rust.RemovedKind.text => HiddenData.text,
            rust.RemovedKind.other => HiddenData.other,
          },
      }),
      rust.CleanOutcome.unsupported => const CleanedFile.failed(
        CleanOutcome.unsupported,
      ),
      rust.CleanOutcome.damaged => const CleanedFile.failed(
        CleanOutcome.damaged,
      ),
    };
  }

  @override
  Future<KeptMessage> keepMessage(
    Uint8List packet,
    String title,
    String text,
  ) async {
    final r = await _h.keepMessage(packet: packet, title: title, text: text);
    return KeptMessage(_item(r.item), already: r.already);
  }

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
