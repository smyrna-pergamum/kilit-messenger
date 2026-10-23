// Exercises RustCore against the real Rust core through the bridge.
// Needs the host build of kilit-ffi; skipped when it is not given:
//
//   cargo build -p kilit-ffi   (in core/)
//   KILIT_FFI_LIB=core/target/debug/libkilit_ffi.so flutter test test/rust_core_test.dart

import 'dart:io';

import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kilit/core/kilit_core.dart';
import 'package:kilit/core/rust_core.dart';
import 'package:kilit/platform/pin_key.dart';
import 'package:kilit/src/rust/frb_generated.dart';

/// No platform key: the Rust core uses its software key.
class NoKey implements PinKey {
  @override
  Future<KeyLevel> level() async => KeyLevel.none;
  @override
  Future<Uint8List> mac(Uint8List data) => throw UnsupportedError('no key');
  @override
  Future<void> destroy() async {}
}

/// Stands in for StrongBox or the TPM: deterministic, depends on every byte
/// and on a device secret. Not a real MAC; tests only.
class FakeHardwareKey implements PinKey {
  FakeHardwareKey(this.device);
  int device;
  int calls = 0;
  int destroyed = 0;
  @override
  Future<void> destroy() async {
    destroyed++;
    device = device * 31 + 7; // a new key
  }

  @override
  Future<KeyLevel> level() async => KeyLevel.strongbox;
  @override
  Future<Uint8List> mac(Uint8List data) async {
    calls++;
    final out = Uint8List(32);
    var h = 0x811c9dc5 ^ device;
    for (var round = 0; round < 32; round++) {
      for (final b in data) {
        h = ((h ^ b) * 0x01000193) & 0xffffffff;
      }
      h = ((h ^ round) * 0x01000193) & 0xffffffff;
      out[round] = h & 0xff;
    }
    return out;
  }
}

