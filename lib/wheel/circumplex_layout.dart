import 'dart:math' as math;

import 'package:flutter/painting.dart';

import '../data/models.dart';
import '../theme/palette.dart';
import 'geometry.dart';
import 'labels.dart';
import 'wheel_layout.dart';

class _Pill {
  _Pill(this.placed, this.label, this.rect, this.quadrant);

  final PlacedFeeling placed;
  final PlacedLabel label;
  final RRect rect;
  final int quadrant;
}

/// Russell's circumplex as a calm circle: pleasantness left → right,
/// energy bottom → top, intensity grows toward the rim.
class CircumplexLayout extends WheelLayout {
  CircumplexLayout(
    this.model, {
    required super.side,
    required super.colors,
    required super.form,
  }) {
    _build();
  }

  final CircumplexWheel model;

  @override
  WheelModel get wheel => model;

  final List<_Pill> _pills = [];
  final List<PlacedLabel> _axisLabels = [];
  late final double pillFont;

  /// Axis words (top, right, bottom, left).
  static const axes = [
    'Daug energijos',
    'Malonu',
    'Mažai energijos',
    'Nemalonu',
  ];

  void _build() {
    final R = radius;
    if (side < 200) {
      pillFont = 0;
      return; // thumbnail: colour only
    }
    pillFont = (R / 16).clamp(10.5, 14.0);
    final style = wheelLabelStyle(colors.ink, pillFont);
    final axisStyle = wheelLabelStyle(
      colors.ink,
      (R / 19).clamp(10.5, 13.0),
      weight: FontWeight.w500,
    );
    for (var i = 0; i < 4; i++) {
      final l = layoutText(axes[i], axisStyle);
      final inset = (i.isEven ? l.height : l.width) / 2 + 10;
      _axisLabels.add(
        PlacedLabel(
          lines: [l],
          anchor: polar(center, i * math.pi / 2, R - inset),
          rotation: 0,
          fontSize: axisStyle.fontSize!,
        ),
      );
    }
    final obstacles = [
      for (final l in _axisLabels)
        Rect.fromCenter(
          center: l.anchor,
          width: l.width + 8,
          height: l.height + 6,
        ),
    ];
    final labels = <TextPainter>[];
    final centres = <Offset>[];
    final sizes = <Size>[];
    for (final p in model.points) {
      final label = layoutText(wheelWord(p.feeling.word.of(form)), style);
      labels.add(label);
      sizes.add(Size(label.width + 18, label.height + 10));
      centres.add(polar(center, deg(p.clockDeg), p.radius * R * 0.9));
    }
    Offset clampIn(Offset c, Size s) {
      // Inside the square, and inside the circle as far as possible.
      var v = c - center;
      final maxR = R - s.height / 2 - 2;
      if (v.distance > maxR) v = v / v.distance * maxR;
      final x = clampSafe(
        center.dx + v.dx,
        s.width / 2 + 2,
        side - s.width / 2 - 2,
      );
      final y = clampSafe(
        center.dy + v.dy,
        s.height / 2 + 2,
        side - s.height / 2 - 2,
      );
      return Offset(x, y);
    }

    Rect rectOf(int i) => Rect.fromCenter(
      center: centres[i],
      width: sizes[i].width,
      height: sizes[i].height,
    );
    for (var i = 0; i < centres.length; i++) {
      centres[i] = clampIn(centres[i], sizes[i]);
    }
    // Gentle push-apart: overlapping words move away from each other.
    for (var pass = 0; pass < 200; pass++) {
      var moved = false;
      for (var i = 0; i < centres.length; i++) {
        for (var j = i + 1; j < centres.length; j++) {
          final a = rectOf(i).inflate(2);
          final b = rectOf(j);
          if (!a.overlaps(b)) continue;
          var d = centres[j] - centres[i];
          if (d.distance < 0.01) d = const Offset(0, 1);
          final step = d / d.distance * 1.5;
          centres[i] = clampIn(centres[i] - step, sizes[i]);
          centres[j] = clampIn(centres[j] + step, sizes[j]);
          moved = true;
        }
        for (final o in obstacles) {
          final a = rectOf(i);
          if (!a.overlaps(o)) continue;
          var d = centres[i] - o.center;
          if (d.distance < 0.01) d = const Offset(0, 1);
          centres[i] = clampIn(centres[i] + d / d.distance * 1.5, sizes[i]);
          moved = true;
        }
      }
      if (!moved) break;
    }
    for (var i = 0; i < model.points.length; i++) {
      final p = model.points[i];
      _pills.add(
        _Pill(
          p,
          PlacedLabel(
            lines: [labels[i]],
            anchor: centres[i],
            rotation: 0,
            fontSize: pillFont,
          ),
          RRect.fromRectAndRadius(
            rectOf(i),
            Radius.circular(sizes[i].height / 2),
          ),
          model.quadrantAt(p.valence, p.arousal),
        ),
      );
    }
  }

