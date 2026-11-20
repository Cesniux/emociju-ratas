import 'package:flutter/material.dart';

import '../copy/strings.dart';
import '../data/science.dart';
import '../theme/colors.dart';
import '../theme/tokens.dart';
import 'reading.dart';
import 'why_screen.dart';

/// "Kaip naudotis": how to use the wheel, the door to why it can help, and
/// where to find help. Short, so the help lines are always in sight.
class HowToScreen extends StatelessWidget {
  const HowToScreen({super.key});

  static void _openWhy(BuildContext context, {bool sources = false}) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => WhyScreen(openSources: sources),
        ),
      );

  @override
  Widget build(BuildContext context) {
    GuideCard card(CardKind kind) =>
        guideCards.firstWhere((c) => c.kind == kind);
    void sources() => _openWhy(context, sources: true);
    return ReadingPage(
      title: S.howToUse,
      children: [
        OpenCard(card: card(CardKind.steps), onSources: sources),
        const SizedBox(height: Space.l),
        WhyTile(onTap: () => _openWhy(context)),
        const SizedBox(height: Space.l),
        OpenCard(card: card(CardKind.helplines), onSources: sources),
        const SizedBox(height: Space.l),
        const ReadingNote(),
      ],
    );
  }
}

/// "Kodėl emocijų ratas gali būti naudingas?": a quiet door to the short
/// reading tour.
class WhyTile extends StatelessWidget {
  const WhyTile({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final text = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      label: '${S.whyTitle} ${S.whyLead}',
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: c.surface,
        shape: RoundedRectangleBorder(
          borderRadius: Radii.cardAll,
          side: BorderSide(color: c.ink, width: 1.5),
        ),
        child: InkWell(
          customBorder: RoundedRectangleBorder(borderRadius: Radii.cardAll),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              Space.l,
              Space.l,
              Space.m,
              Space.l,
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: c.sunken,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.auto_stories_outlined,
                    color: c.ink,
                    size: 26,
                  ),
                ),
                const SizedBox(width: Space.l),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(S.whyTitle, style: text.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        S.whyLead,
                        style: text.bodyMedium?.copyWith(color: c.inkMuted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: Space.s),
                Icon(Icons.chevron_right_rounded, color: c.ink, size: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
