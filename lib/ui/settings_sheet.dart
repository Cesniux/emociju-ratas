import 'package:flutter/material.dart';

import '../copy/strings.dart';
import '../data/models.dart';
import '../state/app_scope.dart';
import '../theme/motion.dart';
import '../theme/tokens.dart';

Future<void> showSettings(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    sheetAnimationStyle: Motion.of(context).sheet,
    builder: (_) => const SettingsSheet(),
  );
}

/// A drawer with the two quiet choices: how you speak of yourself and the
/// colours. Both are remembered.
class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.of(context).settings;
    final text = Theme.of(context).textTheme;
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) => SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          Space.l,
          0,
          Space.l,
          Space.xl + MediaQuery.paddingOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(S.settings, style: text.titleLarge),
            ),
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
            const SizedBox(height: Space.xl),
            Text(S.themeTitle, style: text.titleSmall),
            const SizedBox(height: Space.s),
            SegmentedButton<ThemeMode>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text(S.themeLight),
                ),
                ButtonSegment(value: ThemeMode.dark, label: Text(S.themeDark)),
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text(S.themeSystem),
                ),
              ],
              selected: {settings.themeMode},
              onSelectionChanged: (s) => settings.setThemeMode(s.first),
            ),
          ],
        ),
      ),
    );
  }
}
