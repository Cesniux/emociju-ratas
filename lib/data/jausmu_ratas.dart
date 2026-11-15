// Jausmų ratas: the Lithuanian "Pokalbių gidas" wheel ("Kaip dabar
// jautiesi?"), a Lithuanian version of Geoffrey Roberts' Feelings Wheel (2015),
// itself built on Gloria Willcox's Feeling Wheel (1982).
//
// Words are exactly as in the picture (stored lowercase), clockwise from the
// family at 12 o'clock. Changes from the picture, all listed in
// design/WORDS.md for review:
// - spelling: "smalus" → smalsus, "miegustas" → mieguistas,
//   "frustuotas" → frustruotas, "pažeista" → pažeistas / pažeista;
// - placement: in the picture "vienišas" and "pažeidžiamas" sit under
//   Pasibjaurėjimas; Roberts' wheel has them under sadness, so they are
//   under Liūdesys here.
// English glosses (`en`) are Roberts' words, for review only.

import 'models.dart';

W _w(String masculine, String feminine, String en,
        [List<W> children = const [], String? note]) =>
    W(LtWord(masculine, feminine), en: en, note: note, children: children);

W _n(String noun, String en, [List<W> children = const [], String? note]) =>
    W(LtWord.noun(noun), en: en, note: note, children: children);

