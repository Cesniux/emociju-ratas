import 'package:flutter/rendering.dart';

import '../state/selection.dart';
import 'wheel_layout.dart';

/// Segments and readable labels. Repaints only when the layout or the zoom
/// step changes. Screen-reader and keyboard access live in [WheelTargets].
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

/// Chosen words, hover and the probe dot, drawn over the cached base.
class WheelHighlightPainter extends CustomPainter {
  WheelHighlightPainter({
    required this.layout,
    required this.selection,
    required this.zoomStep,
    this.hoverFamilyId,
    this.probe,
  }) : super(repaint: selection);

  final WheelLayout layout;
  final Selection selection;
  final double zoomStep;
  final String? hoverFamilyId;
  final Offset? probe;

  @override
  void paint(Canvas canvas, Size size) => layout.paintHighlights(
    canvas,
    chosen: selection.keys,
    zoomStep: zoomStep,
    hoverFamilyId: hoverFamilyId,
    probe: probe,
  );

  @override
  bool shouldRepaint(WheelHighlightPainter oldDelegate) =>
      oldDelegate.layout != layout ||
      oldDelegate.zoomStep != zoomStep ||
      oldDelegate.hoverFamilyId != hoverFamilyId ||
      oldDelegate.probe != probe ||
      oldDelegate.selection != selection;
}
