import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/models.dart';
import '../theme/colors.dart';
import '../theme/palette.dart';

/// The app's own mark: eight soft petals in the feeling colours, the same
/// flower as the launcher icon (design/generate.mjs). Used as the button that
/// opens the choice of wheels.
class FlowerIcon extends StatelessWidget {
  const FlowerIcon({super.key, this.size = 36});

  final double size;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return CustomPaint(size: Size.square(size), painter: _FlowerPainter(c));
  }
}

class _FlowerPainter extends CustomPainter {
  _FlowerPainter(this.c);

  final AppColors c;

  /// Plutchik's order clockwise from 12, as in the launcher icon.
  static const _hues = [
    FamilyHue.yellow,
    FamilyHue.sage,
    FamilyHue.green,
    FamilyHue.sky,
    FamilyHue.blue,
    FamilyHue.mauve,
    FamilyHue.clay,
    FamilyHue.orange,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final dark = c.brightness == Brightness.dark;
    // The launcher icon's petal on a 1024 canvas; its tip reaches r 417.
    final s = size.shortestSide / 2 / 417;
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(s);
    canvas.translate(-512, -512);
    final petal = Path()
      ..moveTo(512, 470)
      ..cubicTo(396, 430, 402, 175, 512, 95)
      ..cubicTo(622, 175, 628, 430, 512, 470)
      ..close();
    final edge = Paint()
      ..color = c.surface
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30
      ..strokeJoin = StrokeJoin.round;
    for (var i = 0; i < _hues.length; i++) {
      var colour = Palette.fill(_hues[i], Tier.strong, Brightness.light);
      // At night the petals stay soft: a little of the evening mixed in.
      if (dark) colour = Color.lerp(colour, c.surface, 0.18)!;
      canvas.save();
      canvas.translate(512, 512);
      canvas.rotate(i * math.pi / 4);
      canvas.translate(-512, -512);
      canvas.drawPath(petal, Paint()..color = colour);
      canvas.drawPath(petal, edge);
      canvas.restore();
    }
    canvas.drawCircle(const Offset(512, 512), 120, Paint()..color = c.surface);
    canvas.drawCircle(
      const Offset(512, 512),
      120,
      Paint()
        ..color = c.outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 22,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_FlowerPainter oldDelegate) => oldDelegate.c != c;
}
