import 'dart:typed_data';

import '../src/rust/api.dart' as rust;
import 'kilit_core.dart';

/// [KilitCore] backed by the Rust core (`core/crates/kilit-ffi`) through
/// flutter_rust_bridge. All cryptography happens in Rust; this class only
/// converts types.
class RustCore implements KilitCore {
  RustCore._(this._h);

  final rust.KilitHandle _h;

  /// Opens the store in [dir]. [desktop] picks the larger Argon2id cost.
  static Future<RustCore> open(String dir, {required bool desktop}) async =>
      RustCore._(await rust.KilitHandle.open(dir: dir, desktop: desktop));

  @override
  bool get isDevelopmentStub => false;

  // StrongBox and TPM keys come next; until then the Rust core uses a
  // per-install software key and the settings screen says so.
  @override
  bool get isHardwareBacked => false;

  @override
  Future<bool> hasVault() => _h.hasVault();

  @override
  Future<void> createVault(String pin) => _h.createVault(pin: pin);

  @override
  Future<UnlockResult> unlock(String pin) async {
    final r = await _h.unlock(pin: pin);
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
