import 'package:flutter/material.dart';

import '../copy/strings.dart';
import '../data/science.dart';
import '../data/sources.dart';
import '../data/wheels.dart';
import '../theme/colors.dart';
import '../theme/motion.dart';
import '../theme/tokens.dart';
import 'links.dart';

// The pieces of the two reading pages ("Kaip naudotis" and "Kodėl emocijų
// ratas gali būti naudingas?"): the page itself, open and folding cards,
// help lines and sources.

/// A calm reading page: a title, a column of cards, and "Grįžti" at the
/// bottom under the thumb (no back arrow up top). Everything is built at
/// once (the pages are short), so any card can be scrolled to.
class ReadingPage extends StatelessWidget {
  const ReadingPage({
    super.key,
    required this.title,
    required this.children,
    this.lead,
  });

  final String title;

  /// A quiet line under the title.
  final String? lead;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Space.s,
            Space.xs,
            Space.s,
            Space.s,
          ),
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(60),
              backgroundColor: c.surface,
            ),
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text(S.back),
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: Sizes.readingMax),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                Space.xl,
                Space.l,
                Space.xl,
                Space.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Semantics(
                    header: true,
                    child: Text(title, style: text.headlineSmall),
                  ),
                  if (lead case final lead?) ...[
                    const SizedBox(height: Space.xs),
                    Text(
                      lead,
                      style: text.bodyLarge?.copyWith(color: c.inkMuted),
                    ),
                  ],
                  const SizedBox(height: Space.l),
                  ...children,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The first sentence of [paragraph]: what a folded card shows.
String firstSentence(String paragraph) {
  final end = RegExp(r'[.!?…](?=\s)').firstMatch(paragraph);
  return end == null ? paragraph : paragraph.substring(0, end.end);
}

/// A card that is always open: its title and everything under it.
class OpenCard extends StatelessWidget {
  const OpenCard({super.key, required this.card, this.onSources});

  final GuideCard card;

  /// Opens the list of sources (the numbers under the card become a link).
  final VoidCallback? onSources;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(Space.l + 4),
      decoration: BoxDecoration(
        color: card.kind == CardKind.helplines ? c.sunken : c.surface,
        borderRadius: Radii.cardAll,
        border: Border.all(color: c.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(card.title, style: text.titleMedium),
          ),
          const SizedBox(height: Space.s),
          ...cardBody(context, card, onSources: onSources),
        ],
      ),
    );
  }
}

/// A card that opens when touched: its title and first sentence while
/// closed, all of it when open. The sentence stays where it was and the
/// rest unfolds under it. Its parent decides which card is open, so only
/// one is open at a time.
class FoldCard extends StatelessWidget {
  const FoldCard({
    super.key,
    required this.title,
    required this.lead,
    required this.body,
    required this.open,
    required this.onToggle,
    this.number,
    this.onOpened,
  });

  final String title;
  final String lead;
  final List<Widget> body;
  final bool open;
  final VoidCallback onToggle;

  /// Its place in the reading order, shown in a small circle.
  final int? number;

  /// Called once the card has finished opening.
  final VoidCallback? onOpened;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final text = Theme.of(context).textTheme;
    final motion = Motion.of(context);
    final l10n = MaterialLocalizations.of(context);
    final state = open ? CrossFadeState.showSecond : CrossFadeState.showFirst;
    const side = Space.l + 4;

