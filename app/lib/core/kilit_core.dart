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

  /// Whether the PIN is bound to a hardware key (StrongBox, TEE, TPM).
  bool get isHardwareBacked;

  /// What protects the PIN, for the settings screen.
  PinProtection get pinProtection;

  Future<bool> hasVault();
  Future<void> createVault(String pin);

  /// Tries [pin]. The panic code instead erases everything, the hardware
  /// key included, and answers [UnlockOutcome.wiped]: Kilit is as if newly
  /// installed.
  Future<UnlockResult> unlock(String pin);

  /// Changes the open vault's PIN after checking the current one; a wrong
  /// one counts like a wrong PIN at the lock screen. [UnlockOutcome.unlocked]
  /// means changed.
  Future<UnlockResult> changePin(String current, String fresh);

  /// Whether a panic code is set. Needs the open vault.
  Future<bool> hasPanicCode();

  /// Sets the four-digit panic code.
  Future<void> setPanicCode(String code);
  Future<void> clearPanicCode();

  /// The panic button: when [code] is the panic code, erases everything as
  /// [unlock] does. Returns whether it did.
  Future<bool> panicWipe(String code);

  /// Wipes keys and decrypted state from memory.
  void lock();

  /// The safety number contacts compare: 12 groups of 5 digits.
  Future<String> myFingerprint();

  Future<List<VaultItem>> items();
  Future<VaultItem> addNote(String title, String text);

  /// A text item, decrypted into memory to show it.
  Future<String> readText(String id);

  /// Strips location, camera, author and editing metadata from a JPEG, PNG
  /// or WebP picture without re-encoding it; see `clean` in kilit-parse.
  /// Needs no vault.
  Future<CleanedFile> cleanMetadata(Uint8List bytes);

  /// Seals a file into the vault (at most 64 MiB).
  Future<VaultItem> addFile(String name, String mime, Uint8List bytes);

  /// An item's content in memory: to preview an image, or to save it
  /// unencrypted when the user explicitly asks.
  Future<Uint8List> readFile(String id);

  /// An item as a `.klt` file, to a shared passphrase or to this vault.
  Future<ExportedKlt> exportKlt(String id, {String? passphrase});

  /// A `.klt` file from outside, opened and sealed into the vault.
  Future<ImportResult> importKlt(Uint8List bytes, {String? passphrase});
  Future<void> deleteItem(String id);
  Future<PacketInfo> inspect(String id);

  /// Seals a message to a shared passphrase (or to yourself when null) and
  /// returns the `KLT1:...` text to paste into another app.
  Future<String> sealForCarrier(String message, {String? passphrase});

  /// Finds packets in pasted text; see `find_in_text` in kilit-klt.
  List<FoundPacket> findPackets(String pasted);
  Future<OpenedMessage> openMessage(Uint8List packet, {String? passphrase});

  /// Keeps an opened message in the vault as a note, once per packet.
  Future<KeptMessage> keepMessage(Uint8List packet, String title, String text);

  /// This vault's Kilit ID and the invite link its QR code shows.
  Future<MyKilit> myKilit();

  /// Whether [text] is a Kilit link or an `@ID` at all.
  bool isInvite(String text);

  /// Looks up, over Tor, the card the link, QR code or `@ID` in [text]
  /// names, checks it against the ID and adds the contact. Throws
  /// [ContactRefused] or [Offline].
  Future<Contact> addContact(String text, {String? name});

  /// The contacts, requests and blocked ones included, newest first.
  Future<List<Contact>> contacts();
  Future<void> renameContact(String id, String name);

  /// Lets a request in.
  Future<void> acceptContact(String id);

  /// Hears nothing more from a contact.
  Future<void> blockContact(String id);

  /// Forgets a contact: session, identity key and conversation.
  Future<void> removeContact(String id);

  /// The 60 digits two people compare: 12 groups of 5.
  Future<String> safetyNumber(String id);

  /// A conversation, oldest line first.
  Future<List<ChatLine>> chat(String id);

  /// Seals [text] for a contact and sends it; without the network it
  /// waits in the outbox and goes when Tor is back.
  Future<ChatLine> sendMessage(String id, String text);

  /// Sends a file (at most [maxChatFileBytes]) with [text] beside it, sealed
  /// with a key of its own; pictures lose their metadata first.
  Future<ChatLine> sendFile(
    String id,
    String name,
    String mime,
    Uint8List bytes, {
    String text = '',
  });

  /// A sent or received file's bytes, to show or save.
  Future<Uint8List> readAttachment(String blob);

  /// Sets the conversation's disappearing-message time; zero keeps
  /// messages. The next message tells them.
  Future<void> setTimer(String id, Duration timer);

  /// Sends message [line] to contact [id] again now, file and all. Kilit
  /// also does this by itself once a day for a week until it is delivered.
  Future<void> resendMessage(String id, String line);

  /// A new Kilit ID: new words, link and QR code. Contacts stay; the old ID
  /// and link stop working.
  Future<MyKilit> renewKilitId();

  /// A camera frame as a JPEG with no metadata, turned upright, all in
  /// memory.
  Future<Uint8List> cameraJpeg(CameraFrame frame);

  /// Connects to the relays through Tor's SOCKS port.
  Future<void> netStart(int socks);
  void netStop();

  /// One round of network work: what arrived, what is still queued.
  Future<NetTick> netTick();
}

/// The largest file sent in a chat.
const maxChatFileBytes = 5 * 1024 * 1024;

