import 'package:flutter/material.dart';

import '../copy/strings.dart';
import '../data/science.dart';
import '../theme/motion.dart';
import '../theme/tokens.dart';
import 'flower_icon.dart';
import 'reading.dart';

/// "Kodėl emocijų ratas gali būti naudingas?": a short reading tour.
///
/// Six small numbered chapters, one open at a time. The first is open when
/// the page opens, and each ends with "Toliau" to the next one, so the page
/// can be read like a little book or picked from like a list. "Apie
/// programėlę" and the sources follow the tour.
class WhyScreen extends StatefulWidget {
  const WhyScreen({super.key, this.openSources = false});

  /// Open on the list of sources instead of the first chapter.
  final bool openSources;

  @override
  State<WhyScreen> createState() => _WhyScreenState();
}

class _WhyScreenState extends State<WhyScreen> {
  final List<GuideCard> _tour = tourCards;
  final GuideCard _about = guideCards.firstWhere(
    (c) => c.kind == CardKind.about,
  );

  /// Folds in page order: the chapters, "Apie programėlę", the sources.
  late final int _aboutIndex = _tour.length;
  late final int _sourcesIndex = _tour.length + 1;
  late final List<GlobalKey> _keys = List.generate(
    _tour.length + 2,
    (i) => GlobalKey(debugLabel: 'fold $i'),
  );

  /// The open fold, if any. Opening one closes the others.
  late int? _open = widget.openSources ? _sourcesIndex : 0;

  @override
  void initState() {
    super.initState();
    if (widget.openSources) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _reveal(_sourcesIndex),
      );
    }
  }

  void _toggle(int i) => setState(() => _open = _open == i ? null : i);

  void _go(int i) => setState(() => _open = i);

  /// Brings an opened fold's title to the top, once the fold above it has
  /// closed.
  void _reveal(int i) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _keys[i].currentContext;
      if (!mounted || context == null) return;
      final motion = Motion.of(this.context);
      Scrollable.ensureVisible(
        context,
        duration: motion.medium,
        curve: Motion.ease,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ReadingPage(
      title: S.whyTitle,
      lead: '${S.whyLead} ${S.whyHowToRead}',
      children: [
        for (var i = 0; i < _tour.length; i++) ...[
          FoldCard(
            key: _keys[i],
            number: i + 1,
            title: _tour[i].title,
            lead: firstSentence(_tour[i].paragraphs.first),
            open: _open == i,
            onToggle: () => _toggle(i),
            onOpened: () => _reveal(i),
            body: [
              ...cardBody(context, _tour[i]),
              const SizedBox(height: Space.m),
              _NextButton(
                next: i + 1 < _tour.length ? _tour[i + 1] : null,
                onNext: () => _go(i + 1),
              ),
            ],
          ),
          const SizedBox(height: Space.s),
        ],
        const SizedBox(height: Space.m),
        FoldCard(
          key: _keys[_aboutIndex],
          title: _about.title,
          lead: firstSentence(_about.paragraphs.first),
          open: _open == _aboutIndex,
          onToggle: () => _toggle(_aboutIndex),
          onOpened: () => _reveal(_aboutIndex),
          body: cardBody(context, _about),
        ),
        const SizedBox(height: Space.s),
        FoldCard(
          key: _keys[_sourcesIndex],
          title: S.sources,
          lead: S.sourcesLead,
          open: _open == _sourcesIndex,
          onToggle: () => _toggle(_sourcesIndex),
          onOpened: () => _reveal(_sourcesIndex),
          body: [
            for (var i = 0; i < references.length; i++)
              ReferenceTile(number: i + 1, reference: references[i]),
          ],
        ),
        const SizedBox(height: Space.l),
        const ReadingNote(),
      ],
    );
  }
}

/// "Toliau" and the next chapter's title, or back to the wheel after the last.
class _NextButton extends StatelessWidget {
  const _NextButton({required this.next, required this.onNext});

  final GuideCard? next;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final style = OutlinedButton.styleFrom(
      minimumSize: const Size.fromHeight(52),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(
        horizontal: Space.l,
        vertical: Space.s,
      ),
    );
    final next = this.next;
    if (next == null) {
      return OutlinedButton.icon(
        style: style,
        onPressed: () =>
            Navigator.of(context).popUntil((route) => route.isFirst),
        icon: const FlowerIcon(size: 24),
        label: const Text(S.backToWheel),
      );
    }
    return OutlinedButton.icon(
      style: style,
      onPressed: onNext,
      iconAlignment: IconAlignment.end,
      icon: const Icon(Icons.arrow_forward_rounded),
      label: Text('${S.next}: ${next.title}'),
    );
  }
}
