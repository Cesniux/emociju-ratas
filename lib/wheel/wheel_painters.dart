import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../copy/strings.dart';
import '../state/selection.dart';
import 'wheel_layout.dart';

/// Segments and readable labels. Repaints only when the layout or the zoom
/// step changes; screen-reader nodes rebuild when chosen counts change.
class WheelBasePainter extends CustomPainter {
  WheelBasePainter({
    required this.layout,
    required this.zoomStep,
    required this.chosenCounts,
    this.onTarget,
  });

  final WheelLayout layout;
  final double zoomStep;
  final Map<String, int> chosenCounts;
  final ValueChanged<WheelHit>? onTarget;

  @override
  void paint(Canvas canvas, Size size) => layout.paintBase(canvas, zoomStep);

  @override
  bool shouldRepaint(WheelBasePainter oldDelegate) =>
      oldDelegate.layout != layout || oldDelegate.zoomStep != zoomStep;

  @override
  SemanticsBuilderCallback? get semanticsBuilder {
    if (onTarget == null) return null;
    return (size) => [
          for (final t in layout.semanticTargets)
            CustomPainterSemantics(
              key: ValueKey('${t.familyId}|${t.label}'),
              rect: t.rect,
              properties: SemanticsProperties(
                label: t.label,
                hint: S.familyHint,
                value: (chosenCounts[t.familyId] ?? 0) > 0
                    ? S.chosenValue(chosenCounts[t.familyId]!)
                    : null,
                button: true,
                textDirection: TextDirection.ltr,
                sortKey: OrdinalSortKey(t.order.toDouble()),
                onTap: () => onTarget!(t.hit),
              ),
            ),
        ];
  }

  @override
  bool shouldRebuildSemantics(WheelBasePainter oldDelegate) =>
      oldDelegate.layout != layout ||
      !mapEquals(oldDelegate.chosenCounts, chosenCounts);
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
