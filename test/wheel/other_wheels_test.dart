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
      expect(layout.coreFont, greaterThanOrEqualTo(12));
    });
  }

  test('a tap on the energy circle offers the four nearest words', () {
    final layout = CircumplexLayout(
      energija,
      side: 378,
      colors: AppColors.light,
      form: WordForm.masculine,
    );
    addTearDown(layout.dispose);
    // Bottom-right: calm and pleasant.
    final hit =
        layout.hitTest(layout.center + const Offset(70, 70))! as CircumplexHit;
    final near = energija.nearest(hit.valence, hit.arousal);
    expect(
      near.map((p) => p.feeling.familyId).toSet(),
      contains('energija/mazai-energijos-malonu'),
    );
  });
}
