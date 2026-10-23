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
}

/// Stands in for StrongBox or the TPM: deterministic, depends on every byte
/// and on a device secret. Not a real MAC; tests only.
class FakeHardwareKey implements PinKey {
  FakeHardwareKey(this.device);
  final int device;
  int calls = 0;
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
    expect(first.pinProtection, 'StrongBox güvenlik çipi');
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
}
