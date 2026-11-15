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
        'Emocijų ratas „Kaip dabar jautiesi?“, lietuviška G. Roberts '
        'jausmų rato versija. Paveikslėlis buvo programėlėje.',
  ),
  'lt-plutchik': WordSourceInfo(
    id: 'lt-plutchik',
    name: 'R. Plutchiko emocijų ratas (lietuviškas)',
    description:
        'Lietuviškas R. Plutchiko rato paveikslėlis, buvęs programėlėje.',
  ),
  'lengvos-mintys': WordSourceInfo(
    id: 'lengvos-mintys',
    name: 'Lengvos mintys',
    description: 'Emocijų ratas (lengvosmintys.lt), buvęs programėlėje.',
    url: 'https://www.lengvosmintys.lt',
  ),
};
