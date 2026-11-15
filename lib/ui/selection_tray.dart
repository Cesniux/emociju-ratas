import 'package:flutter/material.dart';

import '../copy/strings.dart';
import '../state/app_scope.dart';
import '../theme/colors.dart';
import '../theme/palette.dart';
import '../theme/tokens.dart';
import '../wheel/labels.dart';

/// Chosen words at the bottom of Home. Fixed height, so the wheel above
/// never jumps when words come and go.
class SelectionTray extends StatelessWidget {
  const SelectionTray({super.key});

  void _clear(BuildContext context) {
    final selection = AppScope.of(context).selection;
    final removed = selection.clear();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text(S.cleared),
          action: SnackBarAction(
            label: S.undo,
            onPressed: () => selection.restore(removed),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final c = AppColors.of(context);
    final text = Theme.of(context).textTheme;
    return ListenableBuilder(
      listenable: Listenable.merge([scope.selection, scope.settings]),
      builder: (context, _) {
        final items = scope.selection.items;
        final form = scope.settings.wordForm;
        return Semantics(
          container: true,
          label: S.trayTitle,
          child: Container(
            constraints: const BoxConstraints(minHeight: Sizes.trayHeight),
            margin: const EdgeInsets.fromLTRB(
              Space.m,
              Space.xs,
              Space.m,
              Space.m,
            ),
            padding: const EdgeInsets.symmetric(horizontal: Space.s),
            decoration: BoxDecoration(
              color: c.sunken,
              borderRadius: BorderRadius.circular(Radii.card + 4),
            ),
            child: items.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(Space.m),
                    child: Center(
                      child: Text(
                        S.trayEmpty,
                        textAlign: TextAlign.center,
                        style: text.bodyMedium?.copyWith(color: c.inkMuted),
                      ),
                    ),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: Sizes.trayHeight,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(
                              horizontal: Space.xs,
                              vertical: Space.m,
                            ),
                            itemCount: items.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: Space.s),
                            itemBuilder: (context, i) {
                              final w = items[i];
                              final label = sentenceCase(w.word.of(form));
                              return Semantics(
                                button: true,
                                label: S.remove(label),
                                excludeSemantics: true,
                                onTap: () => scope.selection.remove(w.key),
                                child: Material(
                                  color: Palette.fill(
                                    w.hue,
                                    Tier.strong,
                                    c.brightness,
                                  ),
                                  shape: const StadiumBorder(),
                                  child: InkWell(
                                    customBorder: const StadiumBorder(),
                                    onTap: () => scope.selection.remove(w.key),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        left: Space.l,
                                        right: Space.s,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            label,
                                            style: text.labelLarge?.copyWith(
                                              color: c.ink,
                                            ),
                                          ),
                                          const SizedBox(width: Space.xs),
                                          Icon(
                                            Icons.close_rounded,
                                            size: 18,
                                            color: c.ink,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _clear(context),
                        child: const Text(S.clear),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
