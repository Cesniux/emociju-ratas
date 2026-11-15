import 'package:emociju_ratas/data/models.dart';
import 'package:emociju_ratas/state/settings_store.dart';
import 'package:emociju_ratas/ui/focus_sheet.dart';
import 'package:emociju_ratas/wheel/wheel_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/pump_app.dart';

void main() {
  testWidgets('the saved wheel is on screen after the very first frame', (
    tester,
  ) async {
    await pumpApp(tester, store: MemorySettingsStore(wheelId: 'jausmu-ratas'));
    // One pump only: nothing loads after the first frame.
    expect(find.text('Kaip dabar jautiesi?'), findsOneWidget);
    expect(find.text('Jausmų ratas'), findsOneWidget);
    expect(find.byType(WheelView), findsOneWidget);
  });

  test('v1.0.0 picture choice migrates to a wheel id', () async {
    for (final (index, id) in [
      (0, 'jausmu-ratas'),
      (1, 'plutchik'),
      (2, 'jausmu-seimos'),
      (3, 'jausmu-ratas'),
    ]) {
      SharedPreferences.setMockInitialValues({'selectedImage': index});
      final store = await PrefsSettingsStore.load();
      expect(store.wheelId, id);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey(PrefsSettingsStore.legacyKey), isFalse);
    }
  });

  testWidgets('a family opens its words; a chosen word lands in the tray', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpApp(tester);
    await tester.pumpAndSettle();

    tester.semantics.tap(find.semantics.byLabel('Liūdesys'));
    await tester.pumpAndSettle();
    expect(find.byType(FocusSheet), findsOneWidget);
    expect(find.text('Nuobodus'), findsOneWidget);

    await tester.tap(find.text('Nuobodus'));
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(
        find.byKey(const ValueKey('chip-jausmu-ratas/liudesys/nuobodus')),
      ),
      isSemantics(isButton: true, isSelected: true, label: 'Nuobodus', hasTapAction: true),
    );

    await tester.tap(find.byTooltip('Uždaryti'));
    await tester.pumpAndSettle();
    expect(find.byType(FocusSheet), findsNothing);
    expect(find.text('Nuobodus'), findsOneWidget, reason: 'chip in the tray');

    await tester.tap(find.text('Išvalyti'));
    await tester.pumpAndSettle();
    expect(find.text('Nuobodus'), findsNothing);
    await tester.tap(find.text('Atšaukti'));
    await tester.pumpAndSettle();
    expect(find.text('Nuobodus'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('the word-form card switches every word and is remembered', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final store = await pumpApp(tester);
    await tester.pumpAndSettle();
    tester.semantics.tap(find.semantics.byLabel('Liūdesys'));
    await tester.pumpAndSettle();

    expect(find.text('Kaip tau patogiau?'), findsOneWidget);
    await tester.tap(find.text('pavargusi'));
    await tester.pumpAndSettle();
    expect(find.text('Nuobodi'), findsOneWidget);
    expect(find.text('Kaip tau patogiau?'), findsNothing);
    expect(store.wordForm, WordForm.feminine);
    semantics.dispose();
  });

  for (final brightness in Brightness.values) {
    testWidgets('home and sheet meet tap-target and contrast guidelines '
        '(${brightness.name})', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpApp(tester, brightness: brightness);
      await tester.pumpAndSettle();
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));

      tester.semantics.tap(find.semantics.byLabel('Džiaugsmas'));
      await tester.pumpAndSettle();
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      semantics.dispose();
    });
  }

  testWidgets('large text (200%) on a small phone does not overflow', (
    tester,
  ) async {
    await pumpApp(tester, size: const Size(320, 568), textScale: 2);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
