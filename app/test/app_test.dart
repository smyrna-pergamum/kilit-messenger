import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kilit/app.dart';
import 'package:kilit/core/dev_core.dart';
import 'package:kilit/core/kilit_core.dart';
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

String? titleTextOrNull(WidgetTester tester) =>
    find.byKey(const ValueKey('lock-title')).evaluate().isEmpty
    ? null
    : titleText(tester);

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

  final shared = <String>[];

  @override
  bool get canShare => true;

  @override
  Future<void> shareText(String text) async => shared.add(text);
}

/// A core that finds every picture damaged.
class DamagedPictures extends DevCore {
  @override
  Future<CleanedFile> cleanMetadata(Uint8List bytes) async =>
      const CleanedFile.failed(CleanOutcome.damaged);
}

/// A clipboard that remembers what is written to it. Returns a reader of
/// its current text.
String? Function() workingClipboard(WidgetTester tester, String? text) {
  var current = text;
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      switch (call.method) {
        case 'Clipboard.getData':
          return current == null || current!.isEmpty ? null : {'text': current};
        case 'Clipboard.setData':
          current = (call.arguments as Map)['text'] as String?;
          return null;
        case 'Clipboard.hasStrings':
          return {'value': current?.isNotEmpty ?? false};
      }
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    ),
  );
  return () => current;
}

/// Types [code] on the panic dialog's keypad and confirms.
Future<void> enterPanicCode(WidgetTester tester, String code) async {
  for (final c in code.split('')) {
    await tester.tap(find.byKey(ValueKey('pin-digit-$c')));
    await tester.pump();
  }
  await tester.tap(find.byKey(const ValueKey('pin-submit')));
  await tester.pumpAndSettle();
}

Future<void> openSettingsSection(WidgetTester tester, String id) async {
  await tester.tap(find.byIcon(Icons.settings_outlined));
  await tester.pumpAndSettle();
  final header = find.byKey(ValueKey('section-$id'));
  await tester.ensureVisible(header);
  await tester.pumpAndSettle();
  await tester.tap(header);
  await tester.pumpAndSettle();
}

Future<void> setPanicCode(WidgetTester tester, String code) async {
  await openSettingsSection(tester, 'panic');
  await tester.ensureVisible(find.byKey(const ValueKey('panic-set')));
  await tester.tap(find.byKey(const ValueKey('panic-set')));
  await tester.pumpAndSettle();
  await enterPanicCode(tester, code);
  await enterPanicCode(tester, code);
}

