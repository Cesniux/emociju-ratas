import 'dart:math' as math;

import 'package:emociju_ratas/data/models.dart';
import 'package:emociju_ratas/wheel/geometry.dart';
import 'package:emociju_ratas/wheel/sunburst_layout.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every word in a family, its name included, runs along the radius the same
/// way (all outward or all inward), and none leans more than 30° past
/// upright.
void expectOneWayPerFamily(SunburstLayout layout, SunburstWheel wheel) {
  for (final root in wheel.roots) {
    final ways = <String, bool>{};
    for (final f in [
      root.core,
      for (final m in root.children) ...[
        m.feeling,
        for (final d in m.descendants) d.feeling,
      ],
    ]) {
      final rot = layout.labelRotationOf(f.id);
      if (rot == null) continue;
      final seg = layout.segmentOf(f.id);
      // Outward: rotation = θ − 90°; inward: θ + 90°.
      final turn = normalize(rot - (seg.start + seg.sweep / 2));
      final outward = (turn - 1.5 * math.pi).abs() < 1e-6;
      final inward = (turn - 0.5 * math.pi).abs() < 1e-6;
      expect(outward || inward, isTrue, reason: '${f.id} runs radially');
      ways[f.id] = outward;
      expect(
        math.cos(rot),
        greaterThanOrEqualTo(-math.sin(deg(30)) - 1e-9),
        reason: '${f.id} leans too far',
      );
    }
    expect(
      ways.values.toSet(),
      hasLength(1),
      reason: '${root.family.id}: $ways',
    );
  }
}
