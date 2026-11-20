import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart' show StringCharacters;

import '../data/models.dart';
import '../theme/palette.dart';
import 'geometry.dart';
import 'labels.dart';
import 'wheel_layout.dart';

class _Band {
  _Band(this.feeling, this.petal, this.level, this.path, this.anchor);

  final Feeling feeling;
  final int petal;

  /// 0 = intense (centre), 1 = basic, 2 = mild (petal tip).
  final int level;
  final Path path;
  final Offset anchor;
  PlacedLabel? label;

  Tier get tier => switch (level) {
    0 => Tier.strong,
    1 => Tier.medium,
    _ => Tier.soft,
  };
}

class _DyadPill {
  _DyadPill(this.dyad, this.index, this.label, this.rect);

  final Dyad dyad;
  final int index;
  final PlacedLabel label;
  final RRect rect;
}

/// Plutchik's flower: 8 petals × mild / basic / intense, dyads between.
class PetalLayout extends WheelLayout {
  PetalLayout(
    this.model, {
    required super.side,
    required super.colors,
    required super.form,
  }) {
    _build();
  }

  final PetalWheel model;

  @override
  WheelModel get wheel => model;

  final List<_Band> _bands = [];
  final List<_DyadPill> _dyads = [];
  late final List<double> radii; // hole, intense, basic, tip
  late final List<double> fonts; // intense, basic, mild, dyad
  static const double _corner = 3;
  static const FontWeight _weight = FontWeight.w800;

  double get _petalSweep => tau / model.petals.length;

