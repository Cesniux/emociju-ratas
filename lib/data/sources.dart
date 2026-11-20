// Where every Lithuanian feeling word comes from. The owner's rule: words are
// taken from existing Lithuanian wheels and feeling lists, never translated
// by us. Feminine forms are grammatical forms of those words.

final class WordSourceInfo {
  const WordSourceInfo({
    required this.id,
    required this.name,
    required this.description,
    this.url,
  });

  final String id;
  final String name;
  final String description;
  final String? url;
}

const wordSources = <String, WordSourceInfo>{
  'pokalbiu-gidas': WordSourceInfo(
    id: 'pokalbiu-gidas',
    name: 'Pokalbių gidas',
    description:
        'Emocijų ir jausmų ratas „Kaip dabar jautiesi?“, lietuviška '
        'G. Roberts jausmų rato versija.',
    url: 'https://pokalbiugidas.lt/produktas/emociju-ir-jausmu-ratas/',
  ),
  'lt-plutchik': WordSourceInfo(
    id: 'lt-plutchik',
    name: 'Plutchiko emocijų ratas (verslas.in, 2013)',
    description: 'Lietuviškas R. Plutchiko rato paveikslėlis.',
    url: 'http://www.verslas.in/izvalgos/plutchiko-emociju-ratas/',
  ),
  'lketa': WordSourceInfo(
    id: 'lketa',
    name: 'Psichologė K. Paradnikė, LKETA (2021)',
    description:
        'Plakatas „Jausmai ir emocijos“, Lietuvos kognityvinės ir elgesio '
        'terapijos asociacija.',
    url:
        'https://lketa.lt/wp-content/uploads/2021/08/Emocijos-didelis-a2-lapas.pdf',
  ),
  'vppc': WordSourceInfo(
    id: 'vppc',
    name: 'Psichoterapeutė L. Matulionienė',
    description:
        'Jausmų sąrašas, Vilniaus psichodinaminės psichoterapijos centras.',
    url:
        'https://www.vilniausppc.lt/jausmai-subjektyvus-psichologiniai-patyrimai/',
  ),
  'panas-x-lt': WordSourceInfo(
    id: 'panas-x-lt',
    name: 'Lietuviškas PANAS-X (Vilniaus universitetas, 2022)',
    description:
        'K. Petraškaitė, N. Grigutytė. Nuotaikos skalės žodžiai, '
        'patikrinti tyrime su 322 suaugusiaisiais.',
    url: 'https://doi.org/10.5708/EJMH.17.2022.3.4',
  ),
  'rosenberg-lt': WordSourceInfo(
    id: 'rosenberg-lt',
    name: 'M. B. Rosenberg, „Nesmurtinis bendravimas“',
    description: 'Jausmų sąrašas, leidykla „Meilės kelias“, 2021.',
  ),
  'lengvos-mintys': WordSourceInfo(
    id: 'lengvos-mintys',
    name: 'Lengvos mintys',
    description:
        'Psichologų praktika; emocijų ratas ir straipsnis '
        '„Kas yra emocijos?“ (2019).',
    url: 'https://lengvosmintys.lt/emocijos/',
  ),
};
