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
    pillFont = (R / 15).clamp(11.0, 15.0);
    final style = wheelLabelStyle(colors.ink, pillFont);
    for (final p in model.points) {
      final text = p.feeling.word.of(form);
      final label = layoutText(text, style);
      final w = label.width + 18;
      final h = label.height + 10;
      var c = polar(center, deg(p.clockDeg), p.radius * R * 0.9);
      c = Offset(
        c.dx.clamp(w / 2 + 2, side - w / 2 - 2),
        c.dy.clamp(h / 2 + 2, side - h / 2 - 2),
      );
      _pills.add(
        _Pill(
          p,
          PlacedLabel(
            lines: [label],
            anchor: c,
            rotation: 0,
            fontSize: pillFont,
          ),
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: c, width: w, height: h),
            Radius.circular(h / 2),
          ),
          model.quadrantAt(p.valence, p.arousal),
        ),
      );
    }
    final axisStyle = wheelLabelStyle(
      colors.inkMuted,
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
  void paintHighlights(
    Canvas canvas, {
    required Set<String> chosen,
    required double zoomStep,
    String? hoverFamilyId,
    Offset? probe,
  }) {
    if (probe != null) {
      canvas.drawCircle(
        probe,
        14,
        Paint()..color = colors.ink.withValues(alpha: 0.12),
      );
      canvas.drawCircle(
        probe,
        9,
        Paint()
          ..color = colors.ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      canvas.drawCircle(probe, 3.5, Paint()..color = colors.ink);
    }
    for (final p in _pills) {
      if (!chosen.contains(p.placed.feeling.key)) continue;
      canvas.drawRRect(
        p.rect,
        Paint()..color = _quadrantTint(p.quadrant, Tier.strong),
      );
      canvas.drawRRect(
        p.rect,
        Paint()
          ..color = colors.ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      p.label.paint(canvas);
    }
  }

  @override
  WheelHit? hitTest(Offset p) {
    final d = p - center;
    if (d.distance > radius + 6) return null;
    final v = (d.dx / radius).clamp(-1.0, 1.0);
    final a = (-d.dy / radius).clamp(-1.0, 1.0);
    final q = model.quadrantAt(v, a);
    return CircumplexHit(
      model.quadrants[q].id,
      valence: v,
      arousal: a,
      position: p,
    );
  }

  @override
  late final List<SemanticTarget> semanticTargets = [
    for (var q = 0; q < 4; q++)
      () {
        final theta = deg(45 + q * 90);
        final point = polar(center, theta, radius * 0.55);
        return SemanticTarget(
          rect: Rect.fromCenter(center: point, width: 64, height: 64),
          label: sentenceCase(model.quadrants[q].name.of(form)),
          familyId: model.quadrants[q].id,
          hit: CircumplexHit(
            model.quadrants[q].id,
            valence: (point.dx - center.dx) / radius,
            arousal: (center.dy - point.dy) / radius,
            position: point,
          ),
          order: q,
        );
      }(),
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
