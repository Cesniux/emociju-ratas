import 'package:emociju_ratas/data/jausmu_ratas.dart';
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
}
