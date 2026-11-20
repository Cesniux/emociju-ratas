import 'package:flutter/rendering.dart';

import 'wheel_layout.dart';

/// Segments and labels. Repaints only when the layout changes. Screen-reader
/// access lives in [WheelTargets].
class WheelBasePainter extends CustomPainter {
  WheelBasePainter({required this.layout, required this.zoomStep});

  final WheelLayout layout;
  final double zoomStep;

  @override
  void paint(Canvas canvas, Size size) => layout.paintBase(canvas, zoomStep);

  @override
  bool shouldRepaint(WheelBasePainter oldDelegate) =>
      oldDelegate.layout != layout || oldDelegate.zoomStep != zoomStep;
}
