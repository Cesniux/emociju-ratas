import 'package:emociju_ratas/data/energija.dart';
import 'package:emociju_ratas/data/jausmu_seimos.dart';
import 'package:emociju_ratas/data/models.dart';
import 'package:emociju_ratas/data/plutchik.dart';
import 'package:emociju_ratas/theme/colors.dart';
import 'package:emociju_ratas/wheel/circumplex_layout.dart';
import 'package:emociju_ratas/wheel/petal_layout.dart';
import 'package:emociju_ratas/wheel/sunburst_layout.dart';
import 'package:emociju_ratas/wheel/wheel_layout.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/wheel_checks.dart';

void main() {
  for (final side in [320.0, 378.0, 560.0]) {
    test('Plutchik at $side dp: every band and dyad hits itself', () {
      final layout = PetalLayout(
        plutchik,
        side: side,
        colors: AppColors.light,
        form: WordForm.masculine,
      );
      addTearDown(layout.dispose);
      for (final f in plutchik.feelings) {
        final hit = layout.hitTest(layout.anchorOf(f.id));
        final id = switch (hit) {
          PetalHit(:final feelingId) => feelingId,
          DyadHit(:final feelingId) => feelingId,
          _ => null,
        };
        expect(id, f.id, reason: f.id);
      }
    });

    test('Plutchik at $side dp: every word whole on one line; mixes never '
        'larger than the basic feelings', () {
      final layout = PetalLayout(
        plutchik,
        side: side,
        colors: AppColors.light,
        form: WordForm.masculine,
      );
      addTearDown(layout.dispose);
      for (final f in plutchik.feelings) {
        expect(layout.labelLinesOf(f.id), 1, reason: f.id);
      }
      expect(layout.fonts[3], lessThanOrEqualTo(layout.fonts[1]));
      expect(layout.fonts[1], greaterThanOrEqualTo(side < 360 ? 5.8 : 7));
    });

    test('Energy circle at $side dp: word pills never overlap', () {
      final layout = CircumplexLayout(
        energija,
        side: side,
        colors: AppColors.light,
        form: WordForm.feminine,
      );
      addTearDown(layout.dispose);
      final rects = layout.pillRects;
      for (var i = 0; i < rects.length; i++) {
        for (var j = i + 1; j < rects.length; j++) {
          expect(
            rects[i].deflate(1).overlaps(rects[j].deflate(1)),
            isFalse,
            reason:
                '${energija.points[i].feeling.key} × '
                '${energija.points[j].feeling.key}',
          );
        }
      }
    });

    test('Jausmų šeimos at $side dp: every word hits itself', () {
      final layout = SunburstLayout(
        jausmuSeimos,
        side: side,
        colors: AppColors.light,
        form: WordForm.masculine,
      );
      addTearDown(layout.dispose);
      for (final f in jausmuSeimos.feelings) {
        final hit = layout.hitTest(layout.centroidOf(f.id)) as SunburstHit?;
        expect(hit?.feelingId, f.id, reason: f.id);
      }
      // Equal slices for the outer words; a word with no words below it
      // runs to the rim in one slice.
      for (final r in jausmuSeimos.roots) {
        for (final m in r.children) {
          final k = m.children.isEmpty ? 1 : m.children.length;
          expect(
            layout.segmentOf(m.feeling.id).sweep,
            closeTo(k * layout.slot, 1e-9),
            reason: m.feeling.id,
          );
        }
      }
      expect(layout.middleFont, layout.outerFont);
      expect(layout.middleFont, greaterThanOrEqualTo(side < 360 ? 4.5 : 5.6));
      expect(layout.coreFont, greaterThanOrEqualTo(layout.middleFont * 1.15));
      for (final r in jausmuSeimos.roots) {
        expect(layout.labelLinesOf(r.core.id), 1, reason: r.core.id);
        expect(layout.labelPlaceOf(r.core.id), closeTo(0.5, 1e-6));
      }
      // "Ilgesys" used to read the other way from the rest of Meilė.
      expectOneWayPerFamily(layout, jausmuSeimos);
    });
  }

  test('a tap on an energy-circle word chooses that word', () {
    final layout = CircumplexLayout(
      energija,
      side: 378,
      colors: AppColors.light,
      form: WordForm.masculine,
    );
    addTearDown(layout.dispose);
    final rects = layout.pillRects;
    for (var i = 0; i < rects.length; i++) {
      final hit = layout.hitTest(rects[i].center);
      expect(hit?.feelingId, energija.points[i].feeling.id);
    }
  });
}
