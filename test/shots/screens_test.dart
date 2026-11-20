@Tags(['shots'])
library;

import 'package:emociju_ratas/state/settings_store.dart';
import 'package:emociju_ratas/ui/how_to_screen.dart';
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

  testWidgets('home on an opening without the hint', (tester) async {
    await pumpApp(
      tester,
      store: MemorySettingsStore(launchCount: 1),
      pixelRatio: 2,
    );
    await shot(tester, '12-home-no-hint');
  });

  testWidgets('home dark', (tester) async {
    await pumpApp(tester, brightness: Brightness.dark, pixelRatio: 2);
    await shot(tester, '11-home-dark');
  });

  testWidgets('zoomed in, with the reset icon', (tester) async {
    await pumpApp(tester, pixelRatio: 2);
    await tester.pumpAndSettle();
    final viewer = tester.widget<InteractiveViewer>(
      find.byType(InteractiveViewer),
    );
    viewer.transformationController!.value = Matrix4.diagonal3Values(
      2.2,
      2.2,
      1,
    )..setTranslationRaw(-300, -500, 0);
    await shot(tester, '22-home-zoomed');
  });

  testWidgets('wheel menu', (tester) async {
    await pumpApp(tester, pixelRatio: 2);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Keisti ratą'));
    await shot(tester, '30-wheel-menu');
  });

  testWidgets('settings', (tester) async {
    await pumpApp(tester, pixelRatio: 2);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Nustatymai'));
    await shot(tester, '31-settings');
  });

  testWidgets('how to use', (tester) async {
    await pumpApp(tester, pixelRatio: 2);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Kaip naudotis'));
    await shot(tester, '40-how-to-top');
    await tester.drag(find.byType(Scrollable).last, const Offset(0, -700));
    await shot(tester, '41-how-to-help');
  });

  testWidgets('why the wheel can help: the short tour', (tester) async {
    await pumpApp(tester, pixelRatio: 2);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Kaip naudotis'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(WhyTile));
    await tester.tap(find.byType(WhyTile));
    await shot(tester, '44-why-top');
    final next = find.textContaining('Toliau:').first;
    await tester.ensureVisible(next);
    await tester.pumpAndSettle();
    await tester.tap(next);
    await shot(tester, '45-why-next');
    await tester.drag(find.byType(Scrollable).last, const Offset(0, -9000));
    await shot(tester, '46-why-bottom');
  });

  testWidgets('tablet', (tester) async {
    await pumpApp(tester, size: const Size(820, 1180), pixelRatio: 1.5);
    await shot(tester, '50-tablet');
  });

  testWidgets('phone on its side', (tester) async {
    await pumpApp(tester, size: const Size(874, 402), pixelRatio: 2);
    await shot(tester, '52-landscape');
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