final SunburstWheel jausmuRatas = buildSunburst(
  id: 'jausmu-ratas',
  title: 'Jausmų ratas',
  byline: 'Pokalbių gidas, pagal G. Roberts ir G. Willcox',
  whenToUse: 'Kasdien: nuo bendro jausmo iki tikslaus žodžio.',
  hint: 'Paliesk spalvą, kuri arčiausiai to, ką jauti.',
  src: 'pokalbiu-gidas',
  families: [
    F(
      name: const LtWord.noun('nuostaba'),
      hue: FamilyHue.yellow,
      en: 'Surprised',
      signal: 'Kyla, kai nutinka kas nors netikėto. Padeda stabtelėti ir '
          'pastebėti, kas vyksta.',
      children: [
        _w('susijaudinęs', 'susijaudinusi', 'Excited', [
          _w('energingas', 'energinga', 'Energetic'),
          _w('nekantrus', 'nekantri', 'Eager'),
        ]),
        _w('nustebęs', 'nustebusi', 'Amazed', [
          _w('priblokštas', 'priblokšta', 'Astonished'),
          _w('pagarbus', 'pagarbi', 'Awe'),
        ]),
        _w('sumišęs', 'sumišusi', 'Confused', [
          _w('suglumęs', 'suglumusi', 'Perplexed'),
          _w('nusivylęs', 'nusivylusi', 'Disillusioned'),
        ]),
        _w('apstulbęs', 'apstulbusi', 'Startled', [
          _w('šokiruotas', 'šokiruota', 'Shocked'),
          _w('nemaloniai nustebęs', 'nemaloniai nustebusi', 'Dismayed'),
        ]),
      ],
    ),
    F(
      name: const LtWord.noun('džiaugsmas'),
      hue: FamilyHue.olive,
      en: 'Happy',
      signal: 'Ateina, kai kas nors sekasi arba artėji prie to, kas brangu.',
      children: [
        _w('optimistiškas', 'optimistiška', 'Optimistic', [
          _w('įkvėptas', 'įkvėpta', 'Inspired'),
          _w('viltingas', 'viltinga', 'Hopeful'),
        ]),
        _w('pasitikintis', 'pasitikinti', 'Trusting', [
          _w('artimas', 'artima', 'Intimate'),
          _w('jautrus', 'jautri', 'Sensitive'),
        ]),
        _w('ramus', 'rami', 'Peaceful', [
          _w('dėkingas', 'dėkinga', 'Thankful'),
          _w('mylintis', 'mylinti', 'Loving'),
        ]),
        _w('galingas', 'galinga', 'Powerful', [
          _w('kūrybingas', 'kūrybinga', 'Creative'),
          _w('drąsus', 'drąsi', 'Courageous'),
        ]),
        _w('priimtas', 'priimta', 'Accepted', [
          _w('vertinamas', 'vertinama', 'Valued'),
          _w('gerbiamas', 'gerbiama', 'Respected'),
        ]),
        _n('pasididžiavimas', 'Proud', [
          _w('pasitikintis', 'pasitikinti', 'Confident'),
          _w('sėkmingas', 'sėkminga', 'Successful'),
        ]),
        _w('susidomėjęs', 'susidomėjusi', 'Interested', [
          _w('žingeidus', 'žingeidi', 'Inquisitive'),
          _w('smalsus', 'smalsi', 'Curious', const [],
              'Paveiksle parašyta „smalus“.'),
        ]),
        _w('patenkintas', 'patenkinta', 'Content', [
          _w('džiugus', 'džiugi', 'Joyful'),
          _w('laisvas', 'laisva', 'Free'),
        ]),
        _w('žaismingas', 'žaisminga', 'Playful', [
          _w('šelmiškas', 'šelmiška', 'Cheeky'),
          _w('susijaudinęs', 'susijaudinusi', 'Aroused'),
        ]),
      ],
    ),
    F(
      name: const LtWord.noun('liūdesys'),
      hue: FamilyHue.blue,
      en: 'Sad + Bad',
      signal: 'Ateina, kai ko nors netenki ar kažko labai trūksta. Šalia jo '
          'dažnai būna nuovargis ir įtampa.',
      children: [
        _w('nuobodus', 'nuobodi', 'Bored', [
          _w('apatiškas', 'apatiška', 'Apathetic'),
          _w('abejingas', 'abejinga', 'Indifferent'),
        ]),
        _w('apkrautas', 'apkrauta', 'Busy', [
          _w('skubinamas', 'skubinama', 'Rushed'),
          _w('spaudžiamas', 'spaudžiama', 'Pressured'),
        ]),
        _w('stresuojantis', 'stresuojanti', 'Stressed', [
          _w('nekontroliuojantis', 'nekontroliuojanti', 'Out of control'),
          _w('priblokštas', 'priblokšta', 'Overwhelmed'),
        ]),
        _w('pavargęs', 'pavargusi', 'Tired', [
          _w('išsiblaškęs', 'išsiblaškiusi', 'Unfocused'),
          _w('mieguistas', 'mieguista', 'Sleepy', const [],
              'Paveiksle parašyta „miegustas“.'),
        ]),
        _w('įskaudintas', 'įskaudinta', 'Hurt', [
          _w('susigėdęs', 'susigėdusi', 'Embarrassed'),
          _w('nusivylęs', 'nusivylusi', 'Disappointed'),
        ]),
        _w('depresiškas', 'depresiška', 'Depressed', [
          _w('tuščias', 'tuščia', 'Empty'),
          _w('prastas', 'prasta', 'Inferior'),
        ]),
        _w('kaltas', 'kalta', 'Guilty', [
          _w('susigėdęs', 'susigėdusi', 'Ashamed'),
          _w('besigailintis', 'besigailinti', 'Remorseful'),
        ]),
        _n('neviltyje', 'Despair', [
          _w('bejėgis', 'bejėgė', 'Powerless'),
          _w('sielvartaujantis', 'sielvartaujanti', 'Grief'),
        ]),
        _w('pažeidžiamas', 'pažeidžiama', 'Vulnerable', [
          _w('trapus', 'trapi', 'Fragile'),
          _w('silpnas', 'silpna', 'Victimised'),
        ], 'Paveiksle po Pasibjaurėjimu, o Roberts rate po liūdesiu.'),
        _w('vienišas', 'vieniša', 'Lonely', [
          _w('apleistas', 'apleista', 'Abandoned'),
          _w('ignoruojamas', 'ignoruojama', 'Isolated'),
        ], 'Paveiksle po Pasibjaurėjimu, o Roberts rate po liūdesiu.'),
      ],
    ),
    F(
      name: const LtWord.noun('pasibjaurėjimas'),
      hue: FamilyHue.mauve,
      en: 'Disgusted',
      signal: 'Saugo nuo to, kas atrodo žalinga, nešvaru ar nepriimtina.',
      children: [
        _w('atmetantis', 'atmetanti', 'Repelled', [
          _w('abejojantis', 'abejojanti', 'Hesitant'),
          _w('pasibaisėjęs', 'pasibaisėjusi', 'Horrified'),
        ]),
        _w('bjaurus', 'bjauri', 'Awful', [
          _w('niekinantis', 'niekinanti', 'Detestable'),
          _w('šlykštus', 'šlykšti', 'Nauseated'),
        ]),
        _w('nusivylęs', 'nusivylusi', 'Disappointed', [
          _w('maištingas', 'maištinga', 'Revolted'),
          _w('gąsdinantis', 'gąsdinanti', 'Appalled'),
        ]),
        _w('nepritariantis', 'nepritarianti', 'Disapproving', [
          _w('sutrikęs', 'sutrikusi', 'Embarrassed'),
          _w('kritiškas', 'kritiška', 'Judgmental'),
        ]),
      ],
    ),
    F(
      name: const LtWord.noun('pyktis'),
      hue: FamilyHue.clay,
      en: 'Angry',
      signal: 'Dažnai parodo, kad kažkas peržengė ribą arba atrodo '
          'neteisinga.',
      children: [
        _w('vertinantis', 'vertinanti', 'Critical', [
          _w('atstumiantis', 'atstumianti', 'Dismissive'),
          _w('skeptiškas', 'skeptiška', 'Sceptical'),
        ]),
        _w('nutolęs', 'nutolusi', 'Distant', [
          _w('sustingęs', 'sustingusi', 'Numb'),
          _w('atsitraukęs', 'atsitraukusi', 'Withdrawn'),
        ]),
        _w('frustruotas', 'frustruota', 'Frustrated', [
          _w('sudirgęs', 'sudirgusi', 'Annoyed'),
          _w('susierzinęs', 'susierzinusi', 'Infuriated'),
        ], 'Paveiksle parašyta „frustuotas“.'),
        _w('agresyvus', 'agresyvi', 'Aggressive', [
          _w('priešiškas', 'priešiška', 'Hostile'),
          _w('provokuojantis', 'provokuojanti', 'Provoked'),
        ]),
        _w('įniršęs', 'įniršusi', 'Mad', [
          _w('pavydus', 'pavydi', 'Jealous'),
          _w('įsiutęs', 'įsiutusi', 'Furious'),
        ]),
        _w('kandus', 'kandi', 'Bitter', [
          _w('pažeistas', 'pažeista', 'Violated', const [],
              'Paveiksle parašyta „pažeista“.'),
          _w('pasipiktinęs', 'pasipiktinusi', 'Indignant'),
        ]),
        _w('pažemintas', 'pažeminta', 'Humiliated', [
          _w('išjuoktas', 'išjuokta', 'Ridiculed'),
          _w('negerbiamas', 'negerbiama', 'Disrespected'),
        ]),
        _w('nuviltas', 'nuvilta', 'Let down', [
          _w('įsižeidęs', 'įsižeidusi', 'Resentful'),
          _w('išduotas', 'išduota', 'Betrayed'),
        ]),
      ],
    ),
    F(
      name: const LtWord.noun('baimė'),
      hue: FamilyHue.orange,
      en: 'Fearful',
      signal: 'Įspėja, kad kažkas gali būti pavojinga ar nežinoma.',
      children: [
        _w('grėsmingas', 'grėsminga', 'Threatened', [
          _w('pažeidžiamas', 'pažeidžiama', 'Exposed'),
          _w('nervingas', 'nervinga', 'Nervous'),
        ]),
        _w('atstumtas', 'atstumta', 'Rejected', [
          _w('išskirtas', 'išskirta', 'Excluded'),
          _w('persekiojamas', 'persekiojama', 'Persecuted'),
        ]),
        _w('neryžtingas', 'neryžtinga', 'Weak', [
          _w('nesvarbus', 'nesvarbi', 'Insignificant'),
          _w('bevertis', 'bevertė', 'Worthless'),
        ]),
        _w('nesaugus', 'nesaugi', 'Insecure', [
          _w('nepilnavertis', 'nepilnavertė', 'Inferior'),
          _w('netinkamas', 'netinkama', 'Inadequate'),
        ]),
        _w('neramus', 'nerami', 'Anxious', [
          _w('susirūpinęs', 'susirūpinusi', 'Worried'),
          _w('priblokštas', 'priblokšta', 'Overwhelmed'),
        ]),
        _w('išsigandęs', 'išsigandusi', 'Scared', [
          _w('baimingas', 'baiminga', 'Frightened'),
          _w('bejėgis', 'bejėgė', 'Helpless'),
        ]),
      ],
    ),
  ],
);