  Color _quadrantTint(int q, Tier tier) =>
      Palette.fill(model.quadrants[q].hue, tier, brightness);

  @override
  void paintBase(Canvas canvas, double zoomStep) {
    final R = radius;
    final rect = Rect.fromCircle(center: center, radius: R);
    // Hue sweeps smoothly round the circle (canvas angles start at 3 o'clock):
    // top-right = quadrant 0, bottom-right = 1, bottom-left = 2, top-left = 3.
    final q0 = _quadrantTint(0, Tier.medium);
    final q1 = _quadrantTint(1, Tier.medium);
    final q2 = _quadrantTint(2, Tier.medium);
    final q3 = _quadrantTint(3, Tier.medium);
    canvas.drawCircle(
      center,
      R,
      Paint()
        ..shader = SweepGradient(
          colors: [
            Color.lerp(q0, q1, 0.5)!,
            q1,
            q2,
            q3,
            q0,
            Color.lerp(q0, q1, 0.5)!,
          ],
          stops: const [0, 0.125, 0.375, 0.625, 0.875, 1],
        ).createShader(rect),
    );
    // Calm centre: intensity grows toward the rim.
    canvas.drawCircle(
      center,
      R,
      Paint()
        ..shader = RadialGradient(
          colors: [
            colors.background.withValues(alpha: 0.92),
            colors.background.withValues(alpha: 0.35),
            colors.background.withValues(alpha: 0),
          ],
          stops: const [0, 0.55, 1],
        ).createShader(rect),
    );
    final axis = Paint()
      ..color = colors.inkMuted.withValues(alpha: 0.35)
      ..strokeWidth = 1;
    canvas.drawLine(center.translate(0, -R), center.translate(0, R), axis);
    canvas.drawLine(center.translate(-R, 0), center.translate(R, 0), axis);
    if (zoomStep <= 0) return; // thumbnail: colour only
    for (final l in _axisLabels) {
      l.paint(canvas);
    }
    final fill = Paint()..color = colors.surface.withValues(alpha: 0.94);
    final line = Paint()
      ..color = colors.outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final p in _pills) {
      canvas.drawRRect(p.rect, fill);
      canvas.drawRRect(p.rect, line);
      p.label.paint(canvas);
    }
  }

  @override
  WheelHit? hitTest(Offset p) {
    final d = p - center;
    if (d.distance > radius + 6) return null;
    // The word under the finger; a near miss counts (48 dp target).
    _Pill? best;
    var bestDistance = double.infinity;
    for (final pill in _pills) {
      final r = pill.rect.outerRect;
      final target = r.inflate(math.max(0, (48 - r.height) / 2));
      if (!target.contains(p)) continue;
      final distance = (r.center - p).distance;
      if (distance < bestDistance) {
        best = pill;
        bestDistance = distance;
      }
    }
    if (best == null) return null;
    final v = (d.dx / radius).clamp(-1.0, 1.0);
    final a = (-d.dy / radius).clamp(-1.0, 1.0);
    return CircumplexHit(
      model.quadrants[best.quadrant].id,
      valence: v,
      arousal: a,
      position: p,
      feelingId: best.placed.feeling.id,
    );
  }

  @override
  late final List<SemanticTarget> semanticTargets = [
    for (var i = 0; i < _pills.length; i++)
      SemanticTarget(
        rect: Rect.fromCenter(
          center: _pills[i].rect.center,
          width: math.max(48, _pills[i].rect.width),
          height: 48,
        ),
        label: sentenceCase(_pills[i].placed.feeling.word.of(form)),
        familyId: model.quadrants[_pills[i].quadrant].id,
        hit: CircumplexHit(
          model.quadrants[_pills[i].quadrant].id,
          valence: _pills[i].placed.valence,
          arousal: _pills[i].placed.arousal,
          position: _pills[i].rect.center,
          feelingId: _pills[i].placed.feeling.id,
        ),
        order: i,
      ),
  ];

  /// Test hooks.
  List<Rect> get pillRects => [for (final p in _pills) p.rect.outerRect];

  @override
  void dispose() {
    for (final p in _pills) {
      p.label.dispose();
    }
    for (final l in _axisLabels) {
      l.dispose();
    }
  }
}
