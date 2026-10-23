import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kilit/app.dart';
import 'package:kilit/core/dev_core.dart';
import 'package:kilit/platform/files.dart';
import 'package:kilit/widgets/pin_pad.dart';

Future<void> enterPin(WidgetTester tester, String pin) async {
  for (final c in pin.split('')) {
    await tester.tap(find.byKey(ValueKey('pin-digit-$c')));
    await tester.pump();
  }
  await tester.tap(find.byKey(const ValueKey('pin-submit')));
  await tester.pumpAndSettle();
}

String titleText(WidgetTester tester) =>
    tester.widget<Text>(find.byKey(const ValueKey('lock-title'))).data!;

/// Picks what the test puts in [next]; records what was saved.
class FakeFiles implements FileAccess {
  PickedFile? next;
  Incoming? incoming;
  final saved = <PickedFile>[];
  final _ready = StreamController<void>.broadcast();

  @override
  Future<PickedFile?> pick() async => next;
  @override
  Future<bool> save(String name, String mime, Uint8List bytes) async {
    saved.add(PickedFile(name, mime, bytes));
    return true;
  }

  @override
  Future<Incoming?> takeIncoming() async {
    final i = incoming;
    incoming = null;
    return i;
  }

  @override
  Stream<void> get incomingReady => _ready.stream;
}

