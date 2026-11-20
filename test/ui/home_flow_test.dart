import 'package:emociju_ratas/data/models.dart';
import 'package:emociju_ratas/state/settings_store.dart';
import 'package:emociju_ratas/ui/home_screen.dart';
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
    expect(find.text('Kaip dabar jautiesi?'), findsWidgets);
    final view = tester.widget<WheelView>(find.byType(WheelView));
    expect(view.wheel.id, 'jausmu-ratas');
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

  testWidgets('the wheel is for looking: words are read, not buttons', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpApp(tester);
    await tester.pumpAndSettle();
    final node = tester.getSemantics(find.bySemanticsLabel('Nuobodus').first);
    expect(node.flagsCollection.isButton, isFalse);
    await tester.tap(find.byKey(HomeScreen.wheelKey));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
    semantics.dispose();
  });

  testWidgets('the flower at the bottom right opens a drawer of wheels', (
    tester,
  ) async {
    final store = await pumpApp(tester);
    await tester.pumpAndSettle();
    final flower = find.byTooltip('Keisti ratą');
    expect(find.text('Keisti ratą'), findsNothing, reason: 'an icon, no text');
    expect(tester.getCenter(flower).dx, greaterThan(330));
    expect(tester.getCenter(flower).dy, greaterThan(780));
    final help = tester.getRect(find.byTooltip('Kaip naudotis'));
    expect(
      help.bottom,
      lessThan(tester.getRect(flower).top),
      reason: '? above',
    );
    expect(help.center.dx, closeTo(tester.getCenter(flower).dx, 1));
    await tester.tap(flower);
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.text('Kurį ratą naudoti?'), findsOneWidget);
    expect(find.text('Spalvos'), findsNothing, reason: 'lives in settings');

    await tester.tap(find.text('Plutchiko gėlė'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
    expect(store.wheelId, 'plutchik');
  });

  testWidgets('settings (top right) hold word form and colours', (
    tester,
  ) async {
    final store = await pumpApp(tester);
    await tester.pumpAndSettle();
    final gear = tester.getCenter(find.byTooltip('Nustatymai'));
    expect(gear.dx, greaterThan(300));
    expect(gear.dy, lessThan(100));
    await tester.tap(find.byTooltip('Nustatymai'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);

    await tester.tap(find.text('pavargusi'));
    await tester.pumpAndSettle();
    expect(store.wordForm, WordForm.feminine);

    await tester.tap(find.text('Tamsios'));
    await tester.pumpAndSettle();
    expect(store.themeMode, ThemeMode.dark);
    expect(
      Theme.of(tester.element(find.text('Nustatymai').last)).brightness,
      Brightness.dark,
    );
  });

  testWidgets('zoomed in: "Atstatyti" appears left of help and the question '
      'steps aside', (tester) async {
    await pumpApp(tester);
    await tester.pumpAndSettle();
    expect(find.byTooltip('Atstatyti'), findsNothing);
    final helpBefore = tester.getRect(find.byTooltip('Kaip naudotis'));

    final viewer = tester.widget<InteractiveViewer>(
      find.byType(InteractiveViewer),
    );
    viewer.transformationController!.value = Matrix4.diagonal3Values(2, 2, 1);
    await tester.pumpAndSettle();
    final button = find.byTooltip('Atstatyti');
    expect(button, findsOneWidget);
    expect(find.text('Atstatyti'), findsNothing, reason: 'no words');
    final help = tester.getRect(find.byTooltip('Kaip naudotis'));
    expect(help, helpBefore, reason: 'help stays put');
    final reset = tester.getRect(button);
    expect(reset.right, lessThan(help.left));
    expect(reset.center.dy, closeTo(help.center.dy, 1));
    // The question, hint and settings fade away so the wheel can use the
    // whole screen.
    expect(find.byTooltip('Nustatymai').hitTestable(), findsNothing);
    final fade = tester.widget<AnimatedOpacity>(
      find
          .ancestor(
            of: find.text('Kaip dabar jautiesi?').last,
            matching: find.byType(AnimatedOpacity),
          )
          .first,
    );
    expect(fade.opacity, 0);

    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.byTooltip('Atstatyti'), findsNothing);
    expect(find.byTooltip('Nustatymai').hitTestable(), findsOneWidget);
  });

  testWidgets('"Kaip naudotis" has no back arrow on top; "Grįžti" below', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Kaip naudotis'));
    await tester.pumpAndSettle();
    expect(find.byType(BackButton), findsNothing);
    expect(find.byType(AppBar), findsNothing);
    final back = find.text('Grįžti');
    expect(tester.getCenter(back).dy, greaterThan(780));
    await tester.tap(back);
    await tester.pumpAndSettle();
    expect(find.text('Kaip dabar jautiesi?').hitTestable(), findsOneWidget);
  });

  for (final brightness in Brightness.values) {
    testWidgets('home meets tap-target and contrast guidelines '
        '(${brightness.name})', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpApp(tester, brightness: brightness);
      await tester.pumpAndSettle();
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
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
