import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kilit/app.dart';
import 'package:kilit/core/dev_core.dart';
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

Future<DevCore> startApp(
  WidgetTester tester, {
  Size size = const Size(400, 860),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final core = DevCore();
  await tester.pumpWidget(KilitApp(core: core));
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
}
