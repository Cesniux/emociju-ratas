// Pure Dart data model for every wheel. No Flutter imports, so the data can
// also be printed by `dart run tool/print_wheels.dart`.

import 'dart:math' as math;

/// Grammatical form used for gendered Lithuanian words.
enum WordForm { masculine, feminine }

/// A Lithuanian word. Adjectives and participles carry both grammatical forms
/// (vienišas / vieniša); nouns have one.
final class LtWord {
  const LtWord(this.masculine, this.feminine);
  const LtWord.noun(String form) : masculine = form, feminine = form;

  final String masculine;
  final String feminine;

  bool get isGendered => masculine != feminine;
  String of(WordForm form) => form == WordForm.feminine ? feminine : masculine;
}

/// Calm hue families (resolved to colours in `lib/theme/palette.dart`).
enum FamilyHue {
  yellow,
  olive,
  blue,
  mauve,
  clay,
  orange,
  sage,
  green,
  sky,
  rose,
}

/// A colour family: a sunburst core, a Plutchik petal or an energy quadrant.
final class Family {
  const Family({
    required this.id,
    required this.name,
    required this.hue,
    required this.signal,
    this.en,
  });

  final String id;
  final LtWord name;
  final FamilyHue hue;

  /// One gentle line on what this feeling often signals (sheet header).
  final String signal;
  final String? en;
}

/// One feeling word placed in a wheel.
final class Feeling {
  const Feeling({
    required this.id,
    required this.word,
    required this.familyId,
    required this.src,
    this.en,
    this.note,
  });

  /// Unique across all wheels: `wheel/family/…/word`.
  final String id;
  final LtWord word;
  final String familyId;

  /// Where the Lithuanian word comes from (see `lib/data/sources.dart`).
  final String src;

  /// English gloss for review only (never shown).
  final String? en;

  /// Review note, e.g. how the source spells it.
  final String? note;

  /// Selection key: the same word chosen anywhere is one chip.
  String get key => word.masculine;
}

sealed class WheelModel {
  const WheelModel({
    required this.id,
    required this.title,
    required this.byline,
    required this.whenToUse,
    required this.hint,
  });

  final String id;
  final String title;

  /// Author and year, e.g. "R. Plutchik, 1980".
  final String byline;

  /// "Kada tinka" line in the wheel menu.
  final String whenToUse;

  /// Hint under the prompt on Home.
  final String hint;

  List<Family> get families;
  Iterable<Feeling> get feelings;

  Family family(String familyId) =>
      families.firstWhere((f) => f.id == familyId);

  Feeling? feeling(String feelingId) {
    for (final f in feelings) {
      if (f.id == feelingId) return f;
    }
    return null;
  }
}

// ---------------------------------------------------------------------------
// Sunburst (hierarchical rings)
// ---------------------------------------------------------------------------

final class SunburstNode {
  const SunburstNode(this.feeling, [this.children = const []]);

  final Feeling feeling;
  final List<SunburstNode> children;

  int get leafCount =>
      children.isEmpty ? 1 : children.fold(0, (sum, c) => sum + c.leafCount);

  Iterable<SunburstNode> get descendants sync* {
    for (final c in children) {
      yield c;
      yield* c.descendants;
    }
  }
}

final class SunburstRoot {
  const SunburstRoot(this.family, this.core, this.children);

  final Family family;

  /// The family's own word (selectable), e.g. "liūdesys".
  final Feeling core;
  final List<SunburstNode> children;

  int get leafCount =>
      children.isEmpty ? 1 : children.fold(0, (sum, c) => sum + c.leafCount);
}

final class SunburstWheel extends WheelModel {
  const SunburstWheel({
    required super.id,
    required super.title,
    required super.byline,
    required super.whenToUse,
    required super.hint,
    required this.roots,
  });

  final List<SunburstRoot> roots;

  @override
  List<Family> get families => [for (final r in roots) r.family];

  @override
  Iterable<Feeling> get feelings sync* {
    for (final r in roots) {
      yield r.core;
      for (final c in r.children) {
        yield c.feeling;
        for (final d in c.descendants) {
          yield d.feeling;
        }
      }
    }
  }

  /// Deepest ring index used (1 = middle only, 2 = middle + outer).
  int get depth {
    var d = 0;
    for (final r in roots) {
      for (final c in r.children) {
        d = math.max(d, c.children.isEmpty ? 1 : 2);
      }
    }
    return d;
  }
}

// ---------------------------------------------------------------------------
// Plutchik (petals with intensity bands, dyads between neighbours)
// ---------------------------------------------------------------------------

final class Petal {
  const Petal(this.family, this.mild, this.basic, this.intense);

  final Family family;
  final Feeling mild;
  final Feeling basic;
  final Feeling intense;

  /// Mild → basic → intense.
  List<Feeling> get ladder => [mild, basic, intense];
}

/// A mixture of petal [a] and its clockwise neighbour.
final class Dyad {
  const Dyad(this.feeling, this.a);

  final Feeling feeling;
  final int a;
  int get b => (a + 1) % 8;
}

final class PetalWheel extends WheelModel {
  const PetalWheel({
    required super.id,
    required super.title,
    required super.byline,
    required super.whenToUse,
    required super.hint,
    required this.petals,
    required this.dyads,
  });

  final List<Petal> petals;
  final List<Dyad> dyads;

  int opposite(int i) => (i + petals.length ~/ 2) % petals.length;

  @override
  List<Family> get families => [for (final p in petals) p.family];

