import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kilit/app.dart';
import 'package:kilit/core/dev_core.dart';
import 'package:kilit/platform/files.dart';
import 'package:kilit/state/prefs.dart';
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
  int settingsOpened = 0;
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

  @override
  Future<void> openAppSettings() async => settingsOpened++;
}

/// Answers Flutter's clipboard calls with [text].
void fakeClipboard(WidgetTester tester, String? text) {
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async => switch (call.method) {
      'Clipboard.getData' => text == null ? null : {'text': text},
      'Clipboard.hasStrings' => {'value': text != null},
      _ => null,
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    ),
  );
}

Future<(DevCore, Prefs)> startApp(
  WidgetTester tester, {
  Size size = const Size(400, 860),
  FileAccess? files,
  Map<String, Object?>? prefs,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final core = DevCore();
  final p = await Prefs.load(MemoryPrefsStore(prefs));
  await tester.pumpWidget(
    KilitApp(core: core, files: files ?? FakeFiles(), prefs: p),
  );
  await tester.pumpAndSettle();
  return (core, p);
}

Future<void> setUpVault(WidgetTester tester) async {
  await enterPin(tester, '482916');
  await enterPin(tester, '482916');
}

void main() {
  testWidgets('first run asks for a PIN twice, then opens the vault', (
    tester,
  ) async {
    await startApp(tester);
    expect(find.byKey(const ValueKey('dev-banner')), findsOneWidget);
    expect(titleText(tester), 'Choose a PIN');
    await enterPin(tester, '482916');
    expect(titleText(tester), 'Enter the PIN again');
    await enterPin(tester, '482916');
    expect(find.byKey(const ValueKey('vault-empty')), findsOneWidget);
  });

  testWidgets('English is the default language', (tester) async {
    final (_, prefs) = await startApp(tester);
    expect(prefs.language, 'en');
    expect(find.text('Choose a PIN'), findsOneWidget);
  });

  testWidgets('mismatched PINs start over', (tester) async {
    await startApp(tester);
    await enterPin(tester, '482916');
    await enterPin(tester, '482917');
    expect(titleText(tester), 'Choose a PIN');
    expect(find.text('The PINs did not match. Start again.'), findsOneWidget);
  });

  testWidgets('submit stays off below six digits', (tester) async {
    await startApp(tester);
    for (final c in '12345'.split('')) {
      await tester.tap(find.byKey(ValueKey('pin-digit-$c')));
    }
    await tester.tap(find.byKey(const ValueKey('pin-submit')));
    await tester.pumpAndSettle();
    expect(titleText(tester), 'Choose a PIN');
  });

  testWidgets('locking and a wrong PIN, then the right one', (tester) async {
    await startApp(tester);
    await setUpVault(tester);
    await tester.tap(find.byKey(const ValueKey('lock-now')));
    await tester.pumpAndSettle();
    expect(titleText(tester), 'Unlock');
    await enterPin(tester, '000000');
    expect(find.text('Wrong PIN.'), findsOneWidget);
    await enterPin(tester, '482916');
    expect(find.byKey(const ValueKey('vault-empty')), findsOneWidget);
  });

  testWidgets('a note appears in the vault and opens in packet analysis', (
    tester,
  ) async {
    await startApp(tester);
    await setUpVault(tester);
    await tester.tap(find.byKey(const ValueKey('add-note')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('note-title')), 'secrets');
    await tester.enterText(find.byKey(const ValueKey('note-text')), 'hidden');
    await tester.tap(find.byKey(const ValueKey('note-save')));
    await tester.pumpAndSettle();
    expect(find.text('secrets.txt'), findsOneWidget);
    await tester.tap(find.text('secrets.txt'));
    await tester.pumpAndSettle();
    expect(find.text('Packet analysis'), findsOneWidget);
    expect(find.text('Ed25519 + ML-DSA-65, verified'), findsOneWidget);
  });

  testWidgets('a carrier message round-trips through paste', (tester) async {
    await startApp(tester);
    await setUpVault(tester);
    await tester.tap(find.byKey(const ValueKey('compose-carrier')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('carrier-message')),
      'tomorrow at ten',
    );
    await tester.enterText(
      find.byKey(const ValueKey('carrier-passphrase')),
      'a long shared passphrase',
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
      'Ayşe: $sealed see you',
    );
    await tester.tap(find.byKey(const ValueKey('paste-open')));
    await tester.pumpAndSettle();
    expect(find.text('tomorrow at ten'), findsOneWidget);
  });

  testWidgets('open from clipboard: one tap after copying in WhatsApp', (
    tester,
  ) async {
    await startApp(tester);
    await setUpVault(tester);
    fakeClipboard(tester, 'just a chat line');
    await tester.tap(find.byKey(const ValueKey('open-clipboard')));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('No Kilit message on the clipboard'),
      findsOneWidget,
    );

    fakeClipboard(tester, 'Ayşe: KLT1:DEVbWVyaGFiYQ. bye');
    await tester.tap(find.byKey(const ValueKey('open-clipboard')));
    await tester.pumpAndSettle();
    expect(find.text('merhaba'), findsOneWidget);
  });

  testWidgets('with the clipboard hint on, the vault offers the message', (
    tester,
  ) async {
    await startApp(tester, prefs: {'language': 'en', 'clipboardHint': true});
    fakeClipboard(tester, 'KLT1:DEVbWVyaGFiYQ.');
    await setUpVault(tester);
    expect(find.byKey(const ValueKey('clipboard-banner')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('clipboard-banner-open')));
    await tester.pumpAndSettle();
    expect(find.text('merhaba'), findsOneWidget);
  });

  testWidgets('without the hint the clipboard is not read', (tester) async {
    var reads = 0;
    await startApp(tester);
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.getData') reads++;
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await setUpVault(tester);
    expect(reads, 0);
    expect(find.byKey(const ValueKey('clipboard-banner')), findsNothing);
  });

  testWidgets('wide windows get a side rail instead of a bottom bar', (
    tester,
  ) async {
    await startApp(tester, size: const Size(1200, 800));
    await setUpVault(tester);
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('settings: theme, language and permissions', (tester) async {
    final files = FakeFiles();
    final (_, prefs) = await startApp(
      tester,
      size: const Size(400, 2400),
      files: files,
    );
    await setUpVault(tester);
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Your protections'), findsOneWidget);
    expect(find.byKey(const ValueKey('status-tor')), findsOneWidget);
    expect(find.textContaining('None (development core)'), findsOneWidget);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(prefs.themeMode, ThemeMode.dark);
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);

    await tester.tap(find.byKey(const ValueKey('open-permissions')));
    expect(files.settingsOpened, 1);

    await tester.tap(find.byKey(const ValueKey('language-tr')));
    await tester.pumpAndSettle();
    expect(prefs.language, 'tr');
    expect(find.text('Korumaların'), findsOneWidget);
    expect(find.text('Ayarlar'), findsWidgets);

    await tester.tap(find.byKey(const ValueKey('clipboard-hint')));
    await tester.pumpAndSettle();
    expect(prefs.clipboardHint, isTrue);
  });

  testWidgets('a picked file is sealed, exported as .klt and imported back', (
    tester,
  ) async {
    final files = FakeFiles();
    await startApp(tester, files: files);
    await setUpVault(tester);

    files.next = PickedFile(
      'holiday.jpg',
      'image/jpeg',
      Uint8List.fromList([1, 2, 3]),
    );
    await tester.tap(find.byKey(const ValueKey('seal-file')));
    await tester.pumpAndSettle();
    expect(find.text('holiday.jpg'), findsOneWidget);

    await tester.tap(find.text('holiday.jpg'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('item-view-image')), findsOneWidget);
    await tester.ensureVisible(find.byKey(const ValueKey('item-export')));
    await tester.tap(find.byKey(const ValueKey('item-export')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('export-passphrase')),
      'a long shared passphrase',
    );
    await tester.tap(find.byKey(const ValueKey('export-go')));
    await tester.pumpAndSettle();
    expect(files.saved.single.name, endsWith('.klt'));
    expect(files.saved.single.name, isNot(contains('holiday')));

    Navigator.of(tester.element(find.text('Packet analysis'))).pop();
    await tester.pumpAndSettle();
    files.next = files.saved.single;
    await tester.tap(find.byKey(const ValueKey('open-klt')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('import-go')));
    await tester.pumpAndSettle();
    expect(find.text('holiday.jpg'), findsNWidgets(2));
  });

  testWidgets('saving unencrypted asks first', (tester) async {
    final files = FakeFiles();
    await startApp(tester, files: files);
    await setUpVault(tester);
    files.next = PickedFile(
      'report.pdf',
      'application/pdf',
      Uint8List.fromList([7]),
    );
    await tester.tap(find.byKey(const ValueKey('seal-file')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('report.pdf'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('item-save-plain')));
    await tester.tap(find.byKey(const ValueKey('item-save-plain')));
    await tester.pumpAndSettle();
    expect(find.text('Save unencrypted?'), findsOneWidget);
    expect(files.saved, isEmpty);
    await tester.tap(find.byKey(const ValueKey('confirm-save-plain')));
    await tester.pumpAndSettle();
    expect(files.saved.single.name, 'report.pdf');
  });

  testWidgets('a KLT1 message shared from another app opens the paste sheet', (
    tester,
  ) async {
    final files = FakeFiles()
      ..incoming = const Incoming.text('Ayşe: KLT1:abc. see you');
    await startApp(tester, files: files);
    await setUpVault(tester);
    await tester.pumpAndSettle();
    final field = tester.widget<TextField>(
      find.byKey(const ValueKey('paste-input')),
    );
    expect(field.controller!.text, contains('KLT1:abc.'));
  });

  test('the PIN pad shuffles all ten digits', () {
    final order = shuffledDigits();
    expect(order.toSet(), {for (var i = 0; i < 10; i++) i});
  });

  test('media types come from file names', () {
    expect(guessMime('A.JPG'), 'image/jpeg');
    expect(guessMime('x.klt'), 'application/x-kilit');
    expect(guessMime('noext'), 'application/octet-stream');
  });

  test('preferences survive a reload and "system" is remembered', () async {
    final store = MemoryPrefsStore();
    final p = await Prefs.load(store);
    expect(p.language, 'en');
    await p.setLanguage(null);
    await p.setThemeMode(ThemeMode.light);
    final again = await Prefs.load(store);
    expect(again.language, isNull);
    expect(again.themeMode, ThemeMode.light);
  });
}
