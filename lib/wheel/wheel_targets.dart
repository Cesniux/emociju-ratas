import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show OrdinalSortKey;
import 'package:flutter/services.dart';

import '../copy/strings.dart';
import '../data/models.dart';
import '../state/selection.dart';
import '../theme/colors.dart';
import 'wheel_layout.dart';

/// One real, focusable button per family (petal, dyad, quadrant) laid over
/// the painted wheel: screen readers announce it, Tab reaches it in
/// clockwise order, Enter or Space opens it, and focus shows an ink ring
/// (WCAG 2.1.1, 2.4.3, 2.4.7, 4.1.2). Pointer taps pass through to the wheel,
/// so a finger still lands on the exact word.
class WheelTargets extends StatelessWidget {
  const WheelTargets({
    super.key,
    required this.layout,
    required this.wheel,
    required this.selection,
    required this.onHit,
  });

  final WheelLayout layout;
  final WheelModel wheel;
  final Selection selection;
  final ValueChanged<WheelHit> onHit;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: selection,
      builder: (context, _) => FocusTraversalGroup(
        policy: OrderedTraversalPolicy(),
        child: Stack(
          children: [
            for (final t in layout.semanticTargets)
              Positioned.fromRect(
                rect: t.rect,
                child: FocusTraversalOrder(
                  order: NumericFocusOrder(t.order.toDouble()),
                  child: _Target(
                    target: t,
                    chosen: selection.countIn(
                      wheel.feelings.where((f) => f.familyId == t.familyId),
                    ),
                    onActivate: () => onHit(t.hit),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Target extends StatefulWidget {
  const _Target({
    required this.target,
    required this.chosen,
    required this.onActivate,
  });

  final SemanticTarget target;
  final int chosen;
  final VoidCallback onActivate;

  @override
  State<_Target> createState() => _TargetState();
}

class _TargetState extends State<_Target> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Focus(
      onFocusChange: (f) => setState(() => _focused = f),
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.numpadEnter ||
                event.logicalKey == LogicalKeyboardKey.space)) {
          widget.onActivate();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Semantics(
        button: true,
        label: widget.target.label,
        hint: S.familyHint,
        value: widget.chosen > 0 ? S.chosenValue(widget.chosen) : null,
        sortKey: OrdinalSortKey(widget.target.order.toDouble()),
        onTap: widget.onActivate,
        child: IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: _focused
                  ? Border.all(color: c.ink, width: 3)
                  : const Border.fromBorderSide(BorderSide.none),
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}
