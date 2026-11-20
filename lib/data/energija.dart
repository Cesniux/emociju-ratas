// Energija ir malonumas: J. Russell's circumplex of affect (1980), drawn as
// the one-point Affect Grid idea (Russell, Weiss & Mendelsohn 1989) on a
// circle, with Posner, Russell & Peterson (2005) for "alert" and "upset".
//
// Angles follow the order of Russell 1980 Fig. 2 (converted to clock angles:
// 0° = most energy at the top, 90° = most pleasant on the right), spread a
// little so every word stays readable on a phone.
//
// Lithuanian words: the Lithuanian PANAS-X (Petraškaitė & Grigutytė 2022,
// Vilnius University), plus "patenkintas" from the Lithuanian edition of
// Rosenberg's book and "nuobodžiaujantis" from lengvos mintys.

import 'models.dart';

Family _q(String slug, String name, FamilyHue hue, String signal) => Family(
  id: 'energija/$slug',
  name: LtWord.noun(name),
  hue: hue,
  signal: signal,
);

final _energeticPleasant = _q(
  'daug-energijos-malonu',
  'daug energijos, malonu',
  FamilyHue.yellow,
  'Gyvumas ir džiaugsmas. Gera būsena veikti ir bendrauti.',
);
final _calmPleasant = _q(
  'mazai-energijos-malonu',
  'mažai energijos, malonu',
  FamilyHue.sage,
  'Ramybė ir pasitenkinimas. Gera būsena ilsėtis ir tiesiog būti.',
);
final _calmUnpleasant = _q(
  'mazai-energijos-nemalonu',
  'mažai energijos, nemalonu',
  FamilyHue.blue,
  'Nuovargis ar liūdesys. Kūnas ir galva prašo poilsio ir šilumos.',
);
final _energeticUnpleasant = _q(
  'daug-energijos-nemalonu',
  'daug energijos, nemalonu',
  FamilyHue.mauve,
  'Įtampa, nerimas ar pyktis. Kūnas pasiruošęs gintis.',
);

final _quadrants = [
  _energeticPleasant,
  _calmPleasant,
  _calmUnpleasant,
  _energeticUnpleasant,
];

PlacedFeeling _p(
  String masculine,
  String feminine,
  String en,
  double clock,
  double radius, {
  String src = 'panas-x-lt',
}) {
  final quadrant = clock < 90
      ? _energeticPleasant
      : clock < 180
      ? _calmPleasant
      : clock < 270
      ? _calmUnpleasant
      : _energeticUnpleasant;
  return PlacedFeeling(
    Feeling(
      id: 'energija/${slugOf(masculine)}',
      word: LtWord(masculine, feminine),
      familyId: quadrant.id,
      src: src,
      en: en,
    ),
    clockDeg: clock,
    radius: radius,
  );
}

final CircumplexWheel energija = CircumplexWheel(
  id: 'energija',
  title: 'Energija ir malonumas',
  byline: 'J. Russell, 1980',
  whenToUse: 'Kai žodžio dar nėra. Pradėk nuo to, ką jauti kūne.',
  hint:
      'Paklausk kūno, kiek jame jėgų. Aukščiau daugiau energijos, dešiniau maloniau.',
  quadrants: _quadrants,
  points: [
    _p('atidus', 'atidi', 'alert', 8, 0.60),
    _p('nustebęs', 'nustebusi', 'surprised', 21, 0.94),
    _p('entuziastingas', 'entuziastinga', 'enthusiastic', 46, 0.93),
    _p('linksmas', 'linksma', 'merry', 62, 0.66),
    _p('laimingas', 'laiminga', 'happy', 74, 0.93),
    _p('patenkintas', 'patenkinta', 'content', 116, 0.94, src: 'rosenberg-lt'),
    _p('atsipalaidavęs', 'atsipalaidavusi', 'relaxed', 132, 0.64),
    _p('ramus', 'rami', 'calm', 148, 0.94),
    _p('mieguistas', 'mieguista', 'sleepy', 166, 0.62),
    _p('pavargęs', 'pavargusi', 'tired', 193, 0.93),
    _p(
      'nuobodžiaujantis',
      'nuobodžiaujanti',
      'bored',
      220,
      0.95,
      src: 'lengvos-mintys',
    ),
    _p('prislėgtas', 'prislėgta', 'depressed', 236, 0.62),
    _p('liūdnas', 'liūdna', 'sad', 250, 0.94),
    _p('nusiminęs', 'nusiminusi', 'upset', 262, 0.66),
    _p('nerimaujantis', 'nerimaujanti', 'nervous', 290, 0.94),
    _p('susierzinęs', 'susierzinusi', 'irritable', 304, 0.62),
    _p('išsigandęs', 'išsigandusi', 'afraid', 318, 0.94),
    _p('piktas', 'pikta', 'angry', 334, 0.64),
    _p('įsitempęs', 'įsitempusi', 'tense', 348, 0.93),
  ],
);
