@Tags(['shots'])
library;

import 'package:emociju_ratas/state/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

/// Renders the main screens with the real fonts into .context/shots/ for the
/// design and accessibility review.
void main() {
  Future<void> shot(WidgetTester tester, String name) async {
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../../.context/shots/$name.png'),
    );
  }

  for (final id in ['jausmu-ratas', 'plutchik', 'energija', 'jausmu-seimos']) {
    testWidgets('home $id', (tester) async {
      await pumpApp(
        tester,
        store: MemorySettingsStore(wheelId: id),
        pixelRatio: 2,
      );
      await shot(tester, '10-home-$id');
    });
  }

  testWidgets('home dark', (tester) async {
    await pumpApp(tester, brightness: Brightness.dark, pixelRatio: 2);
    await shot(tester, '11-home-dark');
  });

  testWidgets('sheet with chosen words, then the tray', (tester) async {
    final s = tester.ensureSemantics();
    await pumpApp(tester, pixelRatio: 2);
    await tester.pumpAndSettle();
    tester.semantics.tap(find.semantics.byLabel('Liūdesys'));
    await tester.pumpAndSettle();
    await shot(tester, '20-sheet-liudesys');
    await tester.tap(find.text('pavargusi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nuobodi'));
    await tester.tap(find.text('Apatiška'));
    await tester.pumpAndSettle();
    await shot(tester, '21-sheet-chosen');
    await tester.tap(find.byTooltip('Uždaryti'));
    await tester.pumpAndSettle();
    tester.semantics.tap(find.semantics.byLabel('Baimė'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Grėsminga'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Uždaryti'));
    await shot(tester, '22-home-tray');
    s.dispose();
  });

  testWidgets('dark sheet', (tester) async {
    final s = tester.ensureSemantics();
    await pumpApp(tester, brightness: Brightness.dark, pixelRatio: 2);
    await tester.pumpAndSettle();
    tester.semantics.tap(find.semantics.byLabel('Džiaugsmas'));
    await shot(tester, '23-sheet-dark');
    s.dispose();
  });

  for (final (id, label, name) in [
    ('plutchik', 'Džiaugsmas', '24-sheet-plutchik'),
    ('energija', 'Mažai energijos, malonu', '25-sheet-energija'),
    ('jausmu-seimos', 'Meilė', '26-sheet-meile'),
  ]) {
    testWidgets('sheet $id', (tester) async {
      final s = tester.ensureSemantics();
      await pumpApp(
        tester,
        store: MemorySettingsStore(wheelId: id),
        pixelRatio: 2,
      );
      await tester.pumpAndSettle();
      tester.semantics.tap(find.semantics.byLabel(label));
      await shot(tester, name);
      s.dispose();
    });
  }

  testWidgets('wheel menu', (tester) async {
    await pumpApp(tester, pixelRatio: 2);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Jausmų ratas'));
    await shot(tester, '30-wheel-menu');
  });

  testWidgets('how to use', (tester) async {
    await pumpApp(tester, pixelRatio: 2);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kaip naudotis'));
    await shot(tester, '40-how-to-top');
    await tester.drag(find.byType(ListView).last, const Offset(0, -700));
    await shot(tester, '41-how-to-help');
    await tester.drag(find.byType(ListView).last, const Offset(0, -9000));
    await shot(tester, '42-how-to-sources');
  });

  testWidgets('tablet', (tester) async {
    await pumpApp(tester, size: const Size(820, 1180), pixelRatio: 1.5);
    await shot(tester, '50-tablet');
  });

  testWidgets('small phone, large text', (tester) async {
    await pumpApp(
      tester,
      size: const Size(375, 667),
      textScale: 1.6,
      pixelRatio: 2,
    );
    await shot(tester, '51-small-large-text');
  });
}