  void _build() {
    final R = radius;
    // A wider centre: its words run along the radius, where they have room.
    radii = [0.05 * R, 0.38 * R, 0.63 * R, 0.84 * R];
    final gap = (0.008 * R).clamp(1.5, 3.0);
    final half = _petalSweep / 2;

    for (var i = 0; i < model.petals.length; i++) {
      final p = model.petals[i];
      final theta = i * _petalSweep;
      final start = theta - half;
      _bands.add(
        _Band(
          p.intense,
          i,
          0,
          sectorPath(
            center,
            radii[0],
            radii[1],
            start,
            _petalSweep,
            gap: gap,
            corner: _corner,
          ),
          polar(center, theta, (radii[0] + radii[1]) / 2 + 2),
        ),
      );
      _bands.add(
        _Band(
          p.basic,
          i,
          1,
          sectorPath(
            center,
            radii[1],
            radii[2],
            start,
            _petalSweep,
            gap: gap,
            corner: _corner,
          ),
          polar(center, theta, (radii[1] + radii[2]) / 2),
        ),
      );
      _bands.add(
        _Band(
          p.mild,
          i,
          2,
          _tipPath(theta, half, gap),
          polar(center, theta, radii[2] + (radii[3] - radii[2]) * 0.38),
        ),
      );
    }

    // Uniform font per level. The intense words in the narrow centre run
    // along the radius; basic and mild words stay level, easiest to read.
    final fit = RadialFit(across: gap + 1.4);
    double boxWidth(int level) => switch (level) {
      1 => 2 * ((radii[1] + radii[2]) / 2) * math.sin(half) * 0.86,
      _ => 2 * radii[2] * math.sin(half) * 0.62,
    };
    double boxHeight(int level) => switch (level) {
      1 => (radii[2] - radii[1]) * 0.78,
      _ => (radii[3] - radii[2]) * 0.5,
    };
    final perLevel = <int, (double, Map<int, List<String>>)>{};
    for (final level in [0, 1, 2]) {
      final style100 = wheelLabelStyle(colors.ink, 100, weight: _weight);
      var size = level == 1 ? 15.0 : 13.0;
      final lines = <int, List<String>>{};
      for (final b in _bands.where((b) => b.level == level)) {
        final text = wheelWord(b.feeling.word.of(form));
        final m = measure100(text, style100);
        // Only long words (11+ letters) may break across two lines.
        final split = text.characters.length >= 11
            ? splitSyllables(text)
            : null;
        final splitWidth = split == null
            ? null
            : math.max(
                measure100(split.$1, style100).width,
                measure100(split.$2, style100).width,
              );
        double one;
        double? two;
        if (level == 0) {
          one = fit.size(m.width / 100, _petalSweep, radii[0], radii[1]);
          if (splitWidth != null) {
            two = fit.size(
              splitWidth / 100,
              _petalSweep,
              radii[0],
              radii[1],
              2,
            );
          }
        } else {
          one =
              math.min(boxWidth(level) / m.width, boxHeight(level) / m.height) *
              100;
          if (splitWidth != null) {
            two =
                math.min(
                  boxWidth(level) / splitWidth,
                  boxHeight(level) / (2 * m.height),
                ) *
                100;
          }
        }
        var best = one;
        var chosenLines = [text];
        if (two != null && split != null && two > one * 1.12) {
          best = two;
          chosenLines = [split.$1, split.$2];
        }
        lines[b.petal] = chosenLines;
        size = math.min(size, best);
      }
      perLevel[level] = (math.max(size, 3), lines);
    }
    for (final b in _bands) {
      final (size, lines) = perLevel[b.level]!;
      final style = wheelLabelStyle(colors.ink, size, weight: _weight);
      final style100 = style.copyWith(fontSize: 100);
      final text = wheelWord(b.feeling.word.of(form));
      final theta = b.petal * _petalSweep;
      if (b.level == 0) {
        final em = measure100(text, style100).width / 100;
        final fitsOne =
            fit.size(em, _petalSweep, radii[0], radii[1]) >= size - 0.01;
        final chosen = fitsOne ? [text] : lines[b.petal]!;
        final lineEm = chosen
            .map((l) => measure100(l, style100).width / 100)
            .reduce(math.max);
        final r = fit.anchor(
          lineEm,
          size,
          _petalSweep,
          radii[0],
          radii[1],
          chosen.length,
        );
        b.label = PlacedLabel(
          lines: [for (final l in chosen) layoutText(l, style)],
          anchor: polar(center, theta, r),
          rotation: RadialFit.rotation(theta),
          fontSize: size,
          capCentered: true,
        );
        continue;
      }
      final fitsOne =
          measure100(text, style100).width * size / 100 <= boxWidth(b.level);
      final painted = [
        for (final l in (fitsOne ? [text] : lines[b.petal]!))
          layoutText(l, style),
      ];
      var anchor = b.anchor;
      if (b.level == 2) {
        // Side petals run sideways: slide the word out along the petal so
        // it never touches the basic word inside it.
        final w = painted.fold<double>(0, (m, l) => math.max(m, l.width));
        final needed = radii[2] + math.sin(theta).abs() * w / 2 + 4;
        final at = (anchor - center).distance;
        if (needed > at) anchor = polar(center, theta, needed);
      }
      b.label = PlacedLabel(
        lines: painted,
        anchor: anchor,
        rotation: 0,
        fontSize: size,
        capCentered: true,
      );
    }

    // Dyads: small pills between the petal tips.
    final style100 = wheelLabelStyle(colors.ink, 100, weight: _weight);
    var dyadSize = 11.0;
    for (final d in model.dyads) {
      final text = wheelWord(d.feeling.word.of(form));
      final m = measure100(text, style100);
      dyadSize = math.min(dyadSize, (side * 0.2) / m.width * 100);
    }
    dyadSize = math.max(dyadSize, 3);
    final dyadStyle = wheelLabelStyle(colors.ink, dyadSize, weight: _weight);
    for (var k = 0; k < model.dyads.length; k++) {
      final d = model.dyads[k];
      final theta = d.a * _petalSweep + half;
      final label = layoutText(wheelWord(d.feeling.word.of(form)), dyadStyle);
      var c = polar(center, theta, 0.925 * R);
      final w = label.width + 16;
      final h = label.height + 8;
      // Keep the pill inside the square.
      c = Offset(
        clampSafe(c.dx, w / 2 + 1, side - w / 2 - 1),
        clampSafe(c.dy, h / 2 + 1, side - h / 2 - 1),
      );
      _dyads.add(
        _DyadPill(
          d,
          k,
          PlacedLabel(
            lines: [label],
            anchor: c,
            rotation: 0,
            fontSize: dyadSize,
            capCentered: true,
          ),
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: c, width: w, height: h),
            Radius.circular(h / 2),
          ),
        ),
      );
    }
    fonts = [perLevel[0]!.$1, perLevel[1]!.$1, perLevel[2]!.$1, dyadSize];
  }

  Path _tipPath(double theta, double half, double gap) {
    final r0 = radii[2] + gap / 2 + _corner;
    final tip = radii[3] - _corner;
    final d = gap / 2 + _corner;
    final o = math.asin(d / r0);
    final left = polar(center, theta - half + o, r0);
    final right = polar(center, theta + half - o, r0);
    final c1 = polar(center, theta - half * 0.82, r0 + (tip - r0) * 0.45);
    final c2 = polar(center, theta - half * 0.22, tip - (tip - r0) * 0.04);
    final c3 = polar(center, theta + half * 0.22, tip - (tip - r0) * 0.04);
    final c4 = polar(center, theta + half * 0.82, r0 + (tip - r0) * 0.45);
    final t = polar(center, theta, tip);
    return Path()
      ..moveTo(left.dx, left.dy)
      ..cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, t.dx, t.dy)
      ..cubicTo(c3.dx, c3.dy, c4.dx, c4.dy, right.dx, right.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: r0),
        canvasAngle(theta + half - o),
        -(2 * (half - o)),
        false,
      )
      ..close();
  }

  FamilyHue _hue(int petal) => model.petals[petal].family.hue;

  bool _levelVisible(int level, double zoomStep) =>
      LabelMin.visible(fonts[level], LabelMin.word, zoomStep);

  @override
  void paintBase(Canvas canvas, double zoomStep) {
    for (final b in _bands) {
      paintRounded(
        canvas,
        b.path,
        Palette.fill(_hue(b.petal), b.tier, brightness),
        _corner,
      );
    }
    for (final b in _bands) {
      if (_levelVisible(b.level, zoomStep)) b.label?.paint(canvas);
    }
    final pillFill = Paint()..color = colors.surface;
    final pillLine = Paint()
      ..color = colors.outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    if (zoomStep <= 0) return; // thumbnail: colour only
    final dyadsVisible = _levelVisible(3, zoomStep);
    for (final p in _dyads) {
      canvas.drawRRect(p.rect, pillFill);
      canvas.drawRRect(p.rect, pillLine);
      if (dyadsVisible) p.label.paint(canvas);
    }
  }

  @override
  WheelHit? hitTest(Offset p) {
    for (final b in _bands) {
      if (b.path.contains(p)) {
        final petal = model.petals[b.petal];
        return PetalHit(
          petal.family.id,
          petal: b.petal,
          feelingId: b.feeling.id,
        );
      }
    }
    for (final d in _dyads) {
      final target = d.rect.outerRect.inflate(
        math.max(0, (48 - d.rect.outerRect.shortestSide) / 2),
      );
      if (target.contains(p)) {
        return DyadHit(
          model.petals[d.dyad.a].family.id,
          dyad: d.index,
          feelingId: d.dyad.feeling.id,
        );
      }
    }
    final r = (p - center).distance;
    if (r < radii[0] - 2 || r > radii[3] + 6) return null;
    final a = clockAngle(center, p);
    final petal = (a / _petalSweep).round() % model.petals.length;
    final level = r < radii[1] ? 0 : (r < radii[2] ? 1 : 2);
    final petalModel = model.petals[petal];
    final feeling = switch (level) {
      0 => petalModel.intense,
      1 => petalModel.basic,
      _ => petalModel.mild,
    };
    return PetalHit(petalModel.family.id, petal: petal, feelingId: feeling.id);
  }

  @override
  late final List<SemanticTarget> semanticTargets = [
    // Each petal from the centre outward, then the mix after it.
    for (final b in _bands)
      SemanticTarget(
        rect: Rect.fromCenter(center: b.anchor, width: 48, height: 48),
        label: sentenceCase(b.feeling.word.of(form)),
        familyId: model.petals[b.petal].family.id,
        hit: PetalHit(
          model.petals[b.petal].family.id,
          petal: b.petal,
          feelingId: b.feeling.id,
        ),
        order: b.petal * 4 + b.level,
      ),
    for (final d in _dyads)
      SemanticTarget(
        rect: Rect.fromCenter(
          center: d.rect.center,
          width: math.max(48, d.rect.width),
          height: 48,
        ),
        label: sentenceCase(d.dyad.feeling.word.of(form)),
        familyId: model.petals[d.dyad.a].family.id,
        hit: DyadHit(
          model.petals[d.dyad.a].family.id,
          dyad: d.index,
          feelingId: d.dyad.feeling.id,
        ),
        order: d.dyad.a * 4 + 3,
      ),
  ];

  /// Test hooks.
  Offset anchorOf(String feelingId) {
    for (final b in _bands) {
      if (b.feeling.id == feelingId) return b.anchor;
    }
    return _dyads.firstWhere((d) => d.dyad.feeling.id == feelingId).rect.center;
  }

  @override
  void dispose() {
    for (final b in _bands) {
      b.label?.dispose();
    }
    for (final d in _dyads) {
      d.label.dispose();
    }
  }
}
