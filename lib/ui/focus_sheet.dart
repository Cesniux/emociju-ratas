import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../copy/strings.dart';
import '../data/models.dart';
import '../state/app_scope.dart';
import '../theme/colors.dart';
import '../theme/motion.dart';
import '../theme/palette.dart';
import '../theme/tokens.dart';
import '../wheel/wheel_layout.dart';
import 'feeling_chip.dart';
import 'focus_content.dart';

/// Opens the words of the tapped family in a calm sheet.
Future<void> showFocusSheet(
  BuildContext context,
  WheelModel wheel,
  WheelHit hit,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    sheetAnimationStyle: Motion.of(context).sheet,
    builder: (_) => FocusSheet(wheel: wheel, hit: hit),
  );
}

class FocusSheet extends StatefulWidget {
  const FocusSheet({super.key, required this.wheel, required this.hit});

  final WheelModel wheel;
  final WheelHit hit;

  @override
  State<FocusSheet> createState() => _FocusSheetState();
}

class _FocusSheetState extends State<FocusSheet> {
  late WheelHit _hit = widget.hit;
  final Map<String, GlobalKey> _groupKeys = {};
  bool _scrolled = false;

  void _toggle(Feeling feeling) {
    final scope = AppScope.of(context);
    final hue = widget.wheel.family(feeling.familyId).hue;
    scope.selection.toggle(feeling, hue);
    HapticFeedback.selectionClick();
  }

  void _scrollToGroup(String? id) {
    if (_scrolled || id == null) return;
    _scrolled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _groupKeys[id]?.currentContext;
      if (ctx == null || !mounted) return;
      Scrollable.ensureVisible(
        ctx,
        alignment: 0.15,
        duration: Motion.of(context).medium,
        curve: Motion.ease,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final c = AppColors.of(context);
    final text = Theme.of(context).textTheme;

    return ListenableBuilder(
      listenable: Listenable.merge([scope.selection, scope.settings]),
      builder: (context, _) {
        final form = scope.settings.wordForm;
        final content = FocusContent.forHit(widget.wheel, _hit, form);
        _scrollToGroup(content.scrollToGroupId);
        final showFormCard =
            !scope.settings.wordFormChosen &&
            content.feelings.any((f) => f.word.isGendered);

        Widget chip(Feeling f, {bool emphasis = false, String? caption}) =>
            FeelingChip(
              key: ValueKey('chip-${f.id}'),
              word: f.word.of(form),
              hue: widget.wheel.family(f.familyId).hue,
              selected: scope.selection.contains(f.key),
              emphasis: emphasis,
              caption: caption,
              onTap: () => _toggle(f),
            );

        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.62,
          minChildSize: 0.35,
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
              Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Palette.fill(
                        content.hue,
                        Tier.strong,
                        c.brightness,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(color: c.ink.withValues(alpha: 0.25)),
                    ),
                  ),
                  const SizedBox(width: Space.m),
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(content.title, style: text.titleLarge),
                    ),
                  ),
                  IconButton(
                    tooltip: S.close,
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              if (content.signal != null) ...[
                const SizedBox(height: Space.xs),
                Text(
                  content.signal!,
                  style: text.bodyLarge?.copyWith(color: c.inkMuted),
                ),
              ],
              if (content.titleFeeling != null) ...[
                const SizedBox(height: Space.m),
                Align(
                  alignment: Alignment.centerLeft,
                  child: chip(content.titleFeeling!),
                ),
              ],
              if (showFormCard) ...[
                const SizedBox(height: Space.l),
                const _WordFormCard(),
              ],
              const SizedBox(height: Space.l),
              for (final g in content.groups)
                Padding(
                  key: _groupKeys.putIfAbsent(g.id, GlobalKey.new),
                  padding: const EdgeInsets.only(bottom: Space.m),
                  child: g.heading != null
                      ? _GroupCard(
                          hue: widget.wheel.family(g.heading!.familyId).hue,
                          highlighted: g.id == content.scrollToGroupId,
                          children: [
                            chip(g.heading!, emphasis: true),
                            if (g.chips.isNotEmpty)
                              Wrap(
                                spacing: Space.s,
                                runSpacing: Space.s,
                                children: [for (final f in g.chips) chip(f)],
                              ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (g.caption != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: Space.s),
                                child: Text(
                                  g.caption!,
                                  style: text.labelMedium?.copyWith(
                                    color: c.inkMuted,
                                  ),
                                ),
                              ),
                            Wrap(
                              spacing: Space.s,
                              runSpacing: Space.s,
                              children: [
                                for (final f in g.chips)
                                  chip(f, caption: g.chipCaptions[f.id]),
                              ],
                            ),
                            if (g.action != null)
                              OutlinedButton.icon(
                                onPressed: () => setState(() {
                                  _hit = g.action!.hit;
                                  _scrolled = true;
                                }),
                                icon: const Icon(Icons.swap_horiz_rounded),
                                label: Text(g.action!.label),
                              ),
                          ],
                        ),
                ),
              if (_hit is CircumplexHit)
                Padding(
                  padding: const EdgeInsets.only(top: Space.s),
                  child: Text(S.nearYourPointHint, style: text.bodySmall),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({
    required this.hue,
    required this.children,
    this.highlighted = false,
  });

  final FamilyHue hue;
  final List<Widget> children;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(Space.m),
      decoration: BoxDecoration(
        color: c.background,
        borderRadius: Radii.cardAll,
        border: Border.all(
          color: highlighted
              ? Palette.fill(hue, Tier.strong, c.brightness)
              : c.outline,
          width: highlighted ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: Space.s),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _WordFormCard extends StatelessWidget {
  const _WordFormCard();

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.of(context).settings;
    final c = AppColors.of(context);
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(Space.m),
      decoration: BoxDecoration(color: c.sunken, borderRadius: Radii.cardAll),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(S.formQuestion, style: text.titleSmall),
          const SizedBox(height: Space.s),
          Wrap(
            spacing: Space.s,
            runSpacing: Space.s,
            children: [
              OutlinedButton(
                onPressed: () => settings.setWordForm(WordForm.masculine),
                child: const Text(S.formMasculine),
              ),
              OutlinedButton(
                onPressed: () => settings.setWordForm(WordForm.feminine),
                child: const Text(S.formFeminine),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
