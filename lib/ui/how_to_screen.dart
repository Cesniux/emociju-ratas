import 'package:flutter/material.dart';

import '../copy/strings.dart';
import '../data/science.dart';
import '../data/sources.dart';
import '../data/wheels.dart';
import '../theme/colors.dart';
import '../theme/tokens.dart';
import 'links.dart';

/// Why naming feelings helps and how to use the wheel, with sources.
class HowToScreen extends StatelessWidget {
  const HowToScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      // No back arrow up top: "Grįžti" waits at the bottom, under the thumb.
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
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                Space.xl,
                Space.l,
                Space.xl,
                Space.xl,
              ),
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    S.howToUse,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(height: Space.l),
                for (final card in guideCards) ...[
                  _Card(card: card),
                  const SizedBox(height: Space.l),
                ],
                Semantics(
                  header: true,
                  child: Text(S.sources, style: text.titleLarge),
                ),
                const SizedBox(height: Space.m),
                for (var i = 0; i < references.length; i++)
                  _ReferenceTile(number: i + 1, reference: references[i]),
                const SizedBox(height: Space.l),
                Text(
                  'Tekstas paremtas tyrimais, bet nepakeičia specialisto '
                  'pagalbos.',
                  style: text.bodySmall?.copyWith(color: c.inkMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.card});

  final GuideCard card;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final text = Theme.of(context).textTheme;
    final body = text.bodyLarge;

    final children = <Widget>[
      Semantics(header: true, child: Text(card.title, style: text.titleMedium)),
      const SizedBox(height: Space.s),
    ];

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
        for (final p in card.paragraphs) {
          children.add(
            Padding(
              padding: const EdgeInsets.only(bottom: Space.s),
              child: Text(p, style: body),
            ),
          );
        }
        for (final h in helplines) {
          children.add(_HelplineTile(line: h));
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
        for (final p in card.paragraphs) {
          children.add(Text(p, style: body));
        }
        for (final w in allWheels) {
          children.addAll([
            const SizedBox(height: Space.m),
            Text(w.title, style: text.titleSmall),
            Text(w.byline, style: text.bodySmall),
            const SizedBox(height: Space.xs),
            Text(wheelStories[w.id] ?? w.whenToUse, style: body),
          ]);
        }
      case CardKind.about:
        for (final p in card.paragraphs) {
          children.add(
            Padding(
              padding: const EdgeInsets.only(bottom: Space.s),
              child: Text(p, style: body),
            ),
          );
        }
        for (final s in wordSources.values) {
          children.add(
            Padding(
              padding: const EdgeInsets.only(bottom: Space.xs),
              child: Text(
                '${s.name}. ${s.description}',
                style: text.bodyMedium,
              ),
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
        for (final p in card.paragraphs) {
          children.add(
            Padding(
              padding: const EdgeInsets.only(bottom: Space.s),
              child: Text(p, style: body),
            ),
          );
        }
    }

    if (card.refs.isNotEmpty) {
      final numbers = [for (final r in card.refs) referenceNumber(r)]..sort();
      children.addAll([
        const SizedBox(height: Space.s),
        Text('${S.sources}: ${numbers.join(', ')}', style: text.bodySmall),
      ]);
    }

    return Container(
      padding: const EdgeInsets.all(Space.l + 4),
      decoration: BoxDecoration(
        color: card.kind == CardKind.helplines ? c.sunken : c.surface,
        borderRadius: Radii.cardAll,
        border: Border.all(color: c.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _HelplineTile extends StatelessWidget {
  const _HelplineTile({required this.line});

  final Helpline line;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final text = Theme.of(context).textTheme;
    return Semantics(
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
    ).withBottomGap();
  }
}

class _ReferenceTile extends StatelessWidget {
  const _ReferenceTile({required this.number, required this.reference});

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

extension on Widget {
  Widget withBottomGap() => Padding(
    padding: const EdgeInsets.only(bottom: Space.s),
    child: this,
  );
}
