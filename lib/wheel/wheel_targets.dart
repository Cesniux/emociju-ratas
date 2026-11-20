import 'package:flutter/rendering.dart' show OrdinalSortKey;
import 'package:flutter/widgets.dart';

import 'wheel_layout.dart';

/// The painted words, read aloud: one screen-reader node per word, in
/// clockwise order. The wheel is for looking, so nothing here is a button.
class WheelTargets extends StatelessWidget {
  const WheelTargets({super.key, required this.layout});

  final WheelLayout layout;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        for (final t in layout.semanticTargets)
          Positioned.fromRect(
            rect: t.rect,
            child: Semantics(
              label: t.label,
              sortKey: OrdinalSortKey(t.order.toDouble()),
              child: const SizedBox.expand(),
            ),
          ),
      ],
    );
  }
}
