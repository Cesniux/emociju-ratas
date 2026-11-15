import '../copy/strings.dart';
import '../data/models.dart';
import '../wheel/labels.dart';
import '../wheel/wheel_layout.dart';

/// A group of words in the sheet: a middle-ring word with its outer words,
/// or a captioned row (Plutchik ladder, nearest words…).
class FocusGroup {
  const FocusGroup({
    required this.id,
    this.heading,
    this.caption,
    this.chips = const [],
    this.chipCaptions = const {},
    this.action,
  });

  final String id;
  final Feeling? heading;
  final String? caption;
  final List<Feeling> chips;
  final Map<String, String> chipCaptions;
  final FocusAction? action;

  bool containsFeeling(String id) =>
      heading?.id == id || chips.any((c) => c.id == id);
}

/// A button that swaps the sheet to another place on the wheel.
class FocusAction {
  const FocusAction(this.label, this.hit);

  final String label;
  final WheelHit hit;
}

/// Everything one sheet shows, built the same way for every wheel kind.
class FocusContent {
  const FocusContent({
    required this.title,
    required this.hue,
    required this.groups,
    this.titleFeeling,
    this.signal,
    this.scrollToGroupId,
  });

  final String title;
  final FamilyHue hue;
  final Feeling? titleFeeling;
  final String? signal;
  final List<FocusGroup> groups;
  final String? scrollToGroupId;

  Iterable<Feeling> get feelings sync* {
    if (titleFeeling != null) yield titleFeeling!;
    for (final g in groups) {
      if (g.heading != null) yield g.heading!;
      yield* g.chips;
    }
  }

  static FocusContent forHit(WheelModel wheel, WheelHit hit, WordForm form) =>
      switch ((wheel, hit)) {
        (SunburstWheel w, SunburstHit h) => _sunburst(w, h, form),
        (PetalWheel w, PetalHit h) => _petal(w, h.petal, form),
        (PetalWheel w, DyadHit h) => _dyad(w, h.dyad, form),
        (CircumplexWheel w, CircumplexHit h) => _circumplex(w, h, form),
        _ => throw ArgumentError('Hit $hit does not belong to ${wheel.id}'),
      };

  static FocusContent _sunburst(SunburstWheel w, SunburstHit h, WordForm form) {
    final root = w.roots.firstWhere((r) => r.family.id == h.familyId);
    final groups = [
      for (final m in root.children)
        FocusGroup(
          id: m.feeling.id,
          heading: m.feeling,
          chips: [for (final o in m.children) o.feeling],
        ),
    ];
    String? scrollTo;
    if (h.feelingId != null) {
      for (final g in groups) {
        if (g.containsFeeling(h.feelingId!)) scrollTo = g.id;
      }
    }
    return FocusContent(
      title: sentenceCase(root.family.name.of(form)),
      hue: root.family.hue,
      titleFeeling: root.core,
      signal: root.family.signal,
      groups: groups,
      scrollToGroupId: scrollTo,
    );
  }

  static FocusContent _petal(PetalWheel w, int i, WordForm form) {
    final p = w.petals[i];
    final n = w.petals.length;
    final left = w.dyads.firstWhere((d) => d.b == i);
    final right = w.dyads.firstWhere((d) => d.a == i);
    String name(int k) => w.petals[k].basic.word.of(form);
    final opposite = w.opposite(i);
    return FocusContent(
      title: sentenceCase(p.basic.word.of(form)),
      hue: p.family.hue,
      signal: p.family.signal,
      groups: [
        FocusGroup(id: 'ladder', caption: S.plutchikLadder, chips: p.ladder),
        FocusGroup(
          id: 'mixes',
          caption: S.plutchikMixes,
          chips: [left.feeling, right.feeling],
          chipCaptions: {
            left.feeling.id: '${name((i - 1 + n) % n)} + ${name(i)}',
            right.feeling.id: '${name(i)} + ${name((i + 1) % n)}',
          },
        ),
        FocusGroup(
          id: 'opposite',
          caption: S.plutchikOpposite,
          action: FocusAction(
            sentenceCase(name(opposite)),
            PetalHit(w.petals[opposite].family.id, petal: opposite),
          ),
        ),
      ],
    );
  }

  static FocusContent _dyad(PetalWheel w, int k, WordForm form) {
    final d = w.dyads[k];
    final a = w.petals[d.a];
    final b = w.petals[d.b];
    return FocusContent(
      title: sentenceCase(d.feeling.word.of(form)),
      hue: a.family.hue,
      signal:
          '${sentenceCase(a.basic.word.of(form))} + '
          '${b.basic.word.of(form)}',
      groups: [
        FocusGroup(id: 'dyad', chips: [d.feeling, a.basic, b.basic]),
        FocusGroup(
          id: 'petals',
          caption: S.plutchikMixes,
          action: FocusAction(
            sentenceCase(a.basic.word.of(form)),
            PetalHit(a.family.id, petal: d.a),
          ),
        ),
      ],
    );
  }

  static FocusContent _circumplex(
    CircumplexWheel w,
    CircumplexHit h,
    WordForm form,
  ) {
    final q = w.quadrants.firstWhere((f) => f.id == h.familyId);
    final near = w.nearest(h.valence, h.arousal, count: 4);
    return FocusContent(
      title: sentenceCase(q.name.of(form)),
      hue: q.hue,
      signal: q.signal,
      groups: [
        FocusGroup(
          id: 'near',
          caption: S.nearYourPoint,
          chips: [for (final p in near) p.feeling],
        ),
      ],
    );
  }
}
