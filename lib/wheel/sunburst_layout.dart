import 'dart:math' as math;

import 'package:flutter/painting.dart';

import '../data/models.dart';
import '../theme/palette.dart';
import 'geometry.dart';
import 'labels.dart';
import 'wheel_layout.dart';

class _Seg {
  _Seg({
    required this.feeling,
    required this.family,
    required this.ring,
    required this.r0,
    required this.r1,
    required this.start,
    required this.sweep,
    required this.path,
    required this.tier,
    required this.corner,
  });

  final Feeling feeling;
  final int family;
  final int ring;
  final double r0;
  final double r1;
  final double start;
  final double sweep;
  final Path path;
  final Tier tier;
  final double corner;
  PlacedLabel? label;
  ArcLabel? arc;

  double get mid => start + sweep / 2;
  bool contains(double angle) => angleInSweep(angle, start, sweep);
}

/// Hierarchical rings (Jausmų ratas, Jausmų šeimos).
class SunburstLayout extends WheelLayout {
  SunburstLayout(
    this.model, {
    required super.side,
    required super.colors,
    required super.form,
    double coreScale = 1,
  }) {
    _build(coreScale.clamp(1.0, 1.3));
  }

  final SunburstWheel model;

  @override
  WheelModel get wheel => model;

  late final List<double> stops;
  late final List<double> familyStart;
  late final List<double> familySweep;
  final List<_Seg> _core = [];
  final List<_Seg> _middle = [];
  final List<_Seg> _outer = [];

  /// Uniform font sizes per ring (dp at zoom 1).
  late final double coreFont;
  late final double middleFont;
  late final double outerFont;

  bool get isCompact => radius < 230;

  void _build(double coreScale) {
    final R = radius;
    final twoRings = model.depth >= 2;
    final fr = isCompact
        ? (twoRings ? [0.10, 0.52, 0.76, 1.0] : [0.10, 0.52, 1.0])
        : (twoRings ? [0.12, 0.40, 0.68, 1.0] : [0.12, 0.45, 1.0]);
    stops = [for (final f in fr) f * R];
    final gap = (0.008 * R).clamp(1.5, 3.0);
    const corner = 4.0;

    // --- family sweeps: proportional to leaves, with a floor so names fit.
    final roots = model.roots;
    final n = roots.length;
    final totalLeaves = roots.fold<int>(0, (s, r) => s + r.leafCount);
    final rc = (stops[0] + stops[1]) / 2;
    final coreStyle = wheelLabelStyle(
      colors.ink,
      14 * coreScale,
      weight: FontWeight.w600,
    );
    final floors = <double>[];
    for (final r in roots) {
      final name = sentenceCase(r.family.name.of(form));
      final one = measure100(name, coreStyle).width * 0.14 * coreScale;
      final split = splitSyllables(name);
      var need = (one + 12) / rc;
      if (split != null) {
        final two =
            math.max(
              measure100(split.$1, coreStyle).width,
              measure100(split.$2, coreStyle).width,
            ) *
            0.14 *
            coreScale;
        need = math.min(need, (two + 12) / rc);
      }
      floors.add(math.min(need, tau / n * 1.5));
    }
    final sweeps = [for (final r in roots) tau * r.leafCount / totalLeaves];
    final fixed = List<bool>.filled(n, false);
    for (var pass = 0; pass < 6; pass++) {
      var changed = false;
      for (var i = 0; i < n; i++) {
        if (!fixed[i] && sweeps[i] < floors[i]) {
          sweeps[i] = floors[i];
          fixed[i] = true;
          changed = true;
        }
      }
      final fixedSum = [
        for (var i = 0; i < n; i++)
          if (fixed[i]) sweeps[i],
      ].fold<double>(0, (a, b) => a + b);
      final freeSum = [
        for (var i = 0; i < n; i++)
          if (!fixed[i]) sweeps[i],
      ].fold<double>(0, (a, b) => a + b);
      if (freeSum <= 0) break;
      final k = (tau - fixedSum) / freeSum;
      for (var i = 0; i < n; i++) {
        if (!fixed[i]) sweeps[i] *= k;
      }
      if (!changed) break;
    }
    // Floors may not all fit on a small screen: share the circle fairly.
    final total = sweeps.fold<double>(0, (a, b) => a + b);
    for (var i = 0; i < n; i++) {
      sweeps[i] *= tau / total;
    }
    familySweep = sweeps;
    final starts = <double>[];
    var a = normalize(-sweeps.first / 2); // first family centred at 12
    for (final s in sweeps) {
      starts.add(a);
      a = normalize(a + s);
    }
    familyStart = starts;

    // --- segments
    for (var i = 0; i < n; i++) {
      final root = roots[i];
      final hue = root.family.hue;
      _core.add(
        _Seg(
          feeling: root.core,
          family: i,
          ring: 0,
          r0: stops[0],
          r1: stops[1],
          start: starts[i],
          sweep: sweeps[i],
          path: sectorPath(
            center,
            stops[0],
            stops[1],
            starts[i],
            sweeps[i],
            gap: gap,
            corner: corner,
          ),
          tier: Tier.strong,
          corner: corner,
        ),
      );
      var ma = starts[i];
      final leaves = root.leafCount;
      for (final m in root.children) {
        final ms = sweeps[i] * m.leafCount / leaves;
        final mr1 = (m.children.isEmpty || !twoRings) ? stops.last : stops[2];
        _middle.add(
          _Seg(
            feeling: m.feeling,
            family: i,
            ring: 1,
            r0: stops[1],
            r1: mr1,
            start: ma,
            sweep: ms,
            path: sectorPath(
              center,
              stops[1],
              mr1,
              ma,
              ms,
              gap: gap,
              corner: corner,
            ),
            tier: Tier.medium,
            corner: corner,
          ),
        );
        var oa = ma;
        for (final o in m.children) {
          final os = ms / m.children.length;
          _outer.add(
            _Seg(
              feeling: o.feeling,
              family: i,
              ring: 2,
              r0: stops[2],
              r1: stops[3],
              start: oa,
              sweep: os,
              path: sectorPath(
                center,
                stops[2],
                stops[3],
                oa,
                os,
                gap: gap,
                corner: math.min(corner, 3),
              ),
              tier: Tier.soft,
              corner: math.min(corner, 3),
            ),
          );
          oa += os;
        }
        ma += ms;
      }
      assert(hue == root.family.hue);
    }

    // --- labels
    coreFont = _layoutCore(coreScale);
    middleFont = _layoutRadial(_middle, max: 15, weight: FontWeight.w500);
    outerFont = _layoutRadial(_outer, max: 14, weight: FontWeight.w500);
  }

