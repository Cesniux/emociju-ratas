import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'emotion_data.dart';

/// Layout is derived once from the static data.
final WheelLayout _wheelLayout = WheelLayout.build(emotionWheelData);

/// Warm cream "paper" the wheel is painted on.
const Color kPaperColor = Color(0xFFF4EAD6);

/// Code-drawn, zoom-friendly emotion wheel with a warm watercolour finish.
///
/// Draws the whole wheel as vector graphics at a large fixed logical size and
/// uses a [FittedBox] so it scales to fit whatever space it is given. Wrap it in
/// an [InteractiveViewer] for pan/zoom.
class EmotionWheelView extends StatelessWidget {
  const EmotionWheelView({super.key, this.size = 2000});

  /// Logical size the wheel is painted at before being fitted to its parent.
  final double size;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: EmotionWheelPainter(
            _wheelLayout,
            fontFamily: DefaultTextStyle.of(context).style.fontFamily,
          ),
        ),
      ),
    );
  }
}

/// A small, label-free render of the wheel, for use as a picker thumbnail.
class EmotionWheelThumbnail extends StatelessWidget {
  const EmotionWheelThumbnail({super.key, this.size = 56});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: EmotionWheelPainter(_wheelLayout, detail: false),
    );
  }
}

/// Paints the concentric emotion wheel with a soft, warm watercolour look:
/// per-segment gradient washes, gentle blooms, a fine grain, soft cream
/// dividers, a unifying warm glaze, and rotated labels.
class EmotionWheelPainter extends CustomPainter {
  EmotionWheelPainter(this.layout, {this.fontFamily, this.detail = true});

  final WheelLayout layout;

  /// Optional font family for the labels (defaults to the platform font).
  final String? fontFamily;

  /// When false, skips labels, blooms and grain — used for tiny thumbnails
  /// where that detail is invisible (and the text would be illegible noise).
  final bool detail;

  static const Color _dividerColor = Color(0xFFF7EEDC);
  static const Color _textColor = Color(0xFF4A3B2F);

  /// Warm pigment all colours are nudged toward, for a cosy unified feel.
  static const Color _warmTint = Color(0xFFE6A85C);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final outerRadius = size.shortestSide / 2;

    // Warm paper background (so the gaps and centre read as paper, not white).
    canvas.drawRect(Offset.zero & size, Paint()..color = kPaperColor);

    // 1) Per-segment watercolour washes (gradient + bloom + grain).
    for (var i = 0; i < layout.segments.length; i++) {
      _paintWash(canvas, center, outerRadius, layout.segments[i], i);
    }

    // 2) A gentle warm glaze over the whole disc to unify the palette.
    canvas.save();
    canvas.clipPath(
      Path()..addOval(Rect.fromCircle(center: center, radius: outerRadius)),
    );
    canvas.drawColor(const Color(0x17F2C57E), BlendMode.softLight);
    canvas.restore();

    // 3) Soft cream dividers (thin, low-contrast — no harsh white lines).
    final dividerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = _dividerColor
      ..strokeWidth = outerRadius * 0.0045
      ..isAntiAlias = true;
    for (final segment in layout.segments) {
      canvas.drawPath(
        _annularSector(center, outerRadius, segment),
        dividerPaint,
      );
    }

    // 4) Warm paper centre.
    canvas.drawCircle(
      center,
      layout.holeRadiusFraction * outerRadius,
      Paint()
        ..color = kPaperColor
        ..isAntiAlias = true,
    );

