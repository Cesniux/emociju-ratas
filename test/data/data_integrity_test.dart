import 'package:emociju_ratas/data/energija.dart';
import 'package:emociju_ratas/data/jausmu_ratas.dart';
import 'package:emociju_ratas/data/jausmu_seimos.dart';
import 'package:emociju_ratas/data/plutchik.dart';
import 'package:emociju_ratas/data/science.dart';
import 'package:emociju_ratas/data/sources.dart';
import 'package:emociju_ratas/data/wheels.dart';
import 'package:flutter_test/flutter_test.dart';

/// Lithuanian adjective/participle pairs: masculine → feminine endings.
bool plausibleFeminine(String masculine, String feminine) {
  final m = masculine.split(' ').last;
  final f = feminine.split(' ').last;
  String stem(int cut) => m.substring(0, m.length - cut);
  if (m.endsWith('ęs')) {
    return f == '${stem(2)}usi' || f == '${stem(2)}iusi';
  }
  // pasitikintis → pasitikinti
  if (m.endsWith('tis') && f == stem(1)) return true;
  if (m.endsWith('is')) return f == '${stem(2)}ė'; // bejėgis → bejėgė
  if (m.endsWith('us')) return f == '${stem(2)}i'; // ramus → rami
  if (m.endsWith('as')) return f == '${stem(2)}a'; // vienišas → vieniša
  return false;
}

void main() {
  test('feeling ids are unique and well formed across all wheels', () {
    final ids = <String>{};
    final pattern = RegExp(r'^[a-z0-9-]+(/[a-z0-9-]+)*$');
    for (final wheel in allWheels) {
      for (final f in wheel.feelings) {
        expect(pattern.hasMatch(f.id), isTrue, reason: f.id);
        expect(ids.add(f.id), isTrue, reason: 'duplicate ${f.id}');
      }
    }
  });

  test('words are clean, sourced and have plausible feminine forms', () {
    for (final wheel in allWheels) {
      for (final f in wheel.feelings) {
        for (final form in [f.word.masculine, f.word.feminine]) {
          expect(form.trim(), form, reason: f.id);
          expect(form, isNotEmpty, reason: f.id);
          expect(
            form,
            form.toLowerCase(),
            reason: '${f.id} is stored lowercase',
          );
        }
        expect(
          wordSources.containsKey(f.src),
          isTrue,
          reason: '${f.id} has unknown source ${f.src}',
        );
        if (f.word.isGendered) {
          expect(
            plausibleFeminine(f.word.masculine, f.word.feminine),
            isTrue,
            reason: '${f.word.masculine} / ${f.word.feminine}',
          );
        }
      }
      for (final family in wheel.families) {
        expect(family.signal.trim(), isNotEmpty, reason: family.id);
      }
    }
  });

  test('every source is cited by a card, and every citation exists', () {
    final cited = {for (final c in guideCards) ...c.refs};
    final listed = {for (final r in references) r.id};
    expect(cited.difference(listed), isEmpty, reason: 'cited, not listed');
    expect(listed.difference(cited), isEmpty, reason: 'listed, never cited');
    expect(listed, hasLength(references.length), reason: 'duplicate ids');
  });

  test('wheel ids resolve and unknown ids fall back to the default', () {
    for (final wheel in allWheels) {
      expect(wheelById(wheel.id), same(wheel));
    }
    expect(wheelById('nera-tokio').id, defaultWheelId);
    expect(wheelById(null).id, defaultWheelId);
  });

  group('Jausmų ratas (Pokalbių gidas)', () {
    final roots = jausmuRatas.roots;

    test('families clockwise from 12 o\'clock, as in the picture', () {
      expect(
        [for (final r in roots) r.family.name.masculine],
        [
          'nuostaba',
          'džiaugsmas',
          'liūdesys',
          'pasibjaurėjimas',
          'pyktis',
          'baimė',
        ],
      );
    });

    test('6 / 41 / 82 words, two outer words under every middle word', () {
      expect([for (final r in roots) r.children.length], [4, 9, 10, 4, 8, 6]);
      final middle = [for (final r in roots) ...r.children];
      expect(middle, hasLength(41));
      expect(middle.every((m) => m.children.length == 2), isTrue);
      expect(middle.expand((m) => m.children), hasLength(82));
    });

    test('every word comes from the Pokalbių gidas picture', () {
      expect(
        jausmuRatas.feelings.every((f) => f.src == 'pokalbiu-gidas'),
        isTrue,
      );
    });
  });

  group('Plutchiko gėlė', () {
    test('8 petals in Plutchik order, mild → basic → intense', () {
      expect(
        [for (final p in plutchik.petals) p.family.en],
        [
          'Joy',
          'Trust',
          'Fear',
          'Surprise',
          'Sadness',
          'Disgust',
          'Anger',
          'Anticipation',
        ],
      );
      final words = plutchik.feelings.map((f) => f.key).toSet();
      expect(words, hasLength(32), reason: '24 petal words + 8 dyads');
    });

    test('dyads join neighbours; opposites are four petals apart', () {
      for (var i = 0; i < plutchik.dyads.length; i++) {
        expect(plutchik.dyads[i].a, i);
        expect(plutchik.dyads[i].b, (i + 1) % 8);
      }
      expect(
        plutchik.petals[plutchik.opposite(0)].basic.word.masculine,
        'liūdesys',
      );
      expect(
        plutchik.petals[plutchik.opposite(2)].basic.word.masculine,
        'pyktis',
      );
    });
  });

  group('Energija ir malonumas', () {
    test('every word sits inside the circle and in its own quadrant', () {
      for (final p in energija.points) {
        expect(p.radius, inInclusiveRange(0.3, 1.0), reason: p.feeling.id);
        final q = energija.quadrantAt(p.valence, p.arousal);
        expect(
          p.feeling.familyId,
          energija.quadrants[q].id,
          reason: p.feeling.id,
        );
      }
    });

    test('nearest words come back nearest first', () {
      final ramus = energija.points.firstWhere((p) => p.feeling.key == 'ramus');
      final near = energija.nearest(ramus.valence, ramus.arousal);
      expect(near.first.feeling.key, 'ramus');
      expect(near, hasLength(4));
    });
  });

  group('Jausmų šeimos', () {
    test('six families with Meilė; 25 secondary words like Parrott', () {
      expect(
        [for (final r in jausmuSeimos.roots) r.family.name.masculine],
        ['meilė', 'džiaugsmas', 'nuostaba', 'pyktis', 'liūdesys', 'baimė'],
      );
      expect(jausmuSeimos.roots.expand((r) => r.children), hasLength(25));
    });

    test('no word repeats its parent', () {
      for (final r in jausmuSeimos.roots) {
        for (final m in r.children) {
          expect(m.feeling.key, isNot(r.core.key));
          for (final o in m.children) {
            expect(o.feeling.key, isNot(m.feeling.key));
          }
        }
      }
    });
  });
}
