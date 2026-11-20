// Jausmų šeimos: the six basic-level feeling families found by Shaver,
// Schwartz, Kirson & O'Connor (1987), who asked people to sort 135 feeling
// words, as arranged into a tree by W. G. Parrott (2001).
//
// Lithuanian adaptation: only nouns found in existing Lithuanian lists are
// used, mostly psychotherapist L. Matulionienė's list (Vilniaus
// psichodinaminės psichoterapijos centras) and psychologist K. Paradnikė's
// LKETA poster; Parrott's near-synonyms with no Lithuanian source are left
// out. As in Shaver's data, disgust sits inside the anger family.

import 'models.dart';

W _n(String noun, String en, {String? src, List<W> children = const []}) =>
    W(LtWord.noun(noun), en: en, src: src, children: children);

final SunburstWheel jausmuSeimos = buildSunburst(
  id: 'jausmu-seimos',
  title: 'Jausmų šeimos',
  byline: 'P. Shaver ir kt., 1987; W. G. Parrott, 2001',
  whenToUse:
      'Ratas, kuriame yra ir meilė. Žodžius į šeimas sudėjo patys žmonės.',
  hint: 'Jausmai gyvena šeimomis. Rask žodį, kuris šiandien tavo.',
  src: 'vppc',
  families: [
    F(
      name: const LtWord.noun('meilė'),
      hue: FamilyHue.rose,
      en: 'Love',
      signal: 'Traukia arčiau. Padeda kurti ryšį ir rūpintis.',
      children: [
        _n(
          'švelnumas',
          'Affection / tenderness',
          children: [
            _n('rūpinimasis', 'caring'),
            _n('atjauta', 'compassion', src: 'lketa'),
          ],
        ),
        _n(
          'aistra',
          'Lust / passion',
          src: 'lketa',
          children: [_n('apsvaigimas', 'infatuation')],
        ),
        _n('ilgesys', 'Longing'),
      ],
    ),
    F(
      name: const LtWord.noun('džiaugsmas'),
      hue: FamilyHue.olive,
      en: 'Joy',
      signal: 'Ateina, kai kas nors sekasi arba artėji prie to, kas brangu.',
      children: [
        _n(
          'džiugesys',
          'Cheerfulness',
          children: [
            _n('laimė', 'happiness'),
            _n('palaima', 'bliss'),
            _n('euforija', 'euphoria'),
            _n('gėrėjimasis', 'delight'),
          ],
        ),
        _n(
          'užsidegimas',
          'Zest',
          children: [_n('energingumas', 'zest / vigour')],
        ),
        _n(
          'pasitenkinimas',
          'Contentment',
          children: [_n('malonumas', 'pleasure')],
        ),
        _n('pasididžiavimas', 'Pride'),
        _n(
          'optimizmas',
          'Optimism',
          src: 'lt-plutchik',
          children: [_n('viltis', 'hope')],
        ),
        _n('susižavėjimas', 'Enthrallment'),
        _n('palengvėjimas', 'Relief'),
      ],
    ),
    F(
      name: const LtWord.noun('nuostaba'),
      hue: FamilyHue.yellow,
      en: 'Surprise',
      signal:
          'Kyla, kai nutinka kas nors netikėto. Padeda stabtelėti ir '
          'pastebėti, kas vyksta.',
      children: [
        _n('apstulbimas', 'amazement'),
        _n('netikėtumas', 'surprise'),
        _n('šokas', 'astonishment / shock'),
      ],
    ),
    F(
      name: const LtWord.noun('pyktis'),
      hue: FamilyHue.clay,
      en: 'Anger',
      signal:
          'Dažnai parodo, kad kažkas peržengė ribą arba atrodo '
          'neteisinga.',
      children: [
        _n(
          'susierzinimas',
          'Irritation',
          children: [_n('apmaudas', 'annoyance')],
        ),
        _n(
          'įniršis',
          'Rage',
          children: [
            _n('įtūžis', 'fury', src: 'lketa'),
            _n('pasipiktinimas', 'outrage'),
            _n('priešiškumas', 'hostility'),
            _n('neapykanta', 'hate'),
          ],
        ),
        _n(
          'pasibjaurėjimas',
          'Disgust',
          src: 'lt-plutchik',
          children: [_n('panieka', 'contempt', src: 'lt-plutchik')],
        ),
        _n('pavydas', 'Envy / jealousy'),
      ],
    ),
    F(
      name: const LtWord.noun('liūdesys'),
      hue: FamilyHue.blue,
      en: 'Sadness',
      signal: 'Ateina, kai ko nors netenki ar kažko labai trūksta.',
      children: [
        _n(
          'neviltis',
          'Despair',
          src: 'lketa',
          children: [
            _n('beviltiškumas', 'hopelessness', src: 'lketa'),
            _n('prislėgtumas', 'depression', src: 'lketa'),
          ],
        ),
        _n(
          'sielvartas',
          'Sorrow / grief',
          children: [_n('susikrimtimas', 'heartache', src: 'lketa')],
        ),
        _n('nusivylimas', 'Disappointment'),
        _n(
          'gėda',
          'Shame',
          children: [
            _n('kaltė', 'guilt'),
            _n('apgailestavimas', 'regret'),
            _n('sąžinės graužimas', 'remorse'),
          ],
        ),
        _n(
          'vienišumas',
          'Neglect / loneliness',
          children: [_n('apleistumas', 'abandonment')],
        ),
        _n('užuojauta', 'Sympathy', children: [_n('pasigailėjimas', 'pity')]),
      ],
    ),
    F(
      name: const LtWord.noun('baimė'),
      hue: FamilyHue.orange,
      en: 'Fear',
      signal: 'Įspėja, kad kažkas gali būti pavojinga ar nežinoma.',
      children: [
        _n(
          'siaubas',
          'Horror',
          children: [_n('panika', 'panic'), _n('išgąstis', 'fright')],
        ),
        _n(
          'nerimas',
          'Nervousness',
          children: [
            _n('įtampa', 'tenseness'),
            _n('nuogąstavimas', 'apprehension', src: 'lketa'),
            _n('susirūpinimas', 'worry', src: 'lketa'),
          ],
        ),
      ],
    ),
  ],
);