  double _layoutCore(double coreScale) {
    final style = wheelLabelStyle(colors.ink, 100, weight: FontWeight.w600);
    final rc = (stops[0] + stops[1]) / 2;
    final thickness = stops[1] - stops[0] - 6;
    double best = 18 * coreScale;
    final fits = <(double, List<String>)>[];
    for (final seg in _core) {
      final name = sentenceCase(seg.feeling.word.of(form));
      final arc = rc * seg.sweep - 10;
      final m1 = measure100(name, style);
      final one = math.min(arc / m1.width, thickness / m1.height) * 100;
      var choice = (one, [name]);
      final split = splitSyllables(name);
      if (split != null && one < 15) {
        final w = math.max(
          measure100(split.$1, style).width,
          measure100(split.$2, style).width,
        );
        final two = math.min(arc / w, thickness / (2 * m1.height)) * 100;
        if (two > one) choice = (two, [split.$1, split.$2]);
      }
      fits.add(choice);
      best = math.min(best, choice.$1);
    }
    final size = best.clamp(6.0, 18 * coreScale);
    for (var i = 0; i < _core.length; i++) {
      final seg = _core[i];
      final name = sentenceCase(seg.feeling.word.of(form));
      final m1 = measure100(name, style);
      final singleFits = m1.width * size / 100 <= rc * seg.sweep - 10;
      seg.arc = ArcLabel.layout(
        lines: singleFits ? [name] : fits[i].$2,
        style: wheelLabelStyle(colors.ink, size, weight: FontWeight.w600),
        radius: rc,
        angle: seg.mid,
      );
    }
    return size.toDouble();
  }

  double _layoutRadial(
    List<_Seg> segs, {
    required double max,
    required FontWeight weight,
  }) {
    if (segs.isEmpty) return 0;
    final base = wheelLabelStyle(colors.ink, 100, weight: weight);
    final fits = <double>[];
    for (final seg in segs) {
      final text = seg.feeling.word.of(form);
      final m = measure100(text, base);
      final length = seg.r1 - seg.r0 - 8;
      final rMid = (seg.r0 + seg.r1) / 2;
      final room = rMid * seg.sweep * 0.82;
      fits.add(math.min(length / m.width, room / m.height) * 100);
    }
    // One calm size per ring; the few longest words shrink on their own.
    final sorted = [...fits]..sort();
    final ring = math.max(
      3.0,
      math.min(max, sorted[(sorted.length * 0.1).floor()]),
    );
    for (var i = 0; i < segs.length; i++) {
      final seg = segs[i];
      final size = math.max(2.0, math.min(ring, fits[i]));
      final theta = seg.mid;
      final famMid = familyStart[seg.family] + familySweep[seg.family] / 2;
      final sinT = math.sin(theta);
      final left = sinT.abs() < math.sin(deg(8))
          ? math.sin(famMid) < 0
          : sinT < 0;
      seg.label = PlacedLabel(
        lines: [
          layoutText(
            seg.feeling.word.of(form),
            wheelLabelStyle(colors.ink, size, weight: weight),
          ),
        ],
        anchor: polar(center, theta, (seg.r0 + seg.r1) / 2),
        rotation: left ? theta + math.pi / 2 : theta - math.pi / 2,
        fontSize: size,
      );
    }
    return ring;
  }

  Color _fill(_Seg s) =>
      Palette.fill(model.roots[s.family].family.hue, s.tier, brightness);

