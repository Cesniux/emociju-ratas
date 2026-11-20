import 'package:emociju_ratas/data/models.dart';
import 'package:emociju_ratas/data/wheels.dart';
import 'package:emociju_ratas/state/app_scope.dart';
import 'package:emociju_ratas/state/settings_store.dart';
import 'package:emociju_ratas/theme/colors.dart';
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

  testWidgets('the flower at the bottom right opens a drawer of wheels; '
      'help sits just left of it', (tester) async {
    final store = await pumpApp(tester);
    await tester.pumpAndSettle();
    final flower = find.byTooltip('Keisti ratą');
    expect(find.text('Keisti ratą'), findsNothing, reason: 'an icon, no text');
    expect(tester.getCenter(flower).dx, greaterThan(330));
    expect(tester.getCenter(flower).dy, greaterThan(780));
    final help = tester.getRect(find.byTooltip('Kaip naudotis'));
    final flowerRect = tester.getRect(flower);
    expect(help.right, lessThan(flowerRect.left), reason: '? on the left');
    expect(flowerRect.left - help.right, lessThan(20), reason: 'side by side');
    expect(help.center.dy, closeTo(flowerRect.center.dy, 1));
    await tester.tap(flower);
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.text('Pasirink emocijų ratą'), findsOneWidget);
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

  testWidgets('zoomed in: "Atstatyti" appears above the flower and the '
      'question steps aside', (tester) async {
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
    final flower = tester.getRect(find.byTooltip('Keisti ratą'));
    final reset = tester.getRect(button);
    expect(reset.bottom, lessThan(flower.top), reason: 'above the flower');
    expect(flower.top - reset.bottom, lessThan(20), reason: 'right above');
    expect(reset.center.dx, closeTo(flower.center.dx, 1));
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

  testWidgets('the hint shows on the first opening, then every third', (
    tester,
  ) async {
    final hint = wheelById(defaultWheelId).hint;
    for (final (before, shown) in [
      (0, true),
      (1, false),
      (2, false),
      (3, true),
      (4, false),
      (6, true),
    ]) {
      final store = await pumpApp(
        tester,
        store: MemorySettingsStore(launchCount: before),
      );
      await tester.pumpAndSettle();
      expect(store.launchCount, before + 1, reason: 'this opening counted');
      expect(
        find.text(hint).hitTestable(),
        shown ? findsOneWidget : findsNothing,
        reason: 'opening ${before + 1}',
      );
      expect(find.text('Kaip dabar jautiesi?').hitTestable(), findsOneWidget);
      // A fresh start for the next opening.
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('after switching light and dark the wheel words have the full '
      'ink colour, not the blend the theme passes through', (tester) async {
    await pumpApp(tester);
    await tester.pumpAndSettle();
    final settings = tester.widget<AppScope>(find.byType(AppScope)).settings;
    Color ink() =>
        tester.state<WheelViewState>(find.byType(WheelView)).layout!.colors.ink;
    expect(ink(), AppColors.light.ink);

    settings.setThemeMode(ThemeMode.dark);
    // Frame by frame through the theme's cross-fade.
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.pumpAndSettle();
    expect(ink(), AppColors.dark.ink);

    settings.setThemeMode(ThemeMode.light);
    await tester.pumpAndSettle();
    expect(ink(), AppColors.light.ink);
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