    // 5) Labels last, so glyphs always sit on top.
    if (detail) {
      for (final segment in layout.segments) {
        if (segment.ring == 0) {
          _drawCurvedLabel(canvas, center, outerRadius, segment);
        } else {
          _drawLabel(canvas, center, outerRadius, segment);
        }
      }
    }
  }

  /// Fills one segment with a soft radial wash, then adds an organic bloom and
  /// a fine grain clipped to the segment.
  void _paintWash(
    Canvas canvas,
    Offset center,
    double outerRadius,
    WheelSegment seg,
    int index,
  ) {
    final rInner = seg.band.inner * outerRadius;
    final rOuter = seg.band.outer * outerRadius;
    final path = _annularSector(center, outerRadius, seg);
    final (innerColor, outerColor) = _washColors(seg);

    // Radial gradient centred on the wheel: lighter inside, a touch deeper out.
    canvas.drawPath(
      path,
      Paint()
        ..isAntiAlias = true
        ..shader = ui.Gradient.radial(center, rOuter, [
          innerColor,
          outerColor,
        ], [(rInner / rOuter).clamp(0.0, 1.0), 1.0]),
    );

    // Blooms and grain are detail-only (skipped for tiny thumbnails).
    if (!detail) return;

    canvas.save();
    canvas.clipPath(path);
    final rnd = math.Random(index * 9277 + 17);

    // A single soft bloom (radial gradient → transparent, no blur filter so it
    // stays cheap to re-rasterise while zooming).
    final bloomAngle =
        seg.startAngle + seg.sweepAngle * (0.25 + rnd.nextDouble() * 0.5);
    final bloomRadius =
        rInner + (rOuter - rInner) * (0.25 + rnd.nextDouble() * 0.5);
    final bloomCenter =
        center +
        Offset(math.cos(bloomAngle), math.sin(bloomAngle)) * bloomRadius;
    final bloomSize = (rOuter - rInner) * 0.85;
    final bloomTone = rnd.nextBool()
        ? const Color(0xFFFFFFFF)
        : _shiftLightness(outerColor, -0.10);
    canvas.drawCircle(
      bloomCenter,
      bloomSize,
      Paint()
        ..shader = ui.Gradient.radial(bloomCenter, bloomSize, [
          bloomTone.withValues(alpha: 0.12),
          bloomTone.withValues(alpha: 0.0),
        ]),
    );

    // Fine grain — a sparse warm/light speckle for paper tooth.
    final area = 0.5 * seg.sweepAngle * (rOuter * rOuter - rInner * rInner);
    final dotCount = (area * 0.0004).round().clamp(0, 48);
    final darkDot = Paint()..color = const Color(0x0E5B4636);
    final lightDot = Paint()..color = const Color(0x12FFF6E6);
    for (var d = 0; d < dotCount; d++) {
      final a = seg.startAngle + rnd.nextDouble() * seg.sweepAngle;
      final rr = math.sqrt(
        rInner * rInner + rnd.nextDouble() * (rOuter * rOuter - rInner * rInner),
      );
      final p = center + Offset(math.cos(a), math.sin(a)) * rr;
      canvas.drawCircle(
        p,
        outerRadius * (0.0010 + rnd.nextDouble() * 0.0013),
        rnd.nextBool() ? darkDot : lightDot,
      );
    }
    canvas.restore();
  }

  Path _annularSector(Offset center, double outerRadius, WheelSegment seg) {
    final rInner = seg.band.inner * outerRadius;
    final rOuter = seg.band.outer * outerRadius;
    final start = seg.startAngle;
    final end = seg.startAngle + seg.sweepAngle;

    final outerRect = Rect.fromCircle(center: center, radius: rOuter);
    final innerRect = Rect.fromCircle(center: center, radius: rInner);

    return Path()
      ..moveTo(
        center.dx + rInner * math.cos(start),
        center.dy + rInner * math.sin(start),
      )
      ..lineTo(
        center.dx + rOuter * math.cos(start),
        center.dy + rOuter * math.sin(start),
      )
      ..arcTo(outerRect, start, seg.sweepAngle, false)
      ..lineTo(
        center.dx + rInner * math.cos(end),
        center.dy + rInner * math.sin(end),
      )
      ..arcTo(innerRect, end, -seg.sweepAngle, false)
      ..close();
  }

  /// Inner/outer wash colours for a segment: softened, warmed, lighter toward
  /// the outer rings, with a gentle per-segment lightness wobble.
  (Color, Color) _washColors(WheelSegment seg) {
    final hsl = HSLColor.fromColor(seg.color);
    final ringLift = switch (seg.ring) {
      0 => 0.05,
      1 => 0.11,
      _ => 0.16,
    };
    final wobble = math.sin(seg.shadeT * math.pi) * 0.04;
    final baseLightness = (hsl.lightness + ringLift + wobble).clamp(0.0, 0.95);
    final baseSaturation = (hsl.saturation * 0.86).clamp(0.0, 1.0);

    Color tone(double lightnessDelta, double saturationScale) {
      final c = HSLColor.fromAHSL(
        1.0,
        hsl.hue,
        (baseSaturation * saturationScale).clamp(0.0, 1.0),
        (baseLightness + lightnessDelta).clamp(0.0, 0.97),
      ).toColor();
      // Nudge every colour toward warm so the whole wheel feels cosy, but
      // keep enough pigment that each emotion stays distinguishable.
      return Color.lerp(c, _warmTint, 0.05)!;
    }

    return (tone(0.06, 0.85), tone(-0.05, 1.0));
  }

  Color _shiftLightness(Color color, double delta) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + delta).clamp(0.0, 1.0)).toColor();
  }

  /// Draws a core (first-ring) label as curved text that follows the ring's
  /// arc, kept upright: letter tops point outward on the top half and inward on
  /// the bottom half, so no word is ever upside down.
  void _drawCurvedLabel(
    Canvas canvas,
    Offset center,
    double outerRadius,
    WheelSegment seg,
  ) {
    if (seg.label.isEmpty) return;

    final rInner = seg.band.inner * outerRadius;
    final rOuter = seg.band.outer * outerRadius;
    final bandThickness = rOuter - rInner;
    final radius = rInner + bandThickness * 0.50; // centred in the ring
    final midAngle = seg.startAngle + seg.sweepAngle / 2;
    final topHalf = math.sin(midAngle) < 0;

    final chars = seg.label.runes.map(String.fromCharCode).toList();
    final availableArc = seg.sweepAngle * 0.92;
    final maxHeight = bandThickness * 0.6;
    final minFont = outerRadius * 0.013;

    List<TextPainter> build(double fontSize) {
      final style = TextStyle(
        color: _textColor,
        fontFamily: fontFamily,
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        height: 1.0,
      );
      return [
        for (final c in chars)
          TextPainter(
            text: TextSpan(text: c, style: style),
            textDirection: TextDirection.ltr,
          )..layout(),
      ];
    }

    // Shrink the font until the whole word fits the wedge's arc and ring height.
    var fontSize = outerRadius * 0.046;
    var painters = build(fontSize);
    double totalWidth() => painters.fold(0.0, (sum, p) => sum + p.width);
    double tallest() => painters.fold(0.0, (sum, p) => math.max(sum, p.height));
    for (var i = 0; i < 10; i++) {
      final arc = totalWidth() / radius;
      final overArc = arc > availableArc;
      final overHeight = tallest() > maxHeight;
      if ((!overArc && !overHeight) || fontSize <= minFont) break;
      final scale = math.min(
        overArc ? availableArc / arc : 1.0,
        overHeight ? maxHeight / tallest() : 1.0,
      );
      fontSize = math.max(minFont, fontSize * scale * 0.98);
      painters = build(fontSize);
    }

    // Lay the characters out around the arc, centred on the wedge.
    final totalAngle = totalWidth() / radius;
    var angle = topHalf ? midAngle - totalAngle / 2 : midAngle + totalAngle / 2;
    for (final tp in painters) {
      final charArc = tp.width / radius;
      final charMid = topHalf ? angle + charArc / 2 : angle - charArc / 2;
      canvas.save();
      canvas.translate(
        center.dx + radius * math.cos(charMid),
        center.dy + radius * math.sin(charMid),
      );
      canvas.rotate(topHalf ? charMid + math.pi / 2 : charMid - math.pi / 2);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
      angle = topHalf ? angle + charArc : angle - charArc;
    }
  }

  void _drawLabel(
    Canvas canvas,
    Offset center,
    double outerRadius,
    WheelSegment seg,
  ) {
    if (seg.label.isEmpty) return;

    final rInner = seg.band.inner * outerRadius;
    final rOuter = seg.band.outer * outerRadius;
    final bandThickness = rOuter - rInner;
    final midAngle = seg.startAngle + seg.sweepAngle / 2;

    // Core labels run along the arc (tangential); middle/outer run radially.
    final radial = seg.ring != 0;
    // Core labels sit centred in the core ring (kept off the outer edge).
    final labelRadius = radial
        ? (rInner + rOuter) / 2
        : rInner + bandThickness * 0.50;
    final arcThickness = seg.sweepAngle * labelRadius;

    final maxWidth = radial ? bandThickness * 0.94 : arcThickness * 0.95;
    final maxHeight = radial ? arcThickness * 0.92 : bandThickness * 0.62;

    final painter = _layoutText(seg, maxWidth, maxHeight, outerRadius);

    // Keep text upright. Radial labels flip per-section (using the core's
    // mid-angle) so a section straddling the top/bottom stays consistent and
    // never points the opposite way; tangential core labels flip on the bottom.
    final flip = radial
        ? math.cos(seg.coreMidAngle) < 0
        : math.sin(midAngle) > 0;
    final rotation =
        (radial ? midAngle : midAngle + math.pi / 2) + (flip ? math.pi : 0);

    canvas.save();
    canvas.translate(
      center.dx + labelRadius * math.cos(midAngle),
      center.dy + labelRadius * math.sin(midAngle),
    );
    canvas.rotate(rotation);
    painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
    canvas.restore();
  }

  /// Lays out the label as large as possible, shrinking only until it fits.
  TextPainter _layoutText(
    WheelSegment seg,
    double maxWidth,
    double maxHeight,
    double outerRadius,
  ) {
    final baseFont = switch (seg.ring) {
      0 => outerRadius * 0.046,
      1 => outerRadius * 0.032,
      _ => outerRadius * 0.028,
    };
    final minFont = outerRadius * 0.013;
    final weight = switch (seg.ring) {
      0 => FontWeight.w700,
      1 => FontWeight.w600,
      _ => FontWeight.w500,
    };

    TextPainter build(double fontSize) {
      return TextPainter(
        text: TextSpan(
          text: seg.label,
          style: TextStyle(
            color: _textColor,
            fontFamily: fontFamily,
            fontSize: fontSize,
            fontWeight: weight,
            letterSpacing: fontSize * 0.01,
            height: 1.0,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
        maxLines: 1,
      )..layout();
    }

    var fontSize = baseFont;
    var painter = build(fontSize);
    for (var i = 0; i < 24; i++) {
      final widthOver = painter.width > maxWidth;
      final heightOver = painter.height > maxHeight;
      if ((!widthOver && !heightOver) || fontSize <= minFont) break;
      final scale = math.min(
        widthOver ? maxWidth / painter.width : 1.0,
        heightOver ? maxHeight / painter.height : 1.0,
      );
      fontSize = math.max(minFont, fontSize * scale * 0.98);
      painter = build(fontSize);
    }
    return painter;
  }

  @override
  bool shouldRepaint(covariant EmotionWheelPainter oldDelegate) =>
      oldDelegate.layout != layout ||
      oldDelegate.fontFamily != fontFamily ||
      oldDelegate.detail != detail;
}
