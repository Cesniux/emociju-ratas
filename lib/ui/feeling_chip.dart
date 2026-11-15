import 'package:flutter/material.dart';

import '../data/models.dart';
import '../theme/colors.dart';
import '../theme/motion.dart';
import '../theme/palette.dart';
import '../theme/tokens.dart';
import '../wheel/labels.dart';

/// A feeling word to choose: large, horizontal, at least 48 dp tall.
class FeelingChip extends StatelessWidget {
  const FeelingChip({
    super.key,
    required this.word,
    required this.hue,
    required this.selected,
    required this.onTap,
    this.emphasis = false,
    this.caption,
  });

  final String word;
  final FamilyHue hue;
  final bool selected;
  final VoidCallback onTap;

  /// Bigger, bolder: a middle-ring word heading its card.
  final bool emphasis;

  /// Small second line, e.g. "džiaugsmas + pasitikėjimas".
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final text = Theme.of(context).textTheme;
    final fill = selected
        ? Palette.fill(hue, Tier.strong, c.brightness)
        : (emphasis ? Palette.fill(hue, Tier.soft, c.brightness) : c.surface);
    final label = sentenceCase(word);
    return MergeSemantics(
      child: Semantics(
        button: true,
        selected: selected,
        child: AnimatedContainer(
          duration: Motion.of(context).short,
          curve: Motion.ease,
          constraints: const BoxConstraints(minHeight: Sizes.minTarget),
          decoration: ShapeDecoration(
            color: fill,
            shape: StadiumBorder(
              side: BorderSide(
                color: selected ? c.ink : c.outline,
                width: selected ? 2 : 1,
              ),
            ),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              customBorder: const StadiumBorder(),
              onTap: onTap,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: emphasis ? Space.l + 2 : Space.l,
                  vertical: Space.s + 2,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSwitcher(
                      duration: Motion.of(context).short,
                      child: selected
                          ? Padding(
                              key: const ValueKey('check'),
                              padding: const EdgeInsets.only(right: Space.s),
                              child: Icon(
                                Icons.check_rounded,
                                size: 20,
                                color: c.ink,
                              ),
                            )
                          : const SizedBox(key: ValueKey('none')),
                    ),
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style:
                                (emphasis ? text.titleSmall : text.labelLarge)
                                    ?.copyWith(color: c.ink),
                          ),
                          if (caption != null)
                            Text(
                              caption!,
                              style: text.bodySmall?.copyWith(
                                color: c.inkMuted,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
