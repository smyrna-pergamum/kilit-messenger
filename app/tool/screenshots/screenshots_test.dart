// Draws the README's screenshots from the real screens, filled with made-up
// people and messages (DevCore encrypts nothing and talks to no one). Kilit
// blocks screenshots on the phone itself, so this is how they are made.
//
//   flutter test tool/screenshots --update-goldens \
//     --dart-define=FONTS=<flutter>/bin/cache/artifacts/material_fonts
//
// The pictures land in docs/screenshots/.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kilit/app.dart';
import 'package:kilit/core/dev_core.dart';
import 'package:kilit/platform/tor.dart';
import 'package:kilit/state/prefs.dart';

import '../../test/app_test.dart' show FakeFiles, FakeTor, enterPin;

const _fonts = String.fromEnvironment('FONTS');

/// The development core, without its "no real encryption" banner: the
/// screenshots show the app as people see it.
class _Demo extends DevCore {
  _Demo({super.clock});

  @override
  bool get isDevelopmentStub => false;
}

Future<void> _font(String family, List<String> files) async {
  final l = FontLoader(family);
  for (final f in files) {
    l.addFont(Future.value(ByteData.sublistView(File(f).readAsBytesSync())));
  }
  await l.load();
}

Future<void> _shot(WidgetTester tester, String name) async {
  await tester.pumpAndSettle();
  await expectLater(
    find.byType(KilitApp),
    matchesGoldenFile('../../../docs/screenshots/$name.png'),
  );
}

void main() {
  testWidgets('screenshots', (tester) async {
    await tester.runAsync(() async {
      await _font('Roboto', [
        for (final w in ['Regular', 'Medium', 'Bold', 'Light', 'Italic'])
          '$_fonts/Roboto-$w.ttf',
      ]);
      await _font('MaterialIcons', ['$_fonts/MaterialIcons-Regular.otf']);
      await _font('JetBrains Mono', ['assets/fonts/JetBrainsMono.ttf']);
    });
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    var now = DateTime(2026, 10, 30, 8, 40);
    final core = _Demo(clock: () => now);
    final tor = TorController(FakeTor(), '/data');
    final prefs = await Prefs.load(
      MemoryPrefsStore({'theme': 'dark', 'language': 'en'}),
    );
    await tester.pumpWidget(
      KilitApp(core: core, files: FakeFiles(), prefs: prefs, tor: tor),
    );
    await tester.pumpAndSettle();
    await enterPin(tester, '482916');
    await enterPin(tester, '482916');
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(seconds: 1));
    }

    // made-up people
    const ayseWords = 'amber-river-stone-light';
    const boraWords = 'zoo-zone-zero-youth';
    const canWords = 'cedar-mango-orbit-silk';
    final ayse = DevCore.addressOf(ayseWords);
    final bora = DevCore.addressOf(boraWords);
    await core.addContact('@$ayseWords', name: 'Ayşe');
    await core.addContact('@$boraWords', name: 'Bora');

    core.deliver(boraWords, 'Could you send me the bridge settings?');
    now = DateTime(2026, 10, 30, 8, 52);
    await core.sendMessage(bora, 'Settings, Tor connection: Automatic.');
    core.receiptFrom(bora);

    now = DateTime(2026, 10, 30, 9, 12);
    core.deliver(ayseWords, 'Morning! Is the meeting still at 10:30?');
    now = DateTime(2026, 10, 30, 9, 14);
    await core.sendMessage(ayse, "Yes. I'll send the notes before.");
    await core.sendFile(
      ayse,
      'meeting-notes.pdf',
      'application/pdf',
      Uint8List(184320),
    );
    core.receiptFrom(ayse);
    now = DateTime(2026, 10, 30, 9, 20);
    core.deliver(ayseWords, 'Got them, thank you.');
    now = DateTime(2026, 10, 30, 9, 21);
    await core.sendMessage(ayse, 'See you there.');

    now = DateTime(2026, 10, 30, 9, 30);
    final family = await core.createGroup('Family', [ayse, bora]);
    now = DateTime(2026, 10, 30, 9, 34);
    core.groupMessage(family.id, bora, 'Dinner at eight on Saturday?');
    now = DateTime(2026, 10, 30, 9, 36);
    core.groupMessage(family.id, ayse, "Works for me. I'll cook.");
    now = DateTime(2026, 10, 30, 9, 40);
    await core.sendGroupMessage(family.id, "Great, I'll bring dessert.");

    now = DateTime(2026, 10, 30, 9, 45);
    core.deliver(canWords, 'Hi, we met at the workshop yesterday.');
    await tester.pump(const Duration(seconds: 4));

    await _shot(tester, '01-chats');

    await tester.tap(find.byKey(ValueKey('contact-$ayse')));
    await _shot(tester, '02-chat');
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(ValueKey('group-${family.id}')));
    await _shot(tester, '03-group');
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('my-id')));
    await _shot(tester, '04-my-kilit');
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('section-protections')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('section-bridges')));
    await _shot(tester, '05-bridges');

    await tester.tap(find.byKey(const ValueKey('lock-now')));
    await _shot(tester, '06-lock');

    tor.stop();
  });
}