Future<void> addNote(WidgetTester tester, String title) async {
  await tester.tap(find.byKey(const ValueKey('add-note')));
  await tester.pumpAndSettle();
  await tester.enterText(find.byKey(const ValueKey('note-title')), title);
  await tester.enterText(find.byKey(const ValueKey('note-text')), 'x');
  await tester.tap(find.byKey(const ValueKey('note-save')));
  await tester.pumpAndSettle();
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
  DevCore? core,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  core ??= DevCore();
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

  testWidgets('a carrier message is shared and round-trips through paste', (
    tester,
  ) async {
    final files = FakeFiles();
    await startApp(tester, files: files);
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
    await tester.tap(find.byKey(const ValueKey('carrier-share')));
    expect(files.shared.single, sealed);

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

  testWidgets('a message opened from the clipboard is kept, then cleared', (
    tester,
  ) async {
    await startApp(tester);
    await setUpVault(tester);
    final clipboard = workingClipboard(tester, 'Ayşe: KLT1:DEVbWVyaGFiYQ. bye');
    await tester.tap(find.byKey(const ValueKey('open-clipboard')));
    await tester.pumpAndSettle();
    expect(find.text('merhaba'), findsOneWidget);
    expect(find.text('Saved in the vault.'), findsOneWidget);
    expect(clipboard(), isEmpty);
    Navigator.of(tester.element(find.text('merhaba'))).pop();
    await tester.pumpAndSettle();
    expect(find.text('merhaba.txt'), findsOneWidget);

    // nothing left to offer
    await tester.tap(find.byKey(const ValueKey('open-clipboard')));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('No Kilit message on the clipboard'),
      findsOneWidget,
    );

    // the same message pasted again is not kept twice
    await tester.tap(find.byKey(const ValueKey('open-pasted')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('paste-input')),
      'KLT1:DEVbWVyaGFiYQ.',
    );
    await tester.tap(find.byKey(const ValueKey('paste-open')));
    await tester.pumpAndSettle();
    expect(find.text('Already in the vault.'), findsOneWidget);
    Navigator.of(tester.element(find.text('Already in the vault.'))).pop();
    await tester.pumpAndSettle();
    expect(find.text('merhaba.txt'), findsOneWidget);
  });

  testWidgets('the panic code on the lock screen resets Kilit', (tester) async {
    final (_, prefs) = await startApp(
      tester,
      size: const Size(400, 1400),
      prefs: {'language': 'en', 'theme': 'dark', 'clipboardHint': true},
    );
    await setUpVault(tester);
    await addNote(tester, 'secrets');
    await setPanicCode(tester, '7391');
    expect(find.text('Panic code set.'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('lock-now')));
    await tester.pumpAndSettle();

    await enterPin(tester, '7391');
    // as if newly installed: choose a PIN, settings back to their defaults
    expect(titleText(tester), 'Choose a PIN');
    expect(prefs.themeMode, ThemeMode.system);
    expect(prefs.clipboardHint, isFalse);
    expect(prefs.language, 'en');
    await setUpVault(tester);
    expect(find.byKey(const ValueKey('vault-empty')), findsOneWidget);
    expect(find.text('secrets.txt'), findsNothing);
  });

  testWidgets('holding the lock button asks for the panic code', (
    tester,
  ) async {
    await startApp(tester, size: const Size(400, 1400));
    await setUpVault(tester);
    await tester.longPress(find.byKey(const ValueKey('lock-now')));
    await tester.pumpAndSettle();
    expect(find.text('Set a panic code in Settings first.'), findsOneWidget);

    await addNote(tester, 'secrets');
    await setPanicCode(tester, '7391');
    await tester.longPress(find.byKey(const ValueKey('lock-now')));
    await tester.pumpAndSettle();
    await enterPanicCode(tester, '1111');
    expect(find.text('That is not the panic code.'), findsOneWidget);
    expect(titleTextOrNull(tester), isNull);

    await tester.longPress(find.byKey(const ValueKey('lock-now')));
    await tester.pumpAndSettle();
    await enterPanicCode(tester, '7391');
    expect(titleText(tester), 'Choose a PIN');
    await setUpVault(tester);
    expect(find.byKey(const ValueKey('vault-empty')), findsOneWidget);
  });

  testWidgets('the PIN is changed in settings, after the current one', (
    tester,
  ) async {
    await startApp(tester, size: const Size(400, 1400));
    await setUpVault(tester);
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('change-pin')));
    await tester.pumpAndSettle();
    expect(find.text('Enter your current PIN'), findsOneWidget);

    // a wrong current PIN starts over
    await enterPin(tester, '000000');
    await enterPin(tester, '135790');
    await enterPin(tester, '135790');
    expect(find.text('Wrong PIN.'), findsOneWidget);
    expect(find.text('Enter your current PIN'), findsOneWidget);

    await enterPin(tester, '482916');
    await enterPin(tester, '135790');
    await enterPin(tester, '135791');
    expect(find.text('The PINs did not match. Start again.'), findsOneWidget);
    await enterPin(tester, '135790');
    await enterPin(tester, '135790');
    expect(find.text('PIN changed.'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('lock-now')));
    await tester.pumpAndSettle();
    await enterPin(tester, '482916');
    expect(find.text('Wrong PIN.'), findsOneWidget);
    await enterPin(tester, '135790');
    expect(titleTextOrNull(tester), isNull);
  });

  const boraId = 'b0ba0000000000000000000000000001';

  Future<void> openChats(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.chat_bubble_outline));
    await tester.pumpAndSettle();
  }

  testWidgets('a contact is added from a card and gets a message', (
    tester,
  ) async {
    final files = FakeFiles();
    await startApp(tester, files: files);
    await setUpVault(tester);
    await openChats(tester);
    expect(find.byKey(const ValueKey('chats-empty')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('add-contact')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('contact-card')),
      'here is my card: ${DevCore.cardFor(boraId, 'Bora')}',
    );
    await tester.tap(find.byKey(const ValueKey('contact-add')));
    await tester.pumpAndSettle();
    // the new contact's conversation opens
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('chat-title'))).data,
      'Bora',
    );
    expect(find.byKey(const ValueKey('chat-empty')), findsOneWidget);

    await tester.enterText(find.byKey(const ValueKey('chat-input')), 'selam');
    await tester.tap(find.byKey(const ValueKey('chat-send')));
    await tester.pumpAndSettle();
    final sealed = tester
        .widget<SelectableText>(find.byKey(const ValueKey('sealed-text')))
        .data!;
    expect(sealed, startsWith('KLM1:'));
    await tester.tap(find.byKey(const ValueKey('sealed-share')));
    expect(files.shared.single, sealed);
    Navigator.of(tester.element(find.byKey(const ValueKey('sealed-text'))))
        .pop();
    await tester.pumpAndSettle();
    expect(find.text('selam'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('→ selam'), findsOneWidget);
  });

  testWidgets('a card that is not one is refused', (tester) async {
    await startApp(tester);
    await setUpVault(tester);
    await openChats(tester);
    await tester.tap(find.byKey(const ValueKey('add-contact')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('contact-card')), 'hi');
    await tester.tap(find.byKey(const ValueKey('contact-add')));
    await tester.pumpAndSettle();
    expect(
      find.text('This is not a contact card, or it is your own.'),
      findsOneWidget,
    );
  });

  testWidgets('a first message from the clipboard makes a new contact', (
    tester,
  ) async {
    await startApp(tester);
    await setUpVault(tester);
    await openChats(tester);
    final clipboard = workingClipboard(
      tester,
      'Bora: ${DevCore.messageFrom(boraId, 'merhaba, kartını aldım')}',
    );
    await tester.tap(find.byKey(const ValueKey('chat-open-clipboard')));
    await tester.pumpAndSettle();
    expect(find.text('merhaba, kartını aldım'), findsOneWidget);
    expect(find.byKey(const ValueKey('new-contact-banner')), findsOneWidget);
    expect(clipboard(), isEmpty);

    // name them, and look at the safety number
    await tester.tap(find.byKey(const ValueKey('chat-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('menu-rename')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('rename-input')), 'Bora');
    await tester.tap(find.byKey(const ValueKey('rename-save')));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('chat-title'))).data,
      'Bora',
    );
    expect(find.byKey(const ValueKey('new-contact-banner')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('chat-safety')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('safety-number')), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    // the same message again is not read twice
    workingClipboard(
      tester,
      DevCore.messageFrom(boraId, 'merhaba, kartını aldım'),
    );
    await tester.tap(find.byKey(const ValueKey('chat-paste')));
    await tester.pumpAndSettle();
    expect(find.text('This message was opened before.'), findsOneWidget);

    // and the contact can go, with the conversation
    await tester.tap(find.byKey(const ValueKey('chat-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('menu-remove')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('remove-contact-go')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('chats-empty')), findsOneWidget);
  });

  testWidgets('my card is made with the name to show', (tester) async {
    final files = FakeFiles();
    await startApp(tester, files: files);
    await setUpVault(tester);
    await openChats(tester);
    await tester.tap(find.byKey(const ValueKey('share-card')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('card-name')), 'Ayşe');
    await tester.tap(find.byKey(const ValueKey('card-make')));
    await tester.pumpAndSettle();
    final card = tester
        .widget<SelectableText>(find.byKey(const ValueKey('card-text')))
        .data!;
    expect(card, startsWith('KLC1:'));
    await tester.tap(find.byKey(const ValueKey('card-share')));
    expect(files.shared.single, card);
  });

  testWidgets('a tap on the lock button only locks', (tester) async {
    await startApp(tester);
    await setUpVault(tester);
    await tester.tap(find.byKey(const ValueKey('lock-now')));
    await tester.pumpAndSettle();
    expect(titleText(tester), 'Unlock');
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

    await tester.ensureVisible(
      find.byKey(const ValueKey('section-appearance')),
    );
    await tester.tap(find.byKey(const ValueKey('section-appearance')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(prefs.themeMode, ThemeMode.dark);
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);

    await tester.ensureVisible(
      find.byKey(const ValueKey('section-permissions')),
    );
    await tester.tap(find.byKey(const ValueKey('section-permissions')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('open-permissions')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('open-permissions')));
    expect(files.settingsOpened, 1);

    await tester.ensureVisible(find.byKey(const ValueKey('section-language')));
    await tester.tap(find.byKey(const ValueKey('section-language')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('language-tr')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('language-tr')));
    await tester.pumpAndSettle();
    expect(prefs.language, 'tr');
    // the list is scrolled down to the languages; the title bar shows it
    expect(find.text('Ayarlar'), findsWidgets);

    await tester.ensureVisible(find.byKey(const ValueKey('section-privacy')));
    await tester.tap(find.byKey(const ValueKey('section-privacy')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('clipboard-hint')));
    await tester.pumpAndSettle();
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

  testWidgets('a picture loses its hidden data before it is sealed', (
    tester,
  ) async {
    final files = FakeFiles();
    await startApp(tester, files: files);
    await setUpVault(tester);
    files.next = PickedFile(
      'beach.jpg',
      'image/jpeg',
      Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xD9]),
    );
    await tester.tap(find.byKey(const ValueKey('seal-file')));
    await tester.pump();
    expect(
      find.text(
        'beach.jpg was encrypted and added to the vault. '
        'Hidden data removed: location, camera details.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('a file type that cannot be cleaned is sealed with a note', (
    tester,
  ) async {
    final files = FakeFiles();
    await startApp(tester, files: files);
    await setUpVault(tester);
    files.next = PickedFile(
      'cv.pdf',
      'application/pdf',
      Uint8List.fromList([0x25, 0x50]),
    );
    await tester.tap(find.byKey(const ValueKey('seal-file')));
    await tester.pump();
    expect(find.textContaining("Kilit can't remove hidden data"), findsOne);
  });

  testWidgets('a damaged picture is sealed only when the user agrees', (
    tester,
  ) async {
    final files = FakeFiles();
    await startApp(tester, files: files, core: DamagedPictures());
    await setUpVault(tester);
    files.next = PickedFile(
      'broken.jpg',
      'image/jpeg',
      Uint8List.fromList([0xFF, 0xD8, 0xFF]),
    );
    await tester.tap(find.byKey(const ValueKey('seal-file')));
    await tester.pumpAndSettle();
    expect(find.text('Damaged picture'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('broken.jpg'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('seal-file')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('confirm-seal-damaged')));
    await tester.pumpAndSettle();
    expect(find.text('broken.jpg'), findsOneWidget);
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

  for (final lang in supportedLanguages.keys) {
    testWidgets('the lock screen and settings render in $lang', (tester) async {
      await startApp(
        tester,
        size: const Size(360, 2600),
        prefs: {'language': lang},
      );
      expect(tester.takeException(), isNull);
      final dir = Directionality.of(
        tester.element(find.byKey(const ValueKey('lock-title'))),
      );
      expect(
        dir,
        lang == 'ar' || lang == 'fa' ? TextDirection.rtl : TextDirection.ltr,
      );
      await setUpVault(tester);
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('status-tor')), findsOneWidget);
      // open every section: the safety number once crashed only when opened
      for (final id in [
        'panic',
        'fingerprint',
        'appearance',
        'language',
        'privacy',
        'permissions',
        'about',
      ]) {
        final header = find.byKey(ValueKey('section-$id'));
        // the list builds lazily: scroll until the header exists
        await tester.scrollUntilVisible(
          header,
          300,
          scrollable: find
              .descendant(
                of: find.byKey(const ValueKey('settings-list')),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await tester.pumpAndSettle();
        await tester.tap(header);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'opening $id in $lang');
      }
      expect(find.byKey(const ValueKey('fingerprint')), findsOneWidget);
      await tester.tap(find.byIcon(Icons.chat_bubble_outline));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('chats-empty')), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'chats in $lang');
    });
  }

  testWidgets(
    'switching the theme shifts colours smoothly, never through black',
    (tester) async {
      final (_, prefs) = await startApp(
        tester,
        prefs: {'language': 'en', 'theme': 'light'},
      );
      Color background() =>
          Theme.of(tester.element(find.byKey(const ValueKey('lock-title'))))
              .scaffoldBackgroundColor;
      final light = background();
      unawaited(prefs.setThemeMode(ThemeMode.dark));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      final middle = background();
      expect(middle, isNot(light));
      expect(middle, isNot(const Color(0xFF0D1117)));
      // halfway between night blue and paper, not black
      expect(middle.computeLuminance(), greaterThan(0.05));
      expect(
        find.byWidgetPredicate(
          (w) => w is FadeTransition && w.child is MaterialApp,
        ),
        findsNothing,
      );
      await tester.pumpAndSettle();
      expect(background(), const Color(0xFF0D1117));
    },
  );

  testWidgets('settings sections open and close', (tester) async {
    await startApp(tester, size: const Size(400, 1600));
    await setUpVault(tester);
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    // protections start open, the rest closed
    expect(find.byKey(const ValueKey('status-tor')), findsOneWidget);
    expect(find.byKey(const ValueKey('theme-choice')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('section-appearance')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('theme-choice')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('section-protections')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('status-tor')), findsNothing);
    // and stay as they were after a trip to another tab
    await tester.tap(find.text('Vault'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('theme-choice')), findsOneWidget);
    expect(find.byKey(const ValueKey('status-tor')), findsNothing);
  });
}