void main() {
  final lib = Platform.environment['KILIT_FFI_LIB'];
  final skip = lib == null ? 'KILIT_FFI_LIB not set' : null;

  setUpAll(() async {
    if (lib != null) {
      await RustLib.init(externalLibrary: ExternalLibrary.open(lib));
    }
  });

  test('a vault made in Rust survives a restart', () async {
    final dir = await Directory.systemTemp.createTemp('kilit-');
    addTearDown(() => dir.delete(recursive: true));

    final first = await RustCore.open(dir.path, desktop: false, key: NoKey());
    expect(await first.hasVault(), isFalse);
    await first.createVault('482916');
    final note = await first.addNote('ilk', 'merhaba dünya');
    final fp = await first.myFingerprint();
    expect(fp.split(' '), hasLength(12));
    first.lock();
    expect(() => first.items(), throwsA(anything));

    final again = await RustCore.open(dir.path, desktop: false, key: NoKey());
    final wrong = await again.unlock('000000');
    expect(wrong.outcome, UnlockOutcome.wrongPin);
    final right = await again.unlock('482916');
    expect(right.outcome, UnlockOutcome.unlocked);
    expect(await again.myFingerprint(), fp);
    final items = await again.items();
    expect(items.single.name, 'ilk.txt');
    expect(await again.readText(note.id), 'merhaba dünya');
    final info = await again.inspect(note.id);
    expect(info.signature, SignatureState.verified);
    expect(info.recipients, ['klt-xwing']);
    expect(info.packetBytes, greaterThan(1000));
  }, skip: skip);

  test('a carrier message round-trips through real KLT1 text', () async {
    final a = await Directory.systemTemp.createTemp('kilit-a-');
    final b = await Directory.systemTemp.createTemp('kilit-b-');
    addTearDown(() => a.delete(recursive: true));
    addTearDown(() => b.delete(recursive: true));
    final ayse = await RustCore.open(a.path, desktop: false, key: NoKey());
    final bob = await RustCore.open(b.path, desktop: false, key: NoKey());
    await ayse.createVault('482916');
    await bob.createVault('739204');

    final text = await ayse.sealForCarrier(
      'yarın 10da',
      passphrase: 'uzun bir ortak parola',
    );
    expect(text, startsWith('KLT1:'));
    final found = bob.findPackets('Ayşe: $text görüşürüz');
    expect(found, hasLength(1));
    final opened = await bob.openMessage(
      found.single.packet!,
      passphrase: 'uzun bir ortak parola',
    );
    expect(opened.text, 'yarın 10da');

    final cut = bob.findPackets(text.substring(0, text.length - 10));
    expect(cut.single.problem, FoundProblem.truncated);
  }, skip: skip);

  test('with a hardware key the vault needs that key', () async {
    final dir = await Directory.systemTemp.createTemp('kilit-hw-');
    addTearDown(() => dir.delete(recursive: true));
    final key = FakeHardwareKey(1);

    final first = await RustCore.open(dir.path, desktop: false, key: key);
    await first.createVault('482916');
    expect(first.isHardwareBacked, isTrue);
    expect(first.pinProtection, PinProtection.strongbox);
    await first.addNote('not', 'donanımla');

    final again = await RustCore.open(dir.path, desktop: false, key: key);
    expect((await again.unlock('000000')).outcome, UnlockOutcome.wrongPin);
    expect((await again.unlock('482916')).outcome, UnlockOutcome.unlocked);
    expect(await again.items(), hasLength(1));

    // the same files on another device: its key gives other MACs
    final elsewhere = await RustCore.open(
      dir.path,
      desktop: false,
      key: FakeHardwareKey(2),
    );
    expect((await elsewhere.unlock('482916')).outcome, UnlockOutcome.wrongPin);
  }, skip: skip);

  test('an old software-key vault moves to the hardware key', () async {
    final dir = await Directory.systemTemp.createTemp('kilit-move-');
    addTearDown(() => dir.delete(recursive: true));

    final old = await RustCore.open(dir.path, desktop: false, key: NoKey());
    await old.createVault('482916');
    await old.addNote('eski', 'taşınacak');
    expect(old.isHardwareBacked, isFalse);
    expect(File('${dir.path}/device-key').existsSync(), isTrue);

    final key = FakeHardwareKey(1);
    final moved = await RustCore.open(dir.path, desktop: false, key: key);
    expect((await moved.unlock('482916')).outcome, UnlockOutcome.unlocked);
    expect(moved.isHardwareBacked, isTrue);
    expect(File('${dir.path}/device-key').existsSync(), isFalse);

    final later = await RustCore.open(dir.path, desktop: false, key: key);
    expect((await later.unlock('482916')).outcome, UnlockOutcome.unlocked);
    final note = (await later.items()).single;
    expect(await later.readText(note.id), 'taşınacak');
  }, skip: skip);

  test('a file exported as .klt imports on another device', () async {
    final a = await Directory.systemTemp.createTemp('kilit-fa-');
    final b = await Directory.systemTemp.createTemp('kilit-fb-');
    addTearDown(() => a.delete(recursive: true));
    addTearDown(() => b.delete(recursive: true));
    final ayse = await RustCore.open(a.path, desktop: false, key: NoKey());
    final bob = await RustCore.open(b.path, desktop: false, key: NoKey());
    await ayse.createVault('482916');
    await bob.createVault('739204');

    final photo = Uint8List.fromList(List.generate(100000, (i) => i % 251));
    final item = await ayse.addFile('tatil.jpg', 'image/jpeg', photo);
    final klt = await ayse.exportKlt(
      item.id,
      passphrase: 'uzun bir ortak parola',
    );
    expect(klt.fileName, matches(RegExp(r'^kilit-[0-9a-f]{8}\.klt$')));

    final wrong = await bob.importKlt(
      klt.bytes,
      passphrase: 'yanlış ama uzun parola',
    );
    expect(wrong.outcome, ImportOutcome.wrongKey);
    final ok = await bob.importKlt(
      klt.bytes,
      passphrase: 'uzun bir ortak parola',
    );
    expect(ok.outcome, ImportOutcome.imported);
    expect(ok.item!.name, 'tatil.jpg');
    expect(ok.signature, SignatureState.verified);
    expect(await bob.readFile(ok.item!.id), photo);

    final junk = await bob.importKlt(Uint8List.fromList([1, 2, 3, 4, 5]));
    expect(junk.outcome, ImportOutcome.notKlt);
  }, skip: skip);

  test('the panic code erases a hardware vault and its key', () async {
    final dir = await Directory.systemTemp.createTemp('kilit-p-');
    addTearDown(() => dir.delete(recursive: true));
    final key = FakeHardwareKey(42);
    final core = await RustCore.open(dir.path, desktop: false, key: key);
    await core.createVault('482916');
    await core.addNote('gizli', 'çok gizli');
    expect(await core.hasPanicCode(), isFalse);
    await core.setPanicCode('7391');
    expect(await core.hasPanicCode(), isTrue);
    core.lock();

    final r = await core.unlock('7391');
    expect(r.outcome, UnlockOutcome.wiped);
    expect(key.destroyed, 1);
    expect(await core.hasVault(), isFalse);
    expect(dir.listSync(), isEmpty);

    // a fresh start, then the panic button
    await core.createVault('246810');
    expect(await core.items(), isEmpty);
    await core.addNote('yeni', 'x');
    await core.setPanicCode('2580');
    expect(await core.panicWipe('1111'), isFalse);
    expect(await core.items(), hasLength(1));
    expect(await core.panicWipe('2580'), isTrue);
    expect(key.destroyed, 2);
    expect(await core.hasVault(), isFalse);
  }, skip: skip);

  test('a software vault is erased inside Rust', () async {
    final dir = await Directory.systemTemp.createTemp('kilit-ps-');
    addTearDown(() => dir.delete(recursive: true));
    final core = await RustCore.open(dir.path, desktop: false, key: NoKey());
    await core.createVault('482916');
    await core.addNote('gizli', 'x');
    await core.setPanicCode('7391');
    core.lock();
    expect((await core.unlock('7391')).outcome, UnlockOutcome.wiped);
    expect(await core.hasVault(), isFalse);
  }, skip: skip);

  test('a hardware vault PIN changes through the key', () async {
    final dir = await Directory.systemTemp.createTemp('kilit-c-');
    addTearDown(() => dir.delete(recursive: true));
    final core = await RustCore.open(
      dir.path,
      desktop: false,
      key: FakeHardwareKey(7),
    );
    await core.createVault('482916');
    expect(
      (await core.changePin('000000', '135790')).outcome,
      UnlockOutcome.wrongPin,
    );
    expect(
      (await core.changePin('482916', '135790')).outcome,
      UnlockOutcome.unlocked,
    );
    core.lock();
    expect((await core.unlock('482916')).outcome, UnlockOutcome.wrongPin);
    expect((await core.unlock('135790')).outcome, UnlockOutcome.unlocked);
  }, skip: skip);

  test('an opened message is kept once', () async {
    final dir = await Directory.systemTemp.createTemp('kilit-k-');
    addTearDown(() => dir.delete(recursive: true));
    final core = await RustCore.open(dir.path, desktop: false, key: NoKey());
    await core.createVault('482916');
    final packet = Uint8List.fromList([1, 2, 3]);
    final a = await core.keepMessage(packet, 'selam', 'selam dostum');
    expect(a.already, isFalse);
    expect(a.item.name, 'selam.txt');
    final b = await core.keepMessage(packet, 'selam', 'selam dostum');
    expect(b.already, isTrue);
    expect(b.item.id, a.item.id);
    expect(await core.items(), hasLength(1));
  }, skip: skip);

  test(
    'the Rust cleaner strips a JPEG comment and leaves a PDF alone',
    () async {
      final dir = await Directory.systemTemp.createTemp('kilit-c-');
      addTearDown(() => dir.delete(recursive: true));
      final core = await RustCore.open(dir.path, desktop: false, key: NoKey());
      // start of image, a comment "hi", end of image
      final jpeg = Uint8List.fromList([
        0xFF, 0xD8, 0xFF, 0xFE, 0, 4, 0x68, 0x69, 0xFF, 0xD9, //
      ]);
      final c = await core.cleanMetadata(jpeg);
      expect(c.outcome, CleanOutcome.cleaned);
      expect(c.removed, {HiddenData.comment});
      expect(c.bytes, [0xFF, 0xD8, 0xFF, 0xD9]);

      final pdf = await core.cleanMetadata(
        Uint8List.fromList('%PDF-1.7'.codeUnits),
      );
      expect(pdf.outcome, CleanOutcome.unsupported);
      expect(pdf.bytes, isNull);
    },
    skip: skip,
  );

  test('two Rust vaults talk through cards and messages', () async {
    final a = await Directory.systemTemp.createTemp('kilit-ma-');
    final b = await Directory.systemTemp.createTemp('kilit-mb-');
    addTearDown(() => a.delete(recursive: true));
    addTearDown(() => b.delete(recursive: true));
    final ayse = await RustCore.open(a.path, desktop: false, key: NoKey());
    final bora = await RustCore.open(b.path, desktop: false, key: NoKey());
    await ayse.createVault('482916');
    await bora.createVault('739204');

    final card = await bora.myCard('Bora');
    expect(card, startsWith('KLC1:'));
    expect(() => ayse.addContact('not a card'), throwsA(isA<ContactRefused>()));
    final c = await ayse.addContact(card);
    expect(c.name, 'Bora');

    final m = await ayse.sendMessage(c.id, 'selam');
    final got = await bora.receive('Ayşe: $m');
    expect(got.single.kind, IncomingKind.opened);
    expect(got.single.text, 'selam');
    expect(got.single.newContact, isTrue);
    expect((await bora.receive(m)).single.kind, IncomingKind.duplicate);

    final reply = await bora.sendMessage(got.single.contact, 'aleyküm selam');
    expect((await ayse.receive(reply)).single.kind, IncomingKind.opened);
    final lines = await ayse.chat(c.id);
    expect(
      [for (final l in lines) (l.outgoing, l.text)],
      [(true, 'selam'), (false, 'aleyküm selam')],
    );
    expect(
      await ayse.safetyNumber(c.id),
      await bora.safetyNumber(got.single.contact),
    );
  }, skip: skip);
}
