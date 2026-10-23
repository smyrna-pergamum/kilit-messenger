import 'dart:typed_data';

/// What the UI may ask of the Rust core. The UI never holds keys, PINs past
/// the call, or decrypted files longer than it shows them; everything else
/// stays behind this interface.
///
/// [RustCore] talks to `core/crates/kilit-ffi` through flutter_rust_bridge.
/// [DevCore] is an in-memory stand-in for widget tests.
abstract interface class KilitCore {
  /// True only for the in-memory stand-in. The UI shows a warning banner.
  bool get isDevelopmentStub;

  /// Whether the PIN is bound to a hardware key (StrongBox, TPM).
  bool get isHardwareBacked;

  Future<bool> hasVault();
  Future<void> createVault(String pin);
  Future<UnlockResult> unlock(String pin);

  /// Wipes keys and decrypted state from memory.
  void lock();

  /// The safety number contacts compare: 12 groups of 5 digits.
  Future<String> myFingerprint();

  Future<List<VaultItem>> items();
  Future<VaultItem> addNote(String title, String text);

  /// A text item, decrypted into memory to show it.
  Future<String> readText(String id);
  Future<void> deleteItem(String id);
  Future<PacketInfo> inspect(String id);

  /// Seals a message to a shared passphrase (or to yourself when null) and
  /// returns the `KLT1:...` text to paste into another app.
  Future<String> sealForCarrier(String message, {String? passphrase});

  /// Finds packets in pasted text; see `find_in_text` in kilit-klt.
  List<FoundPacket> findPackets(String pasted);
  Future<OpenedMessage> openMessage(Uint8List packet, {String? passphrase});
}

enum UnlockOutcome { unlocked, wrongPin, waitBeforeRetry }

class UnlockResult {
  const UnlockResult(this.outcome, {this.wait = Duration.zero});
  final UnlockOutcome outcome;

  /// How long until the next attempt is allowed.
  final Duration wait;
}

class VaultItem {
  const VaultItem({
    required this.id,
    required this.name,
    required this.mime,
    required this.size,
    required this.added,
    required this.signed,
  });
  final String id;
  final String name;
  final String mime;
  final int size;
  final DateTime added;
  final bool signed;
}

enum SignatureState { unsigned, verified, invalid }

/// The "paket analizi" screen's facts. Never contains key material.
class PacketInfo {
  const PacketInfo({
    required this.name,
    required this.mime,
    required this.contentBytes,
    required this.packetBytes,
    required this.recipients,
    required this.signature,
    this.signerFingerprint,
  });
  final String name;
  final String mime;
  final int contentBytes;
  final int packetBytes;

  /// Stanza types, such as `klt-xwing`.
  final List<String> recipients;
  final SignatureState signature;
  final String? signerFingerprint;
}

enum FoundProblem { truncated, malformed }

class FoundPacket {
  const FoundPacket.ok(Uint8List this.packet) : problem = null;
  const FoundPacket.bad(FoundProblem this.problem) : packet = null;
  final Uint8List? packet;
  final FoundProblem? problem;
}

enum OpenFailure { wrongKey, damaged, notAMessage }

class OpenedMessage {
  const OpenedMessage.ok(String this.text, this.signature) : failure = null;
  const OpenedMessage.failed(OpenFailure this.failure)
    : text = null,
      signature = SignatureState.unsigned;
  final String? text;
  final SignatureState signature;
  final OpenFailure? failure;
}
