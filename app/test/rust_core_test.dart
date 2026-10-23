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
import 'package:kilit/src/rust/frb_generated.dart';

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

    final first = await RustCore.open(dir.path, desktop: false);
    expect(await first.hasVault(), isFalse);
    await first.createVault('482916');
    final note = await first.addNote('ilk', 'merhaba dünya');
    final fp = await first.myFingerprint();
    expect(fp.split(' '), hasLength(12));
    first.lock();
    expect(() => first.items(), throwsA(anything));

    final again = await RustCore.open(dir.path, desktop: false);
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
    final ayse = await RustCore.open(a.path, desktop: false);
    final bob = await RustCore.open(b.path, desktop: false);
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
}