Future<DevCore> startApp(
  WidgetTester tester, {
  Size size = const Size(400, 860),
  FileAccess? files,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final core = DevCore();
  await tester.pumpWidget(KilitApp(core: core, files: files ?? FakeFiles()));
  await tester.pumpAndSettle();
  return core;
}

void main() {
  testWidgets('first run asks for a PIN twice, then opens the vault', (
    tester,
  ) async {
    await startApp(tester);
    expect(find.byKey(const ValueKey('dev-banner')), findsOneWidget);
    expect(titleText(tester), 'Bir PIN belirle');
    await enterPin(tester, '482916');
    expect(titleText(tester), 'PIN\'i tekrar gir');
    await enterPin(tester, '482916');
    expect(find.byKey(const ValueKey('vault-empty')), findsOneWidget);
  });

  testWidgets('mismatched PINs start over', (tester) async {
    await startApp(tester);
    await enterPin(tester, '482916');
    await enterPin(tester, '482917');
    expect(titleText(tester), 'Bir PIN belirle');
    expect(find.text('PIN\'ler eşleşmedi. Baştan başla.'), findsOneWidget);
  });

  testWidgets('submit stays off below six digits', (tester) async {
    await startApp(tester);
    for (final c in '12345'.split('')) {
      await tester.tap(find.byKey(ValueKey('pin-digit-$c')));
    }
    await tester.tap(find.byKey(const ValueKey('pin-submit')));
    await tester.pumpAndSettle();
    expect(titleText(tester), 'Bir PIN belirle');
  });

  testWidgets('locking and a wrong PIN, then the right one', (tester) async {
    await startApp(tester);
    await enterPin(tester, '482916');
    await enterPin(tester, '482916');
    await tester.tap(find.byKey(const ValueKey('lock-now')));
    await tester.pumpAndSettle();
    expect(titleText(tester), 'Kilidi aç');
    await enterPin(tester, '000000');
    expect(find.text('PIN yanlış.'), findsOneWidget);
    await enterPin(tester, '482916');
    expect(find.byKey(const ValueKey('vault-empty')), findsOneWidget);
  });

  testWidgets('a note appears in the vault and opens in packet analysis', (
    tester,
  ) async {
    await startApp(tester);
    await enterPin(tester, '482916');
    await enterPin(tester, '482916');
    await tester.tap(find.byKey(const ValueKey('add-note')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('note-title')),
      'şifreler',
    );
    await tester.enterText(find.byKey(const ValueKey('note-text')), 'gizli');
    await tester.tap(find.byKey(const ValueKey('note-save')));
    await tester.pumpAndSettle();
    expect(find.text('şifreler.txt'), findsOneWidget);
    await tester.tap(find.text('şifreler.txt'));
    await tester.pumpAndSettle();
    expect(find.text('Paket analizi'), findsOneWidget);
    expect(find.text('Ed25519 + ML-DSA-65, doğrulandı'), findsOneWidget);
  });

  testWidgets('a carrier message round-trips through paste', (tester) async {
    await startApp(tester);
    await enterPin(tester, '482916');
    await enterPin(tester, '482916');
    await tester.tap(find.byKey(const ValueKey('compose-carrier')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('carrier-message')),
      'yarın 10da',
    );
    await tester.enterText(
      find.byKey(const ValueKey('carrier-passphrase')),
      'uzun bir ortak parola',
    );
    await tester.tap(find.byKey(const ValueKey('carrier-seal')));
    await tester.pumpAndSettle();
    final sealed = tester
        .widget<SelectableText>(find.byKey(const ValueKey('carrier-result')))
        .data!;
    expect(sealed, startsWith('KLT1:'));
    expect(sealed, endsWith('.'));

    Navigator.of(tester.element(find.byKey(const ValueKey('carrier-result'))))
        .pop();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('open-pasted')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('paste-input')),
      'Ayşe: $sealed görüşürüz',
    );
    await tester.tap(find.byKey(const ValueKey('paste-open')));
    await tester.pumpAndSettle();
    expect(find.text('yarın 10da'), findsOneWidget);
  });

  testWidgets('wide windows get a side rail instead of a bottom bar', (
    tester,
  ) async {
    await startApp(tester, size: const Size(1200, 800));
    await enterPin(tester, '482916');
    await enterPin(tester, '482916');
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  test('the PIN pad shuffles all ten digits', () {
    final order = shuffledDigits();
    expect(order.toSet(), {for (var i = 0; i < 10; i++) i});
  });

  testWidgets('a picked file is sealed, exported as .klt and imported back', (
    tester,
  ) async {
    final files = FakeFiles();
    await startApp(tester, files: files);
    await enterPin(tester, '482916');
    await enterPin(tester, '482916');

    files.next = PickedFile(
      'tatil.jpg',
      'image/jpeg',
      Uint8List.fromList([1, 2, 3]),
    );
    await tester.tap(find.byKey(const ValueKey('seal-file')));
    await tester.pumpAndSettle();
    expect(find.text('tatil.jpg'), findsOneWidget);

    await tester.tap(find.text('tatil.jpg'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('item-view-image')), findsOneWidget);
    await tester.ensureVisible(find.byKey(const ValueKey('item-export')));
    await tester.tap(find.byKey(const ValueKey('item-export')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('export-passphrase')),
      'uzun bir ortak parola',
    );
    await tester.tap(find.byKey(const ValueKey('export-go')));
    await tester.pumpAndSettle();
    expect(files.saved.single.name, endsWith('.klt'));
    expect(files.saved.single.name, isNot(contains('tatil')));

    // close the packet sheet, then open the exported file again
    Navigator.of(tester.element(find.text('Paket analizi'))).pop();
    await tester.pumpAndSettle();
    files.next = files.saved.single;
    await tester.tap(find.byKey(const ValueKey('open-klt')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('import-go')));
    await tester.pumpAndSettle();
    expect(find.text('tatil.jpg'), findsNWidgets(2));
  });

  testWidgets('saving unencrypted asks first', (tester) async {
    final files = FakeFiles();
    await startApp(tester, files: files);
    await enterPin(tester, '482916');
    await enterPin(tester, '482916');
    files.next = PickedFile(
      'rapor.pdf',
      'application/pdf',
      Uint8List.fromList([7]),
    );
    await tester.tap(find.byKey(const ValueKey('seal-file')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('rapor.pdf'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('item-save-plain')));
    await tester.tap(find.byKey(const ValueKey('item-save-plain')));
    await tester.pumpAndSettle();
    expect(find.text('Şifresiz kaydedilsin mi?'), findsOneWidget);
    expect(files.saved, isEmpty);
    await tester.tap(find.byKey(const ValueKey('confirm-save-plain')));
    await tester.pumpAndSettle();
    expect(files.saved.single.name, 'rapor.pdf');
  });

  testWidgets('a KLT1 message shared from another app opens the paste sheet', (
    tester,
  ) async {
    final files = FakeFiles()
      ..incoming = const Incoming.text('Ayşe: KLT1:abc. görüşürüz');
    await startApp(tester, files: files);
    await enterPin(tester, '482916');
    await enterPin(tester, '482916');
    await tester.pumpAndSettle();
    expect(find.text('Yapıştırılanı aç'), findsWidgets);
    final field = tester.widget<TextField>(
      find.byKey(const ValueKey('paste-input')),
    );
    expect(field.controller!.text, contains('KLT1:abc.'));
  });

  test('media types come from file names', () {
    expect(guessMime('A.JPG'), 'image/jpeg');
    expect(guessMime('x.klt'), 'application/x-kilit');
    expect(guessMime('noext'), 'application/octet-stream');
  });
}
