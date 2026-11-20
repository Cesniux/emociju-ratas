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

  double get mid => start + sweep / 2;
  bool contains(double angle) => angleInSweep(angle, start, sweep);
}

/// One word to fit along a radius: its width in em (the wider of the two
/// word forms, so switching pavargęs / pavargusi never moves the rings) and
/// the room it gets across the wheel.
class _Fit {
  _Fit(this.em, this.sweep, {this.leaf = false});

  final double em;
  final double sweep;

  /// A middle word with no words below it: it runs to the rim.
  final bool leaf;
}

/// Hierarchical rings (Jausmų ratas, Jausmų šeimos).
///
/// Every outermost word gets the same slice of the circle, so no word is
/// squeezed and no slice is left half empty; each feeling family is as wide
/// as the words in it. All words, the family names too, run along the radius
/// like in the Lithuanian picture the wheel comes from, and the ring widths
/// are chosen for this screen so the words are as large as they can be.
/// Family names are never broken in two: they share one size, small enough
/// for the longest ("Pasibjaurėjimas") to sit whole in the middle of its
/// slice.
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

  /// Ring edges: hole, core | middle, middle | outer, rim.
  late final List<double> stops;
  late final List<double> familyStart;
  late final List<double> familySweep;

  /// The slice every outermost word gets.
  late final double slot;
  final List<_Seg> _core = [];
  final List<_Seg> _middle = [];
  final List<_Seg> _outer = [];

  /// Uniform font sizes per ring (dp at zoom 1).
  late final double coreFont;
  late final double middleFont;
  late final double outerFont;

  /// Family names are drawn at least this much larger than the other words.
  static const double _coreLead = 1.2;

  static const FontWeight coreWeight = FontWeight.w900;
  static const FontWeight wordWeight = FontWeight.w800;

  /// Outer ring drawn as one band per middle word in thumbnails, where the
  /// words are not drawn: fewer lines, calmer.
  final List<(Path, int, double)> _outerBands = [];

  /// Words are parted by a thin line, not a gap, so each word keeps the
  /// room (owner's choice, 2026-11-20: like the Lithuanian picture).
  late final double _gap;
  late final RadialFit _fit = RadialFit(across: _gap + 0.6, pad: 2.5);

  /// Corners stay just a little soft; round "pills" took room from words.
  static const double _corner = 1;

  double _fitSize(double em, double sweep, double a, double b, int lines) =>
      _fit.size(em, sweep, a, b, lines);

  void _build(double coreScale) {
    final R = radius;
    final twoRings = model.depth >= 2;
    _gap = (0.004 * R).clamp(0.75, 1.5);
    const corner = _corner;
    final roots = model.roots;
    final n = roots.length;

    // --- equal slices: one per outermost word, so families follow their words.
    int weight(SunburstNode m) => twoRings ? math.max(1, m.children.length) : 1;
    final famSlots = [
      for (final r in roots) r.children.fold<int>(0, (s, m) => s + weight(m)),
    ];
    final totalSlots = famSlots.fold<int>(0, (a, b) => a + b);
    slot = tau / totalSlots;
    final sweeps = [for (final k in famSlots) k * slot];
    familySweep = sweeps;
    final starts = <double>[];
    var a = normalize(-sweeps.first / 2); // first family centred at 12
    for (final s in sweeps) {
      starts.add(a);
      a = normalize(a + s);
    }
    familyStart = starts;

    // --- measure every word once (both forms, the wider decides).
    final coreStyle = wheelLabelStyle(colors.ink, 100, weight: coreWeight);
    final wordStyle = wheelLabelStyle(colors.ink, 100, weight: wordWeight);
    final widths = <String, double>{};
    double em(String text, TextStyle style) => widths.putIfAbsent(
      '${style.fontWeight}|$text',
      () => measure100(text, style).width / 100,
    );
    double emBoth(LtWord w, TextStyle style) => math.max(
      em(wheelWord(w.masculine), style),
      em(wheelWord(w.feminine), style),
    );
    final coreFits = [
      for (var i = 0; i < n; i++)
        _Fit(emBoth(roots[i].family.name, coreStyle), sweeps[i]),
    ];
    final midFits = <_Fit>[];
    final outFits = <_Fit>[];
    for (final r in roots) {
      for (final m in r.children) {
        final leaf = m.children.isEmpty || !twoRings;
        midFits.add(
          _Fit(emBoth(m.feeling.word, wordStyle), slot * weight(m), leaf: leaf),
        );
        if (!twoRings) continue;
        for (final o in m.children) {
          outFits.add(_Fit(emBoth(o.feeling.word, wordStyle), slot));
        }
      }
    }

    // --- ring widths: the split that gives the words the most room.
    final coreMax = 18 * coreScale;
    const wordMax = 15.0;
    // One size for every family name, each on one line in the middle of
    // its slice.
    double coreSize(double r0, double r1) {
      var size = coreMax;
      for (final f in coreFits) {
        size = math.min(size, _fit.centredSize(f.em, f.sweep, r0, r1));
      }
      return size;
    }

    /// The calm size of a ring and its smallest word. One size per ring;
    /// the few longest words shrink on their own.
    (double, double) ringSizes(List<_Fit> fits, double r0, double r1) {
      if (fits.isEmpty) return (wordMax, wordMax);
      final sizes = [
        for (final f in fits) _fitSize(f.em, f.sweep, r0, f.leaf ? R : r1, 1),
      ]..sort();
      return (
        math.min(wordMax, sizes[(sizes.length * 0.1).floor()]),
        sizes.first,
      );
    }

    final hole = math.max(4.0, 0.03 * R);
    var best = (score: -1.0, r1: 0.43 * R, r2: twoRings ? 0.71 * R : R);
    if (side >= 120) {
      final outer = <int, (double, double)>{
        if (twoRings)
          for (var i2 = 34; i2 <= 88; i2++)
            i2: ringSizes(outFits, i2 / 100 * R, R),
      };
      for (var i1 = 22; i1 <= 60; i1++) {
        final r1 = i1 / 100 * R;
        final core = coreSize(hole, r1);
        if (core <= 0) continue;
        for (var i2 = i1 + 12; i2 <= (twoRings ? 88 : i1 + 12); i2++) {
          final r2 = twoRings ? i2 / 100 * R : R;
          final (mid, midWorst) = ringSizes(midFits, r1, r2);
          final (out, outWorst) = twoRings ? outer[i2]! : (wordMax, wordMax);
          final words = math.min(mid, out);
          final worst = math.min(midWorst, outWorst);
          // Big words first, family names clearly larger, and the longest
          // words not left far behind.
          final score =
              math.min(words, core / _coreLead) +
              0.5 * math.min(worst, words) +
              0.01 * (words + core);
          if (score > best.score) best = (score: score, r1: r1, r2: r2);
        }
      }
    }
    stops = twoRings ? [hole, best.r1, best.r2, R] : [hole, best.r1, R];

    // --- segments
    for (var i = 0; i < n; i++) {
      final root = roots[i];
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
            gap: _gap,
            corner: corner,
          ),
          tier: Tier.strong,
          corner: corner,
        ),
      );
      var ma = starts[i];
      for (final m in root.children) {
        final ms = slot * weight(m);
        final leaf = m.children.isEmpty || !twoRings;
        final mr1 = leaf ? R : stops[2];
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
              gap: _gap,
              corner: corner,
            ),
            tier: Tier.medium,
            corner: corner,
          ),
        );
        if (!leaf) {
          _outerBands.add((
            sectorPath(center, stops[2], R, ma, ms, gap: _gap, corner: _corner),
            i,
            3,
          ));
          var oa = ma;
          for (final o in m.children) {
            _outer.add(
              _Seg(
                feeling: o.feeling,
                family: i,
                ring: 2,
                r0: stops[2],
                r1: R,
                start: oa,
                sweep: slot,
                path: sectorPath(
                  center,
                  stops[2],
                  R,
                  oa,
                  slot,
                  gap: _gap,
                  corner: _corner,
                ),
                tier: Tier.soft,
                corner: _corner,
              ),
            );
            oa += slot;
          }
        }
        ma += ms;
      }
    }

    // --- labels
    if (side < 120) {
      coreFont = 0;
      middleFont = 0;
      outerFont = 0;
      return; // thumbnail: colour only
    }
    coreFont = coreSize(stops[0], stops[1]);
    // The middle and outer words share one size: no ring looks squeezed.
    final words = math.min(
      ringSizes(midFits, stops[1], twoRings ? stops[2] : R).$1,
      twoRings ? ringSizes(outFits, stops[2], R).$1 : wordMax,
    );
    middleFont = words;
    outerFont = twoRings ? words : 0;
    _layoutCore();
    _layoutWords(_middle, middleFont);
    _layoutWords(_outer, outerFont);
  }

  /// Which way a family's words read. Every word in a family, its name
  /// included, reads the same way: outward when the family's middle is on
  /// the right half, inward on the left. A family right at 12 or 6 o'clock
  /// reads top to bottom.
  bool _readsInward(int family) {
    final mid = familyStart[family] + familySweep[family] / 2;
    final s = math.sin(mid);
    if (s.abs() > 1e-9) return s < 0;
    return math.cos(mid) > 0;
  }

  double _rotation(_Seg seg) =>
      RadialFit.rotation(seg.mid, left: _readsInward(seg.family));

  void _layoutCore() {
    final style = wheelLabelStyle(colors.ink, coreFont, weight: coreWeight);
    for (final seg in _core) {
      final name = wheelWord(seg.feeling.word.of(form));
      final em = measure100(name, style).width / 100;
      // Halfway along the slice; a word that would not fit there (never at
      // the chosen size) moves out only as far as it must.
      final length = em * coreFont;
      final inner = math.max(
        seg.r0 + _fit.pad,
        (_fit.lineEm * coreFont + _fit.across) / seg.sweep,
      );
      final r = math.min(
        math.max((seg.r0 + seg.r1) / 2, inner + length / 2),
        seg.r1 - _fit.pad - length / 2,
      );
      seg.label = PlacedLabel(
        lines: [layoutText(name, style)],
        anchor: polar(center, seg.mid, r),
        rotation: _rotation(seg),
        fontSize: coreFont,
        capCentered: true,
      );
    }
  }

  void _layoutWords(List<_Seg> segs, double ringFont) {
    if (segs.isEmpty) return;
    final base = wheelLabelStyle(colors.ink, 100, weight: wordWeight);
    for (final seg in segs) {
      final text = wheelWord(seg.feeling.word.of(form));
      final em = measure100(text, base).width / 100;
      final size = math.max(
        2.0,
        math.min(ringFont, _fitSize(em, seg.sweep, seg.r0, seg.r1, 1)),
      );
      final r = _fit.anchor(em, size, seg.sweep, seg.r0, seg.r1);
      seg.label = PlacedLabel(
        lines: [
          layoutText(
            text,
            wheelLabelStyle(colors.ink, size, weight: wordWeight),
          ),
        ],
        anchor: polar(center, seg.mid, r),
        rotation: _rotation(seg),
        fontSize: size,
        capCentered: true,
      );
    }
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
    final words = zoomStep > 0 && coreFont > 0;
    for (final s in _all) {
      if (s.ring == 2 && !words) continue;
      paintRounded(canvas, s.path, _fill(s), s.corner);
    }
    if (!words) {
      for (final (path, family, corner) in _outerBands) {
        paintRounded(
          canvas,
          path,
          Palette.fill(model.roots[family].family.hue, Tier.soft, brightness),
          corner,
        );
      }
      return;
    }
    for (final s in _all) {
      s.label?.paint(canvas);
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
  late final List<SemanticTarget> semanticTargets = () {
    // Clockwise, each family's core first, then its words outward.
    final ordered = [
      for (var i = 0; i < _core.length; i++) ...[
        _core[i],
        for (final m in _middle.where((s) => s.family == i)) ...[
          m,
          ..._outer.where(
            (o) => o.family == i && angleInSweep(o.mid, m.start, m.sweep),
          ),
        ],
      ],
    ];
    return [
      for (var k = 0; k < ordered.length; k++)
        SemanticTarget(
          rect: Rect.fromCenter(
            center: polar(
              center,
              ordered[k].mid,
              (ordered[k].r0 + ordered[k].r1) / 2,
            ),
            width: 48,
            height: 48,
          ),
          label: sentenceCase(ordered[k].feeling.word.of(form)),
          familyId: model.roots[ordered[k].family].family.id,
          hit: SunburstHit(
            model.roots[ordered[k].family].family.id,
            feelingId: ordered[k].feeling.id,
          ),
          order: k,
        ),
    ];
  }();

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

  /// Lines a word is drawn on (tests: family names are never broken).
  int? labelLinesOf(String feelingId) =>
      _all.firstWhere((s) => s.feeling.id == feelingId).label?.lines.length;

  /// How far along its ring a word's middle sits: 0 at the ring's inner
  /// edge, 1 at the outer (tests: family names in the middle).
  double? labelPlaceOf(String feelingId) {
    final s = _all.firstWhere((s) => s.feeling.id == feelingId);
    final label = s.label;
    if (label == null) return null;
    return ((label.anchor - center).distance - s.r0) / (s.r1 - s.r0);
  }

  /// Smallest word in a ring (tests: nothing squeezed).
  double minFontOf(int ring) => _all
      .where((s) => s.ring == ring && s.label != null)
      .fold(double.infinity, (m, s) => math.min(m, s.label!.fontSize));

  /// Font size a word is drawn at (tests: nothing squeezed).
  double? labelSizeOf(String feelingId) =>
      _all.firstWhere((s) => s.feeling.id == feelingId).label?.fontSize;

  @override
  void dispose() {
    for (final s in _all) {
      s.label?.dispose();
    }
  }
}
