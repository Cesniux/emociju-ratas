import 'package:emociju_ratas/copy/strings.dart';
import 'package:emociju_ratas/data/science.dart';
import 'package:emociju_ratas/ui/how_to_screen.dart';
import 'package:emociju_ratas/ui/reading.dart';
import 'package:emociju_ratas/ui/why_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

void main() {
  // A very tall screen: each page is built and visible at once, nothing to
  // scroll.
  Future<void> openHowTo(WidgetTester tester) async {
    await pumpApp(tester, size: const Size(402, 9000), pixelRatio: 1);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Kaip naudotis'));
    await tester.pumpAndSettle();
  }

  Future<void> openWhy(WidgetTester tester) async {
    await openHowTo(tester);
    await tester.tap(find.text(S.whyTitle));
    await tester.pumpAndSettle();
  }

  /// Whether the text can be seen and touched (a folded card keeps its
  /// words in the tree, hidden).
  bool shown(Finder text) => text.hitTestable().evaluate().isNotEmpty;

  Finder tourTitle(int i) => find.text(tourCards[i].title);
  bool chapterOpen(int i) => shown(find.text(tourCards[i].paragraphs.last));

  test('a folded card shows its first sentence', () {
    expect(
      firstSentence('Jausmai keičiasi. Nuostaba, baimė ar susierzinimas.'),
      'Jausmai keičiasi.',
    );
    expect(
      firstSentence('Galima jausti ir džiaugsmą, ir liūdesį kartu.'),
      'Galima jausti ir džiaugsmą, ir liūdesį kartu.',
    );
  });

  test('the tour has the six chapters its lead promises', () {
    expect(tourCards, hasLength(6));
    expect(S.whyLead, startsWith('Šeši'));
  });

  testWidgets('"Kaip naudotis": how to use, then the tile to "why", then '
      'help; nothing folded', (tester) async {
    await openHowTo(tester);
    final steps = guideCards.firstWhere((c) => c.kind == CardKind.steps);
    expect(shown(find.text(steps.paragraphs.first)), isTrue);
    expect(shown(find.text(steps.paragraphs.last)), isTrue);
    expect(shown(find.text('Vilties linija')), isTrue);
    expect(find.byType(FoldCard), findsNothing);

    final stepsBottom = tester.getBottomLeft(find.text(steps.paragraphs.last));
    final tile = tester.getRect(find.byType(WhyTile));
    final help = tester.getTopLeft(find.text('Jei labai sunku'));
    expect(stepsBottom.dy, lessThan(tile.top), reason: 'below how to use');
    expect(tile.bottom, lessThan(help.dy), reason: 'above help');
    expect(shown(find.text(S.whyLead)), isTrue);
  });

  testWidgets('the tile opens the tour on its first chapter; the others are '
      'folded to a title and a first sentence', (tester) async {
    await openWhy(tester);
    expect(find.byType(WhyScreen), findsOneWidget);
    expect(chapterOpen(0), isTrue);
    for (var i = 1; i < tourCards.length; i++) {
      expect(chapterOpen(i), isFalse, reason: tourCards[i].id);
      final lead = firstSentence(tourCards[i].paragraphs.first);
      expect(shown(find.text(lead)), isTrue, reason: tourCards[i].id);
    }
    expect(shown(find.text('1')), isTrue, reason: 'numbered');
  });

  testWidgets('opening one chapter closes the one that was open', (
    tester,
  ) async {
    await openWhy(tester);
    await tester.tap(tourTitle(2));
    await tester.pumpAndSettle();
    expect(chapterOpen(2), isTrue);
    expect(chapterOpen(0), isFalse);

    await tester.tap(find.text(S.sources));
    await tester.pumpAndSettle();
    expect(chapterOpen(2), isFalse);
    expect(shown(find.textContaining('Zaccaro', findRichText: true)), isTrue);

    await tester.tap(find.text(S.sources));
    await tester.pumpAndSettle();
    expect(shown(find.textContaining('Zaccaro', findRichText: true)), isFalse);
  });

  testWidgets('"Toliau" walks the tour, and the last chapter leads back to '
      'the wheel', (tester) async {
    await openWhy(tester);
    for (var i = 0; i + 1 < tourCards.length; i++) {
      final next = find.text('${S.next}: ${tourCards[i + 1].title}');
      expect(shown(next), isTrue, reason: 'chapter ${i + 1}');
      await tester.tap(next);
      await tester.pumpAndSettle();
      expect(chapterOpen(i + 1), isTrue);
      expect(chapterOpen(i), isFalse);
    }
    await tester.tap(find.text(S.backToWheel));
    await tester.pumpAndSettle();
    expect(find.byType(WhyScreen), findsNothing);
    expect(find.text('Kaip dabar jautiesi?').hitTestable(), findsOneWidget);
  });

  testWidgets('the source numbers under "how to use" open the sources', (
    tester,
  ) async {
    await openHowTo(tester);
    await tester.tap(find.text('${S.sources}: 1, 2, 3, 4'));
    await tester.pumpAndSettle();
    expect(find.byType(WhyScreen), findsOneWidget);
    expect(shown(find.textContaining('Zaccaro', findRichText: true)), isTrue);
    expect(chapterOpen(0), isFalse);
  });

  testWidgets('a folded chapter is one button that says it is folded', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await openWhy(tester);
    final node = tester.getSemantics(tourTitle(4));
    expect(node.flagsCollection.isButton, isTrue);
    expect(node.label, contains(firstSentence(tourCards[4].paragraphs.first)));
    expect(node.hint, isNotEmpty);
    semantics.dispose();
  });

  testWidgets('on a phone, the next chapter scrolls up to the top', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Kaip naudotis'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(WhyTile));
    await tester.tap(find.byType(WhyTile));
    await tester.pumpAndSettle();
    final next = find.text('${S.next}: ${tourCards[1].title}');
    await tester.ensureVisible(next);
    await tester.pumpAndSettle();
    await tester.tap(next);
    await tester.pumpAndSettle();
    final top = tester.getTopLeft(tourTitle(1)).dy;
    expect(top, lessThan(140), reason: 'title brought up, got $top');
  });
}