/// One YUV 4:2:0 frame from the camera, plane by plane.
class CameraFrame {
  const CameraFrame({
    required this.width,
    required this.height,
    required this.y,
    required this.u,
    required this.v,
    required this.yRow,
    required this.uvRow,
    required this.uvPixel,
    required this.rotation,
  });
  final int width;
  final int height;
  final Uint8List y;
  final Uint8List u;
  final Uint8List v;
  final int yRow;
  final int uvRow;
  final int uvPixel;

  /// Clockwise degrees that make it upright.
  final int rotation;
}

/// No card for this ID on the relays, or it was this vault's own.
class ContactRefused implements Exception {
  const ContactRefused();
}

/// Needs the network, and Tor is not up.
class Offline implements Exception {
  const Offline();
}

class MyKilit {
  const MyKilit(this.id, this.link);

  /// Four words, shown with `@`.
  final String id;

  /// `kilit://add?…`
  final String link;
}

class ChatLine {
  const ChatLine({
    this.id = '',
    required this.outgoing,
    required this.text,
    required this.at,
    required this.sent,
    this.onRelay = true,
    this.delivered = false,
    this.expires,
    this.file,
  });

  /// The message's id; names it to [KilitCore.resendMessage].
  final String id;

  /// Written on this device.
  final bool outgoing;
  final String text;

  /// When it was written or opened here.
  final DateTime at;

  /// When the sender says they wrote it.
  final DateTime sent;

  /// Outgoing only: a relay has it, or it still waits for the network.
  final bool onRelay;

  /// Outgoing only: their phone opened it.
  final bool delivered;

  /// When it disappears; null never.
  final DateTime? expires;
  final ChatFile? file;
}

class ChatFile {
  const ChatFile({
    required this.name,
    required this.mime,
    required this.size,
    required this.blob,
  });
  final String name;
  final String mime;
  final int size;

  /// Where it is kept; empty while its pieces are still coming.
  final String blob;

  bool get ready => blob.isNotEmpty;
  bool get isImage => mime.startsWith('image/');
}

enum Standing { accepted, request, blocked }

class Contact {
  const Contact({
    required this.id,
    required this.kilitId,
    required this.name,
    required this.added,
    this.standing = Standing.accepted,
    this.timer = Duration.zero,
    this.last,
  });

  /// 32 hex digits: a hash of their identity key, nothing else.
  final String id;

  /// Their four words.
  final String kilitId;

  /// Empty until the user gives one.
  final String name;
  final DateTime added;
  final Standing standing;

  /// Disappearing-message time; zero keeps messages.
  final Duration timer;
  final ChatLine? last;

  Contact named(String n) => Contact(
    id: id,
    kilitId: kilitId,
    name: n,
    added: added,
    standing: standing,
    timer: timer,
    last: last,
  );

  Contact withTimer(Duration t) => Contact(
    id: id,
    kilitId: kilitId,
    name: name,
    added: added,
    standing: standing,
    timer: t,
    last: last,
  );
}

class Arrived {
  const Arrived(this.contact, this.text, {this.request = false});
  final String contact;
  final String text;

  /// From someone not yet a contact: it waits in Requests.
  final bool request;
}

class NetTick {
  const NetTick({
    this.arrived = const [],
    this.relaysUp = 0,
    this.relays = 0,
    this.queued = 0,
  });
  final List<Arrived> arrived;
  final int relaysUp;
  final int relays;

  /// Messages still waiting for a relay.
  final int queued;
}

class KeptMessage {
  const KeptMessage(this.item, {required this.already});
  final VaultItem item;

  /// The same packet was kept before; nothing was added.
  final bool already;
}

/// What protects the vault's PIN on this device.
enum PinProtection {
  strongbox,
  tee,
  tpm,

  /// Android Keystore without secure hardware.
  osSoftware,

  /// The Rust core's software key file beside the vault.
  softwareFile,

  /// No vault yet and no platform key.
  none,

  /// The in-memory development core.
  dev,
}

extension PinProtectionHardware on PinProtection {
  bool get isHardware =>
      this == PinProtection.strongbox ||
      this == PinProtection.tee ||
      this == PinProtection.tpm;
}

enum CleanOutcome {
  /// [CleanedFile.bytes] is the picture without its metadata.
  cleaned,

  /// Not a picture format Kilit can clean; the file may carry metadata.
  unsupported,

  /// A picture whose structure is broken; nothing could be checked.
  damaged,
}

/// Kinds of metadata a picture can hide.
enum HiddenData { exif, location, xmp, iptc, comment, extraImages, text, other }

class CleanedFile {
  const CleanedFile.cleaned(Uint8List this.bytes, this.removed)
    : outcome = CleanOutcome.cleaned;
  const CleanedFile.failed(this.outcome) : bytes = null, removed = const {};
  final CleanOutcome outcome;

  /// The cleaned picture; null unless [outcome] is [CleanOutcome.cleaned].
  final Uint8List? bytes;

  /// What was taken out; empty when there was nothing to take out.
  final Set<HiddenData> removed;
}

enum UnlockOutcome {
  unlocked,
  wrongPin,
  waitBeforeRetry,

  /// The panic code: everything is gone.
  wiped,
}

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

class ExportedKlt {
  const ExportedKlt(this.fileName, this.bytes);

  /// A random `kilit-xxxxxxxx.klt` name that says nothing of the content.
  final String fileName;
  final Uint8List bytes;
}

enum ImportOutcome { imported, wrongKey, notKlt, damaged }

class ImportResult {
  const ImportResult(
    this.outcome, {
    this.item,
    this.signature = SignatureState.unsigned,
  });
  final ImportOutcome outcome;
  final VaultItem? item;

  /// Who signed the original file.
  final SignatureState signature;
}