  Iterable<_Seg> get _all sync* {
    yield* _core;
    yield* _middle;
    yield* _outer;
  }

  @override
  void paintBase(Canvas canvas, double zoomStep) {
    for (final s in _all) {
      paintRounded(canvas, s.path, _fill(s), s.corner);
    }
    if (LabelMin.visible(coreFont, LabelMin.core, zoomStep)) {
      for (final s in _core) {
        s.arc?.paint(canvas, center);
      }
    }
    if (LabelMin.visible(middleFont, LabelMin.word, zoomStep)) {
      for (final s in _middle) {
        s.label?.paint(canvas);
      }
    }
    if (LabelMin.visible(outerFont, LabelMin.word, zoomStep)) {
      for (final s in _outer) {
        s.label?.paint(canvas);
      }
    }
  }

  @override
  void paintHighlights(
    Canvas canvas, {
    required Set<String> chosen,
    required double zoomStep,
    String? hoverFamilyId,
    Offset? probe,
  }) {
    if (hoverFamilyId != null) {
      for (final s in _core) {
        if (model.roots[s.family].family.id == hoverFamilyId) {
          paintRoundedOutline(
            canvas,
            s.path,
            colors.ink.withValues(alpha: 0.35),
            s.corner,
            1.5,
          );
          paintRounded(canvas, s.path, _fill(s), s.corner);
          if (LabelMin.visible(coreFont, LabelMin.core, zoomStep)) {
            s.arc?.paint(canvas, center);
          }
        }
      }
    }
    if (chosen.isEmpty) return;
    for (final s in _all) {
      if (!chosen.contains(s.feeling.key)) continue;
      paintRoundedOutline(canvas, s.path, colors.ink, s.corner, 2);
      paintRounded(
        canvas,
        s.path,
        Palette.fill(model.roots[s.family].family.hue, Tier.strong, brightness),
        s.corner,
      );
      switch (s.ring) {
        case 0 when LabelMin.visible(coreFont, LabelMin.core, zoomStep):
          s.arc?.paint(canvas, center);
        case 1 when LabelMin.visible(middleFont, LabelMin.word, zoomStep):
          s.label?.paint(canvas);
        case 2 when LabelMin.visible(outerFont, LabelMin.word, zoomStep):
          s.label?.paint(canvas);
        default:
          // Not readable at this zoom: a small ink dot marks the word.
          canvas.drawCircle(
            polar(center, s.mid, (s.r0 + s.r1) / 2),
            math.min(3.5, (s.r1 - s.r0) / 4),
            Paint()..color = colors.ink,
          );
      }
    }
  }

  @override
  WheelHit? hitTest(Offset p) {
    final r = (p - center).distance;
    if (r < stops[0] - 2 || r > radius + 8) return null;
    final a = clockAngle(center, p);
    int? fi;
    for (var i = 0; i < familyStart.length; i++) {
      if (angleInSweep(a, familyStart[i], familySweep[i])) {
        fi = i;
        break;
      }
    }
    fi ??= 0;
    final familyId = model.roots[fi].family.id;
    if (r < stops[1]) {
      return SunburstHit(familyId, feelingId: model.roots[fi].core.id);
    }
    _Seg? mid;
    for (final s in _middle) {
      if (s.family == fi && s.contains(a)) {
        mid = s;
        break;
      }
    }
    if (mid == null) return SunburstHit(familyId);
    if (r < mid.r1) return SunburstHit(familyId, feelingId: mid.feeling.id);
    for (final s in _outer) {
      if (s.family == fi && s.contains(a)) {
        return SunburstHit(familyId, feelingId: s.feeling.id);
      }
    }
    return SunburstHit(familyId, feelingId: mid.feeling.id);
  }

  @override
  late final List<SemanticTarget> semanticTargets = [
    for (var i = 0; i < _core.length; i++)
      SemanticTarget(
        rect: Rect.fromCenter(
          center: polar(center, _core[i].mid, (stops[0] + stops[1]) / 2),
          width: 48,
          height: 48,
        ),
        label: sentenceCase(model.roots[i].family.name.of(form)),
        familyId: model.roots[i].family.id,
        hit: SunburstHit(model.roots[i].family.id),
        order: i,
      ),
  ];

  /// Test hooks.
  int get middleCount => _middle.length;
  int get outerCount => _outer.length;
  ({double start, double sweep}) segmentOf(String feelingId) {
    final s = _all.firstWhere((s) => s.feeling.id == feelingId);
    return (start: s.start, sweep: s.sweep);
  }

  /// Centre point of a word's segment (tests, screenshots).
  Offset centroidOf(String feelingId) {
    final s = _all.firstWhere((s) => s.feeling.id == feelingId);
    return polar(center, s.mid, (s.r0 + s.r1) / 2);
  }

  /// Rotation of a radial label (tests: never upside down).
  double? labelRotationOf(String feelingId) =>
      _all.firstWhere((s) => s.feeling.id == feelingId).label?.rotation;

  @override
  void dispose() {
    for (final s in _all) {
      s.label?.dispose();
      s.arc?.dispose();
    }
  }
}
