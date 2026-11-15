import 'package:flutter/material.dart';

import '../copy/strings.dart';
import '../data/models.dart';
import '../data/wheels.dart';
import '../state/app_scope.dart';
import '../theme/colors.dart';
import '../theme/motion.dart';
import '../theme/tokens.dart';
import '../wheel/wheel_view.dart';

Future<void> showWheelMenu(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    sheetAnimationStyle: Motion.of(context).sheet,
    builder: (_) => const WheelMenuSheet(),
  );
}

/// Choose a wheel and the word form. Both are remembered.
class WheelMenuSheet extends StatelessWidget {
  const WheelMenuSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.of(context).settings;
    final c = AppColors.of(context);
    final text = Theme.of(context).textTheme;
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.94,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: EdgeInsets.fromLTRB(
            Space.xl,
            0,
            Space.xl,
            Space.xxl + MediaQuery.paddingOf(context).bottom,
          ),
          children: [
            Semantics(
              header: true,
              child: Text(S.wheelMenuTitle, style: text.titleLarge),
            ),
            const SizedBox(height: Space.l),
            for (final wheel in allWheels) ...[
              _WheelCard(
                wheel: wheel,
                selected: wheel.id == settings.wheelId,
                onTap: () {
                  settings.selectWheel(wheel.id);
                  Navigator.of(context).maybePop();
                },
              ),
              const SizedBox(height: Space.m),
            ],
            const SizedBox(height: Space.s),
            Divider(color: c.outline),
            const SizedBox(height: Space.l),
            Text(S.wordFormTitle, style: text.titleSmall),
            const SizedBox(height: Space.s),
            SegmentedButton<WordForm>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: WordForm.masculine,
                  label: Text(S.formMasculine),
                ),
                ButtonSegment(
                  value: WordForm.feminine,
                  label: Text(S.formFeminine),
                ),
              ],
              selected: {settings.wordForm},
              onSelectionChanged: (s) => settings.setWordForm(s.first),
            ),
          ],
        ),
      ),
    );
  }
}

class _WheelCard extends StatelessWidget {
  const _WheelCard({
    required this.wheel,
    required this.selected,
    required this.onTap,
  });

  final WheelModel wheel;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final text = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      selected: selected,
      label:
          '${wheel.title}. ${wheel.byline}. ${wheel.whenToUse}'
          '${selected ? ' ${S.selectedWheel}.' : ''}',
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: c.background,
        shape: RoundedRectangleBorder(
          borderRadius: Radii.cardAll,
          side: BorderSide(
            color: selected ? c.ink : c.outline,
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          customBorder: RoundedRectangleBorder(borderRadius: Radii.cardAll),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(Space.m),
            child: Row(
              children: [
                WheelThumbnail(wheel: wheel, size: 64),
                const SizedBox(width: Space.l),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(wheel.title, style: text.titleMedium),
                      const SizedBox(height: 2),
                      Text(wheel.byline, style: text.bodySmall),
                      const SizedBox(height: Space.xs),
                      Text(wheel.whenToUse, style: text.bodyMedium),
                    ],
                  ),
                ),
                if (selected) ...[
                  const SizedBox(width: Space.s),
                  Icon(Icons.check_circle_rounded, color: c.ink),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
