// Plutchiko gėlė: R. Plutchik (1980, 2001), 8 petals × mild / basic / intense
// and the 8 primary dyads between neighbours.
//
// Lithuanian words: the Lithuanian Plutchik picture the app used to show
// (verslas.in, 2013). Four words follow the psychologist K. Paradnikė's LKETA
// poster (2021) where the picture stands alone against the other Lithuanian
// sources: priėmimas (picture: susitaikymas), apstulbimas (nustebimas),
// laukimas (nuojauta) and pagarbi baimė (pagarba). See design/WORDS.md.

import 'models.dart';

const _src = 'lt-plutchik';

Family _family(
  String slug,
  String name,
  FamilyHue hue,
  String en,
  String signal,
) => Family(
  id: 'plutchik/$slug',
  name: LtWord.noun(name),
  hue: hue,
  signal: signal,
  en: en,
);

Feeling _f(
  Family family,
  String word,
  String en, {
  String src = _src,
  String? note,
}) => Feeling(
  id: '${family.id}/${slugOf(word)}',
  word: LtWord.noun(word),
  familyId: family.id,
  src: src,
  en: en,
  note: note,
);

final _joy = _family(
  'dziaugsmas',
  'džiaugsmas',
  FamilyHue.yellow,
  'Joy',
  'Ateina, kai kas nors sekasi arba gauni tai, ko norėjai.',
);
final _trust = _family(
  'pasitikejimas',
  'pasitikėjimas',
  FamilyHue.sage,
  'Trust',
  'Leidžia atsiremti į kitą ir jaustis saugiai šalia.',
);
final _fear = _family(
  'baime',
  'baimė',
  FamilyHue.green,
  'Fear',
  'Įspėja apie pavojų ir padeda pasisaugoti.',
);
final _surprise = _family(
  'nuostaba',
  'nuostaba',
  FamilyHue.sky,
  'Surprise',
  'Kyla, kai nutinka kas nors netikėto. Padeda stabtelėti ir pastebėti.',
);
final _sadness = _family(
  'liudesys',
  'liūdesys',
  FamilyHue.blue,
  'Sadness',
  'Ateina, kai ko nors netenki. Kviečia sulėtinti ir pasirūpinti savimi.',
);
final _disgust = _family(
  'pasibjaurejimas',
  'pasibjaurėjimas',
  FamilyHue.mauve,
  'Disgust',
  'Saugo nuo to, kas atrodo žalinga ar nepriimtina.',
);
final _anger = _family(
  'pyktis',
  'pyktis',
  FamilyHue.clay,
  'Anger',
  'Parodo, kad kažkas peržengė ribą arba atrodo neteisinga.',
);
final _anticipation = _family(
  'laukimas',
  'laukimas',
  FamilyHue.orange,
  'Anticipation',
  'Nukreipia dėmesį į tai, kas dar tik ateis.',
);

final PetalWheel plutchik = PetalWheel(
  id: 'plutchik',
  title: 'Plutchiko gėlė',
  byline: 'R. Plutchik, 1980',
  whenToUse: 'Kai nori suprasti, kiek stiprus jausmas ir su kuo jis maišosi.',
  hint: 'Paliesk žiedlapį. Vidurys stipresnis, kraštai švelnesni.',
  petals: [
    Petal(
      _joy,
      _f(_joy, 'ramybė', 'serenity'),
      _f(_joy, 'džiaugsmas', 'joy'),
      _f(_joy, 'ekstazė', 'ecstasy'),
    ),
    Petal(
      _trust,
      _f(
        _trust,
        'priėmimas',
        'acceptance',
        src: 'lketa',
        note: 'Paveiksle „susitaikymas“.',
      ),
      _f(_trust, 'pasitikėjimas', 'trust'),
      _f(_trust, 'susižavėjimas', 'admiration'),
    ),
    Petal(
      _fear,
      _f(_fear, 'nuogąstavimas', 'apprehension'),
      _f(_fear, 'baimė', 'fear'),
      _f(_fear, 'siaubas', 'terror'),
    ),
    Petal(
      _surprise,
      _f(_surprise, 'išsiblaškymas', 'distraction'),
      _f(_surprise, 'nuostaba', 'surprise'),
      _f(
        _surprise,
        'apstulbimas',
        'amazement',
        src: 'lketa',
        note: 'Paveiksle „nustebimas“.',
      ),
    ),
    Petal(
      _sadness,
      _f(_sadness, 'susimąstymas', 'pensiveness'),
      _f(_sadness, 'liūdesys', 'sadness'),
      _f(_sadness, 'sielvartas', 'grief'),
    ),
    Petal(
      _disgust,
      _f(_disgust, 'nuobodulys', 'boredom'),
      _f(_disgust, 'pasibjaurėjimas', 'disgust'),
      _f(_disgust, 'neapykanta', 'loathing'),
    ),
    Petal(
      _anger,
      _f(_anger, 'apmaudas', 'annoyance'),
      _f(_anger, 'pyktis', 'anger'),
      _f(_anger, 'įniršis', 'rage'),
    ),
    Petal(
      _anticipation,
      _f(_anticipation, 'susidomėjimas', 'interest'),
      _f(
        _anticipation,
        'laukimas',
        'anticipation',
        src: 'lketa',
        note: 'Paveiksle „nuojauta“.',
      ),
      _f(_anticipation, 'budrumas', 'vigilance'),
    ),
  ],
  dyads: [
    Dyad(_f(_joy, 'meilė', 'love'), 0),
    Dyad(_f(_trust, 'palankumas', 'submission'), 1),
    Dyad(
      _f(
        _fear,
        'pagarbi baimė',
        'awe',
        src: 'lketa',
        note: 'Paveiksle „pagarba“.',
      ),
      2,
    ),
    Dyad(_f(_surprise, 'nepritarimas', 'disapproval'), 3),
    Dyad(_f(_sadness, 'gailestis', 'remorse'), 4),
    Dyad(_f(_disgust, 'panieka', 'contempt'), 5),
    Dyad(_f(_anger, 'agresyvumas', 'aggressiveness'), 6),
    Dyad(_f(_anticipation, 'optimizmas', 'optimism'), 7),
  ],
);
