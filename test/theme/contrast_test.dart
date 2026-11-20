import 'dart:math' as math;

import 'package:emociju_ratas/data/models.dart';
import 'package:emociju_ratas/theme/colors.dart';
import 'package:emociju_ratas/theme/palette.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

/// WCAG 2.x contrast ratio.
double contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  for (final colors in [AppColors.light, AppColors.dark]) {
    final mode = colors.brightness.name;

    group('$mode theme', () {
      test('every interface text pair is at least 4.5:1 (WCAG 1.4.3)', () {
        for (final (name, fg, bg) in colors.textPairs) {
          expect(contrast(fg, bg), greaterThanOrEqualTo(4.5), reason: name);
        }
      });

      test('ink labels on every feeling tint are at least 4.5:1', () {
        for (final hue in FamilyHue.values) {
          for (final tier in Tier.values) {
            final fill = Palette.fill(hue, tier, colors.brightness);
            expect(
              contrast(colors.ink, fill),
              greaterThanOrEqualTo(4.5),
              reason: '${hue.name}/${tier.name}',
            );
          }
        }
      });

      test('ink outline on a chosen (strong) segment is at least 3:1', () {
        for (final hue in FamilyHue.values) {
          final fill = Palette.fill(hue, Tier.strong, colors.brightness);
          expect(
            contrast(colors.ink, fill),
            greaterThanOrEqualTo(3),
            reason: hue.name,
          );
        }
      });
    });
  }
}
