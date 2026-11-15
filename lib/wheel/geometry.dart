import 'dart:math' as math;
import 'dart:ui';

/// Full turn.
const double tau = math.pi * 2;

/// Clock angles: 0 at 12 o'clock, increasing clockwise, in radians.
double deg(double degrees) => degrees * math.pi / 180;

/// Point at clock angle [theta] and radius [r] around [center].
Offset polar(Offset center, double theta, double r) =>
    center + Offset(r * math.sin(theta), -r * math.cos(theta));

/// Clock angle of [p] around [center], in [0, 2π).
double clockAngle(Offset center, Offset p) {
  final d = p - center;
  final a = math.atan2(d.dx, -d.dy);
  return a < 0 ? a + tau : a;
}

/// [a] wrapped into [0, 2π).
double normalize(double a) {
  final r = a % tau;
  return r < 0 ? r + tau : r;
}

/// True when clock angle [a] lies in [start, start + sweep).
bool angleInSweep(double a, double start, double sweep) =>
    normalize(a - start) < sweep;

/// Canvas rotation for clock angle [theta] (the canvas measures from
/// 3 o'clock).
double canvasAngle(double theta) => theta - math.pi / 2;

/// Rounded annular sector with a constant-width gap to its neighbours.
///
/// Fill this path *and* stroke it with width `2 * corner` and round joins in
/// the same colour: the stroke grows the inset shape back out by [corner],
/// which gives exact rounded corners.
Path sectorPath(
  Offset c,
  double r0,
  double r1,
  double start,
  double sweep, {
  double gap = 2,
  double corner = 3,
}) {
  var cr = corner;
  // Shrink the corner radius for tiny segments.
  cr = math.min(cr, (r1 - r0) / 2 - 0.5);
  final arcAtInner = r0 * sweep;
  cr = math.min(cr, arcAtInner / 2 - gap);
  if (cr < 0) cr = 0;

  final d = gap / 2 + cr;
  // Inset radially too, so neighbouring rings keep the same gap.
  final ri = r0 + cr + gap / 2;
  final ro = r1 - cr - gap / 2;
  if (ro <= ri || sweep <= 0) return Path();

  double offsetAt(double r) => r <= d ? sweep / 2 : math.asin(d / r);
  final oi = offsetAt(ri);
  final oo = offsetAt(ro);
  final innerSweep = sweep - 2 * oi;
  final outerSweep = sweep - 2 * oo;
  if (outerSweep <= 0) return Path();

  final path = Path()
    ..moveTo(polar(c, start + oi, ri).dx, polar(c, start + oi, ri).dy);
  final p1 = polar(c, start + oo, ro);
  path.lineTo(p1.dx, p1.dy);
  path.arcTo(
    Rect.fromCircle(center: c, radius: ro),
    canvasAngle(start + oo),
    outerSweep,
    false,
  );
  if (innerSweep > 0) {
    final p2 = polar(c, start + sweep - oi, ri);
    path.lineTo(p2.dx, p2.dy);
    path.arcTo(
      Rect.fromCircle(center: c, radius: ri),
      canvasAngle(start + sweep - oi),
      -innerSweep,
      false,
    );
  } else {
    final tip = polar(c, start + sweep / 2, math.max(ri, d));
    path.lineTo(tip.dx, tip.dy);
  }
  path.close();
  return path;
}

/// Paints [path] as a rounded shape (see [sectorPath]).
void paintRounded(Canvas canvas, Path path, Color color, double corner) {
  final fill = Paint()
    ..color = color
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;
  canvas.drawPath(path, fill);
  if (corner > 0) {
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = corner * 2
        ..strokeJoin = StrokeJoin.round
        ..isAntiAlias = true,
    );
  }
}

/// Paints an ink outline [width] wide around a rounded shape.
void paintRoundedOutline(
  Canvas canvas,
  Path path,
  Color color,
  double corner,
  double width,
) {
  canvas.drawPath(
    path,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = corner * 2 + width * 2
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true,
  );
}

/// Like num.clamp, but never throws when [lo] > [hi] (tiny thumbnails):
/// the value then sits in the middle.
double clampSafe(double value, double lo, double hi) =>
    lo > hi ? (lo + hi) / 2 : value.clamp(lo, hi).toDouble();