  @override
  Iterable<Feeling> get feelings sync* {
    for (final p in petals) {
      yield* p.ladder;
    }
    for (final d in dyads) {
      yield d.feeling;
    }
  }
}

// ---------------------------------------------------------------------------
// Circumplex (pleasantness × energy)
// ---------------------------------------------------------------------------

final class PlacedFeeling {
  const PlacedFeeling(
    this.feeling, {
    required this.clockDeg,
    required this.radius,
  });

  final Feeling feeling;

  /// Angle clockwise from 12 o'clock (top = most energy, right = pleasant).
  final double clockDeg;

  /// Distance from the centre, 0..1 (intensity).
  final double radius;

  double get _rad => clockDeg * math.pi / 180;

  /// −1 (unpleasant) … +1 (pleasant).
  double get valence => radius * math.sin(_rad);

  /// −1 (low energy) … +1 (high energy).
  double get arousal => radius * math.cos(_rad);
}

final class CircumplexWheel extends WheelModel {
  const CircumplexWheel({
    required super.id,
    required super.title,
    required super.byline,
    required super.whenToUse,
    required super.hint,
    required this.quadrants,
    required this.points,
  });

  /// Clockwise from top-right: energetic+pleasant, calm+pleasant,
  /// calm+unpleasant, energetic+unpleasant.
  final List<Family> quadrants;
  final List<PlacedFeeling> points;

  @override
  List<Family> get families => quadrants;

  @override
  Iterable<Feeling> get feelings => points.map((p) => p.feeling);

  /// Quadrant index for a point in (valence, arousal) space.
  int quadrantAt(double valence, double arousal) {
    if (valence >= 0) return arousal >= 0 ? 0 : 1;
    return arousal >= 0 ? 3 : 2;
  }

  /// The [count] words nearest to (valence, arousal), nearest first.
  List<PlacedFeeling> nearest(double valence, double arousal, {int count = 4}) {
    final sorted = [...points]
      ..sort((a, b) {
        double d(PlacedFeeling p) =>
            math.pow(p.valence - valence, 2) +
            math.pow(p.arousal - arousal, 2).toDouble();
        return d(a).compareTo(d(b));
      });
    return sorted.take(count).toList();
  }
}

// ---------------------------------------------------------------------------
// Builders: data files describe words; ids are derived here.
// ---------------------------------------------------------------------------

const _translit = {
  'ą': 'a',
  'č': 'c',
  'ę': 'e',
  'ė': 'e',
  'į': 'i',
  'š': 's',
  'ų': 'u',
  'ū': 'u',
  'ž': 'z',
};

/// `pasibjaurėjimas` → `pasibjaurejimas`; spaces become dashes.
String slugOf(String text) {
  final buffer = StringBuffer();
  for (final rune in text.toLowerCase().runes) {
    final ch = String.fromCharCode(rune);
    final mapped = _translit[ch] ?? ch;
    if (RegExp(r'[a-z0-9]').hasMatch(mapped)) {
      buffer.write(mapped);
    } else if (mapped == ' ' || mapped == '-') {
      buffer.write('-');
    }
  }
  return buffer.toString().replaceAll(RegExp('-+'), '-');
}

/// Word spec used by the data files.
final class W {
  const W(this.word, {this.en, this.note, this.src, this.children = const []});

  final LtWord word;
  final String? en;
  final String? note;
  final String? src;
  final List<W> children;
}

/// Family spec used by the data files.
final class F {
  const F({
    required this.name,
    required this.hue,
    required this.signal,
    this.en,
    this.note,
    this.src,
    this.children = const [],
  });

  final LtWord name;
  final FamilyHue hue;
  final String signal;
  final String? en;
  final String? note;
  final String? src;
  final List<W> children;
}

String _uniqueSlug(String base, Set<String> taken) {
  var slug = base;
  var n = 2;
  while (!taken.add(slug)) {
    slug = '$base-${n++}';
  }
  return slug;
}

SunburstWheel buildSunburst({
  required String id,
  required String title,
  required String byline,
  required String whenToUse,
  required String hint,
  required String src,
  required List<F> families,
}) {
  final familySlugs = <String>{};
  final roots = <SunburstRoot>[];
  for (final f in families) {
    final familyId =
        '$id/${_uniqueSlug(slugOf(f.name.masculine), familySlugs)}';
    final family = Family(
      id: familyId,
      name: f.name,
      hue: f.hue,
      signal: f.signal,
      en: f.en,
    );
    final core = Feeling(
      id: familyId,
      word: f.name,
      familyId: familyId,
      src: f.src ?? src,
      en: f.en,
      note: f.note,
    );
    SunburstNode node(W w, String parentId, Set<String> siblings) {
      final nodeId =
          '$parentId/${_uniqueSlug(slugOf(w.word.masculine), siblings)}';
      final childSlugs = <String>{};
      return SunburstNode(
        Feeling(
          id: nodeId,
          word: w.word,
          familyId: familyId,
          src: w.src ?? src,
          en: w.en,
          note: w.note,
        ),
        [for (final c in w.children) node(c, nodeId, childSlugs)],
      );
    }

    final slugs = <String>{};
    roots.add(
      SunburstRoot(family, core, [
        for (final c in f.children) node(c, familyId, slugs),
      ]),
    );
  }
  return SunburstWheel(
    id: id,
    title: title,
    byline: byline,
    whenToUse: whenToUse,
    hint: hint,
    roots: roots,
  );
}