    return Material(
      color: c.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: Radii.cardAll,
        side: BorderSide(color: c.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Read as one: "Title. First sentence", a button, folded or open.
          MergeSemantics(
            child: Semantics(
              button: true,
              hint: open ? l10n.collapsedHint : l10n.expandedHint,
              child: InkWell(
                onTap: onToggle,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    side,
                    Space.l,
                    Space.m,
                    open ? Space.xs : Space.l,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (number case final n?)
                        Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(right: Space.m),
                          decoration: BoxDecoration(
                            color: c.sunken,
                            shape: BoxShape.circle,
                          ),
                          child: Text('$n', style: text.labelMedium),
                        ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Semantics(
                              header: true,
                              child: Text(title, style: text.titleMedium),
                            ),
                            AnimatedCrossFade(
                              duration: motion.medium,
                              sizeCurve: Motion.ease,
                              crossFadeState: state,
                              firstChild: Padding(
                                padding: const EdgeInsets.only(top: Space.xs),
                                child: Text(
                                  lead,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: text.bodyLarge?.copyWith(
                                    color: c.inkMuted,
                                  ),
                                ),
                              ),
                              secondChild: const SizedBox(
                                width: double.infinity,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: Space.s),
                      AnimatedRotation(
                        turns: open ? 0.5 : 0,
                        duration: motion.medium,
                        curve: Motion.ease,
                        onEnd: open ? onOpened : null,
                        child: Icon(
                          Icons.expand_more_rounded,
                          size: 28,
                          color: c.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: motion.medium,
            sizeCurve: Motion.ease,
            crossFadeState: state,
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              // The whole width of the card: longer, calmer lines.
              padding: const EdgeInsets.fromLTRB(side, Space.s, side, side),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: body,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Everything in a card under its title: steps, paragraphs, help lines,
/// the wheels, and which sources back it.
List<Widget> cardBody(
  BuildContext context,
  GuideCard card, {
  VoidCallback? onSources,
}) {
  final c = AppColors.of(context);
  final text = Theme.of(context).textTheme;
  final body = text.bodyLarge;
  final children = <Widget>[];

  Widget paragraph(String p) => Padding(
    padding: const EdgeInsets.only(bottom: Space.s),
    child: Text(p, style: body),
  );

  switch (card.kind) {
    case CardKind.steps:
      for (var i = 0; i < card.paragraphs.length; i++) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: Space.s),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(right: Space.m, top: 1),
                  decoration: BoxDecoration(
                    color: c.sunken,
                    shape: BoxShape.circle,
                  ),
                  child: Text('${i + 1}', style: text.labelMedium),
                ),
                Expanded(child: Text(card.paragraphs[i], style: body)),
              ],
            ),
          ),
        );
      }
      children.add(
        Text(
          'Teisingų ar neteisingų atsakymų nėra. Ratas tik padeda rasti žodį.',
          style: body?.copyWith(color: c.inkMuted),
        ),
      );
    case CardKind.helplines:
      children.addAll(card.paragraphs.map(paragraph));
      for (final h in helplines) {
        children.add(HelplineTile(line: h));
      }
      children.add(
        Align(
          alignment: Alignment.centerLeft,
          child: Semantics(
            link: true,
            child: TextButton.icon(
              onPressed: () => openLink(
                context,
                Uri.parse(helplinesAllUrl),
                shown: 'pagalbasau.lt',
              ),
              icon: const Icon(Icons.open_in_new_rounded, size: 20),
              label: const Text('Visos pagalbos linijos: pagalbasau.lt'),
            ),
          ),
        ),
      );
    case CardKind.wheels:
      children.addAll(card.paragraphs.map(paragraph));
      for (final w in allWheels) {
        children.addAll([
          const SizedBox(height: Space.s),
          Text(w.title, style: text.titleSmall),
          Text(w.byline, style: text.bodySmall),
          const SizedBox(height: Space.xs),
          Text(wheelStories[w.id] ?? w.whenToUse, style: body),
        ]);
      }
    case CardKind.about:
      children.addAll(card.paragraphs.map(paragraph));
      for (final s in wordSources.values) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: Space.xs),
            child: Text('${s.name}. ${s.description}', style: text.bodyMedium),
          ),
        );
      }
      children.add(
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () =>
                showLicensePage(context: context, applicationName: S.appName),
            child: const Text('Šriftų ir programų licencijos'),
          ),
        ),
      );
    case CardKind.text:
      children.addAll(card.paragraphs.map(paragraph));
  }

  if (card.refs.isNotEmpty) {
    final numbers = [for (final r in card.refs) referenceNumber(r)]..sort();
    final label = '${S.sources}: ${numbers.join(', ')}';
    children.add(const SizedBox(height: Space.s));
    children.add(
      onSources == null
          ? Text(label, style: text.bodySmall)
          : Align(
              alignment: Alignment.centerLeft,
              child: Semantics(
                link: true,
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: Space.s),
                    textStyle: text.bodySmall,
                    foregroundColor: c.ink,
                  ),
                  onPressed: onSources,
                  child: Text(
                    label,
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ),
    );
  }
  return children;
}

class HelplineTile extends StatelessWidget {
  const HelplineTile({super.key, required this.line});

  final Helpline line;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.s),
      child: Semantics(
        button: true,
        link: true,
        label: '${line.name}. ${line.note} ${S.openSite}.',
        excludeSemantics: true,
        onTap: () => openLink(context, Uri.parse(line.url)),
        child: Material(
          color: c.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: c.outline),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => openLink(context, Uri.parse(line.url)),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Space.l,
                vertical: Space.m,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(line.name, style: text.titleMedium),
                        Text(
                          line.note,
                          style: text.bodyMedium?.copyWith(color: c.inkMuted),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.open_in_new_rounded, color: c.ink),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ReferenceTile extends StatelessWidget {
  const ReferenceTile({
    super.key,
    required this.number,
    required this.reference,
  });

  final int number;
  final Reference reference;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final text = Theme.of(context).textTheme;
    final link = reference.link;
    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 32,
          child: Text(
            '$number.',
            style: text.bodySmall?.copyWith(color: c.ink),
          ),
        ),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                // English titles: let screen readers switch voice.
                TextSpan(text: reference.text, locale: const Locale('en')),
                if (link != null) ...[
                  const TextSpan(text: ' '),
                  TextSpan(
                    text: reference.doi != null ? 'doi:${reference.doi}' : link,
                    style: TextStyle(
                      color: c.ink,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ],
            ),
            style: text.bodySmall?.copyWith(color: c.inkMuted),
          ),
        ),
      ],
    );
    if (link == null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: Space.s),
        child: content,
      );
    }
    return Semantics(
      link: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => openLink(context, Uri.parse(link)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Space.xs + 2),
          child: content,
        ),
      ),
    );
  }
}

/// The quiet line at the end of both reading pages.
class ReadingNote extends StatelessWidget {
  const ReadingNote({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Text(
      S.readingNote,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.inkMuted),
    );
  }
}
