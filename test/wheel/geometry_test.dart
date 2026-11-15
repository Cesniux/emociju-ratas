import 'dart:math' as math;

import 'package:emociju_ratas/data/jausmu_ratas.dart';
import 'package:emociju_ratas/data/models.dart';
import 'package:emociju_ratas/theme/colors.dart';
import 'package:emociju_ratas/wheel/geometry.dart';
import 'package:emociju_ratas/wheel/labels.dart';
import 'package:emociju_ratas/wheel/sunburst_layout.dart';
import 'package:emociju_ratas/wheel/wheel_layout.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('polar and clockAngle agree: 0 at 12 o\'clock, clockwise', () {
    const c = Offset(100, 100);
    expect(polar(c, 0, 50), within(distance: 1e-9, from: const Offset(100, 50)));
    expect(polar(c, math.pi / 2, 50),
        within(distance: 1e-9, from: const Offset(150, 100)));
    for (var d = 0.0; d < 360; d += 7.5) {
      expect(clockAngle(c, polar(c, deg(d), 40)), closeTo(deg(d), 1e-9));
    }
  });

  test('Lithuanian syllable split keeps diphthongs whole', () {
    expect(splitSyllables('Pasibjaurėjimas'), ('Pasibjau-', 'rėjimas'));
    expect(splitSyllables('Baimė'), isNull);
  });

  for (final side in [320.0, 378.0, 560.0]) {
    for (final form in WordForm.values) {
      group('Jausmų ratas at $side dp (${form.name})', () {
        late SunburstLayout layout;
        setUp(() => layout = SunburstLayout(jausmuRatas,
            side: side, colors: AppColors.light, form: form));
        tearDown(() => layout.dispose());

        test('the centre of every segment hits that word', () {
          for (final f in jausmuRatas.feelings) {
            final hit = layout.hitTest(layout.centroidOf(f.id));
            expect(hit, isA<SunburstHit>(), reason: f.id);
            expect((hit! as SunburstHit).feelingId, f.id, reason: f.id);
            expect(hit.familyId, f.familyId, reason: f.id);
          }
        });

        test('no dead zones between the hole and the rim', () {
          final c = layout.center;
          for (var a = 0.0; a < 360; a += 0.5) {
            for (var k = 0; k < 20; k++) {
              final r = layout.stops.first + 1 +
                  (layout.radius - layout.stops.first - 2) * k / 19;
              final hit = layout.hitTest(polar(c, deg(a), r));
              expect(hit, isNotNull, reason: '$a° r=$r');
            }
          }
          expect(layout.hitTest(c), isNull, reason: 'centre hole');
          expect(layout.hitTest(c + Offset(0, layout.radius + 20)), isNull);
        });

        test('family sweeps fill the circle', () {
          expect(layout.familySweep.fold<double>(0, (a, b) => a + b),
              closeTo(tau, 1e-9));
          expect(layout.middleCount, 41);
          expect(layout.outerCount, 82);
        });

        test('core names are readable at 1×; radial words never upside down',
            () {
          expect(layout.coreFont,
              greaterThanOrEqualTo(side < 360 ? 12 : LabelMin.core));
          for (final f in jausmuRatas.feelings) {
            final rot = layout.labelRotationOf(f.id);
            if (rot == null) continue;
            // Near 12 and 6 o'clock text runs vertically; allow 8° of tilt.
            expect(math.cos(rot), greaterThanOrEqualTo(-math.sin(deg(8)) - 1e-9),
                reason: f.id);
          }
        });
      });
    }
  }

  test('on a tablet every ring is readable without zooming', () {
    final layout = SunburstLayout(jausmuRatas,
        side: 560, colors: AppColors.light, form: WordForm.feminine);
    addTearDown(layout.dispose);
    expect(LabelMin.visible(layout.middleFont, LabelMin.word, 1), isTrue,
        reason: 'middle ${layout.middleFont}');
    expect(LabelMin.visible(layout.outerFont, LabelMin.word, 1.5), isTrue,
        reason: 'outer ${layout.outerFont}');
  });
}
