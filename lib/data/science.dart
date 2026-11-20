// The "Kaip naudotis" reading page: short cards, honest claims, sources.
// Pure Dart. Every claim is as strong as its source, no stronger
// (design/RATIONALE.md). Help lines checked on pagalbasau.lt, 2026-11-14.

final class Reference {
  const Reference(this.id, this.text, {this.doi, this.url});

  final String id;

  /// Authors (year). Title. Journal, volume(issue), pages.
  final String text;
  final String? doi;
  final String? url;

  String? get link => doi != null ? 'https://doi.org/$doi' : url;
}

/// A help line by name. No phone numbers on purpose: a number can change
/// after the app is installed, a website shows the current one.
final class Helpline {
  const Helpline(this.name, this.note, this.url);

  final String name;
  final String note;
  final String url;
}

enum CardKind { text, steps, helplines, wheels, about }

final class GuideCard {
  const GuideCard({
    required this.id,
    required this.title,
    this.kind = CardKind.text,
    this.paragraphs = const [],
    this.refs = const [],
  });

  final String id;
  final String title;
  final CardKind kind;

  /// For [CardKind.steps], one step per entry.
  final List<String> paragraphs;
  final List<String> refs;
}

/// Short descriptions of each wheel, keyed by wheel id.
const wheelStories = <String, String>{
  'jausmu-ratas':
      'Lietuviška „Pokalbių gido“ versija. Ji sukurta pagal G. Roberts '
      '(2015) ratą, o šis remiasi G. Willcox (1982) „Jausmų ratu“. '
      'Viduryje bendras jausmas, kraštuose vis tikslesni žodžiai.',
  'plutchik':
      'R. Plutchik (1980) aštuonias pagrindines emocijas išdėstė kaip gėlės '
      'žiedlapius. Arčiau vidurio jos stipresnės, kraštuose švelnesnės, '
      'o tarp žiedlapių randasi jų mišiniai. Priešingos emocijos yra '
      'viena prieš kitą.',
  'energija':
      'J. Russell (1980) jausmus aprašė dviem klausimais: kiek malonu ir '
      'kiek energijos. Kai žodžio dar nėra, rask vietą, kuri tinka tavo '
      'būsenai: šalia jos ir bus artimiausi žodžiai.',
  'jausmu-seimos':
      'P. Shaver ir kolegos (1987) paprašė žmonių sugrupuoti 135 jausmų '
      'žodžius ir rado šešias šeimas: meilę, džiaugsmą, nuostabą, pyktį, '
      'liūdesį ir baimę. W. G. Parrott (2001) jas sudėjo į medį. Čia '
      'lietuviška adaptacija iš esamų lietuviškų jausmų sąrašų.',
};

const helplines = <Helpline>[
  Helpline(
    'Skubi pagalba',
    'Kai gresia pavojus sau ar kitiems.',
    'https://112.lt/',
  ),
  Helpline('Vilties linija', 'Suaugusiems.', 'https://www.viltieslinija.lt/'),
  Helpline('Jaunimo linija', 'Jaunimui.', 'https://jaunimolinija.lt/'),
  Helpline(
    'Vaikų linija',
    'Vaikams ir paaugliams.',
    'https://www.vaikulinija.lt/',
  ),
];

const helplinesAllUrl = 'https://pagalbasau.lt/gauk-pagalba/pagalbos-linijos/';

const guideCards = <GuideCard>[
  GuideCard(
    id: 'kaip',
    title: 'Kaip naudotis ratu',
    kind: CardKind.steps,
    paragraphs: [
      'Sustok akimirkai. Lėtai įkvėpk ir dar lėčiau iškvėpk.',
      'Pradėk nuo vidurio: kuri spalva arčiausiai to, ką dabar jauti?',
      'Eik link krašto: ten tikslesni žodžiai. Jei jie smulkūs, priartink '
          'ratą dviem pirštais.',
      'Rask žodį, kuris tinka. Jei tinka keli, tai irgi gerai.',
      'Pastebėk, kur tą jausmą jauti kūne: krūtinėje, pilve, pečiuose.',
      'Pasakyk sau „Jaučiu…“. Jei nori, užsirašyk.',
    ],
    refs: ['zaccaro2018', 'laborde2022', 'nummenmaa2014', 'frattaroli2006'],
  ),
  GuideCard(
    id: 'sunku',
    title: 'Jei labai sunku',
    kind: CardKind.helplines,
    paragraphs: [
      'Ratas padeda pastebėti jausmus, bet negydo ir nediagnozuoja. Jei '
          'sunku jau kelias savaites arba jausmai trukdo gyventi, pasikalbėk '
          'su šeimos gydytoju ar psichologu.',
      'Jei sunku dabar, kreipkis į pagalbos liniją. Paliesk jos pavadinimą: '
          'atsivers svetainė, kurioje rasi, kaip susisiekti.',
    ],
    refs: ['bakker2016'],
  ),
  GuideCard(
    id: 'kodel',
    title: 'Kodėl verta pavadinti jausmą',
    paragraphs: [
      'Kai stiprų jausmą pavadini žodžiu, jis dažnai šiek tiek atvėsta. '
          'Tyrimuose smegenų pavojaus centras reagavo silpniau, kai žmonės '
          'įvardydavo, ką jaučia, o baimės tyrime kūnas po savaitės reagavo '
          'ramiau.',
      'Stebuklo čia nėra. Lengvam jausmui įvardijimas gali ir nepadėti, o '
          'gerų akimirkų geriau neanalizuoti, tiesiog jomis pasidžiaugti.',
    ],
    refs: [
      'lieberman2007',
      'kircanski2012',
      'torre2018',
      'levygigi2022',
      'lyubomirsky2006',
    ],
  ),
  GuideCard(
    id: 'tikslumas',
    title: 'Tikslesnis žodis padeda',
    paragraphs: [
      'Žmonės, kurie jausmus skiria smulkiau (ne tik „blogai“, bet '
          '„nusivylimas“ ar „vienatvė“), dažniau ir sėkmingiau juos tvarko, o '
          'patirdami stresą rečiau griebiasi to, kas kenkia.',
      'Tai ryšys, ne įrodyta priežastis, ir jis nedidelis. Bet žodis rankoje '
          'retai būna nereikalingas.',
    ],
    refs: [
      'barrett2001',
      'kalokerinos2019',
      'kashdan2015',
      'seah2022',
      'demiralp2012',
      'starr2020',
      'dejonckheere2019',
    ],
  ),
  GuideCard(
    id: 'ismokti',
    title: 'To galima išmokti',
    paragraphs: [
      'Jausmų žodyną galima praturtinti. Trumpos pamokos apie jausmų '
          'žodžius ir žodžių sąrašai prieš akis padėjo žmonėms jausmus skirti '
          'tiksliau. Panašiai veikia ir dažnas klausimas sau „kaip '
          'jaučiuosi?“.',
      'Ratas čia praverčia, nes žodį atpažinti lengviau nei jį prisiminti. '
          'Maždaug vienam iš dešimties suaugusiųjų jausmus įvardyti sunku, ir '
          'tai visai žmogiška.',
      'Tyrimų, kurie tikrintų patį emocijų ratą, dar beveik nėra. Todėl '
          'ratas čia tik žodžių pagalbininkas.',
    ],
    refs: [
      'vedernikova2021',
      'seah2025',
      'hoemann2021',
      'widdershoven2019',
      'budiu2014',
      'mattila2006',
      'franz2008',
      'bruno2024',
    ],
  ),
  GuideCard(
    id: 'keli',
    title: 'Keli jausmai vienu metu',
    paragraphs: [
      'Galima jausti ir džiaugsmą, ir liūdesį kartu, pavyzdžiui, '
          'atsisveikinant. Mišrūs jausmai būna dažnai, todėl rate gali '
          'rasti ne vieną savo žodį.',
    ],
    refs: ['larsen2011', 'berrios2015'],
  ),
  GuideCard(
    id: 'praeina',
    title: 'Jausmai praeina',
    paragraphs: [
      'Jausmai keičiasi. Nuostaba, baimė ar susierzinimas dažniausiai '
          'praeina greitai. Liūdesys užsibūna ilgiausiai, ypač kai vis '
          'grįžtame prie tų pačių minčių.',
    ],
    refs: ['verduyn2015'],
  ),
  GuideCard(
    id: 'ratai',
    title: 'Kuo skiriasi ratai',
    kind: CardKind.wheels,
    paragraphs: [
      'Kiekvienas ratas yra vieno tyrėjo žemėlapis tos pačios vietovės. '
          'Mokslininkai vis dar ginčijasi, ar yra kelios pagrindinės '
          'emocijos, ar smegenys kiekvieną jausmą sudeda iš kūno pojūčių ir '
          'žodžių. Rinkis ratą, su kuriuo lengviau.',
    ],
    refs: [
      'willcox1982',
      'roberts2015',
      'plutchik1980',
      'plutchik2001',
      'russell1980',
      'russell1989',
      'posner2005',
      'shaver1987',
      'parrott2001',
      'barrett2017',
      'lindquist2015',
    ],
  ),
  GuideCard(
    id: 'apie',
    title: 'Apie programėlę',
    kind: CardKind.about,
    paragraphs: [
      'Niekas neišeina iš telefono: nėra paskyros, sekimo ar reklamų. '
          'Programėlė prisimena tik paskutinį ratą ir žodžių formą.',
      'Žodžiai paimti iš esamų lietuviškų emocijų ratų ir jausmų sąrašų.',
    ],
    refs: ['huckvale2019'],
  ),
];

const references = <Reference>[
  Reference(
    'zaccaro2018',
    'Zaccaro, A. ir kt. (2018). How breath-control can change your life: a '
        'systematic review on psycho-physiological correlates of slow '
        'breathing. Frontiers in Human Neuroscience, 12, 353.',
    doi: '10.3389/fnhum.2018.00353',
  ),
  Reference(
    'laborde2022',
    'Laborde, S. ir kt. (2022). Effects of voluntary slow breathing on heart '
        'rate and heart rate variability. Neuroscience & Biobehavioral '
        'Reviews, 138, 104711.',
    doi: '10.1016/j.neubiorev.2022.104711',
  ),
  Reference(
    'nummenmaa2014',
    'Nummenmaa, L., Glerean, E., Hari, R., Hietanen, J. K. (2014). Bodily '
        'maps of emotions. PNAS, 111(2), 646–651.',
    doi: '10.1073/pnas.1321664111',
  ),
  Reference(
    'frattaroli2006',
    'Frattaroli, J. (2006). Experimental disclosure and its moderators: a '
        'meta-analysis. Psychological Bulletin, 132(6), 823–865.',
    doi: '10.1037/0033-2909.132.6.823',
  ),
  Reference(
    'bakker2016',
    'Bakker, D., Kazantzis, N., Rickwood, D., Rickard, N. (2016). Mental '
        'health smartphone apps: review and evidence-based recommendations for '
        'future developments. JMIR Mental Health, 3(1), e7.',
    doi: '10.2196/mental.4984',
  ),
  Reference(
    'lieberman2007',
    'Lieberman, M. D. ir kt. (2007). Putting feelings into words: affect '
        'labeling disrupts amygdala activity in response to affective stimuli. '
        'Psychological Science, 18(5), 421–428.',
    doi: '10.1111/j.1467-9280.2007.01916.x',
  ),
  Reference(
    'kircanski2012',
    'Kircanski, K., Lieberman, M. D., Craske, M. G. (2012). Feelings into '
        'words: contributions of language to exposure therapy. Psychological '
        'Science, 23(10), 1086–1091.',
    doi: '10.1177/0956797612443830',
  ),
  Reference(
    'torre2018',
    'Torre, J. B., Lieberman, M. D. (2018). Putting feelings into words: '
        'affect labeling as implicit emotion regulation. Emotion Review, 10(2), '
        '116–124.',
    doi: '10.1177/1754073917742706',
  ),
  Reference(
    'levygigi2022',
    'Levy-Gigi, E., Shamay-Tsoory, S. (2022). Affect labeling: the role of '
        'timing and intensity. PLoS ONE, 17(12), e0279303.',
    doi: '10.1371/journal.pone.0279303',
  ),
  Reference(
    'lyubomirsky2006',
    'Lyubomirsky, S., Sousa, L., Dickerhoof, R. (2006). The costs and '
        'benefits of writing, talking, and thinking about life\'s triumphs and '
        'defeats. Journal of Personality and Social Psychology, 90(4), 692–708.',
    doi: '10.1037/0022-3514.90.4.692',
  ),
  Reference(
    'barrett2001',
    'Barrett, L. F., Gross, J., Christensen, T. C., Benvenuto, M. (2001). '
        'Knowing what you\'re feeling and knowing what to do about it. '
        'Cognition and Emotion, 15(6), 713–724.',
    doi: '10.1080/02699930143000239',
  ),
  Reference(
    'kalokerinos2019',
    'Kalokerinos, E. K., Erbas, Y., Ceulemans, E., Kuppens, P. (2019). '
        'Differentiate to regulate. Psychological Science, 30(6), 863–879.',
    doi: '10.1177/0956797619838763',
  ),
  Reference(
    'kashdan2015',
    'Kashdan, T. B., Barrett, L. F., McKnight, P. E. (2015). Unpacking '
        'emotion differentiation. Current Directions in Psychological Science, '
        '24(1), 10–16.',
    doi: '10.1177/0963721414550708',
  ),
  Reference(
    'seah2022',
    'Seah, T. H. S., Coifman, K. G. (2022). Emotion differentiation and '
        'behavioral dysregulation in clinical and nonclinical samples: a '
        'meta-analysis. Emotion, 22(7), 1686–1697.',
    doi: '10.1037/emo0000968',
  ),
  Reference(
    'demiralp2012',
    'Demiralp, E. ir kt. (2012). Feeling blue or turquoise? Emotional '
        'differentiation in major depressive disorder. Psychological Science, '
        '23(11), 1410–1416.',
    doi: '10.1177/0956797612444903',
  ),
  Reference(
    'starr2020',
    'Starr, L. R. ir kt. (2020). The perils of murky emotions: emotion '
        'differentiation moderates the prospective relationship between '
        'naturalistic stress exposure and adolescent depression. Emotion, '
        '20(6), 927–938.',
    doi: '10.1037/emo0000630',
  ),
  Reference(
    'dejonckheere2019',
    'Dejonckheere, E. ir kt. (2019). Complex affect dynamics add limited '
        'information to the prediction of psychological well-being. Nature '
        'Human Behaviour, 3(5), 478–491.',
    doi: '10.1038/s41562-019-0555-0',
  ),
  Reference(
    'vedernikova2021',
    'Vedernikova, E., Kuppens, P., Erbas, Y. (2021). From knowledge to '
        'differentiation: increasing emotion knowledge through an intervention '
        'increases negative emotion differentiation. Frontiers in Psychology, '
        '12, 703757.',
    doi: '10.3389/fpsyg.2021.703757',
  ),
  Reference(
    'seah2025',
    'Seah, T. H. S., Coifman, K. G. (2025). Effects of scaffolding emotion '
        'language use on emotion differentiation and psychological health. '
        'Cognition and Emotion, 39(7), 1719–1736.',
    doi: '10.1080/02699931.2024.2382334',
  ),
  Reference(
    'hoemann2021',
    'Hoemann, K., Barrett, L. F., Quigley, K. S. (2021). Emotional '
        'granularity increases with intensive ambulatory assessment. Frontiers '
        'in Psychology, 12, 704125.',
    doi: '10.3389/fpsyg.2021.704125',
  ),
  Reference(
    'widdershoven2019',
    'Widdershoven, R. L. A. ir kt. (2019). Effect of self-monitoring '
        'through experience sampling on emotion differentiation in depression. '
        'Journal of Affective Disorders, 244, 71–77.',
    doi: '10.1016/j.jad.2018.10.092',
  ),
  Reference(
    'budiu2014',
    'Budiu, R. (2014). Memory recognition and recall in user interfaces. '
        'Nielsen Norman Group.',
    url: 'https://www.nngroup.com/articles/recognition-and-recall/',
  ),
  Reference(
    'mattila2006',
    'Mattila, A. K., Salminen, J. K., Nummi, T., Joukamaa, M. (2006). Age '
        'is strongly associated with alexithymia in the general population. '
        'Journal of Psychosomatic Research, 61(5), 629–635.',
    doi: '10.1016/j.jpsychores.2006.04.013',
  ),
  Reference(
    'franz2008',
    'Franz, M. ir kt. (2008). Alexithymia in the German general '
        'population. Social Psychiatry and Psychiatric Epidemiology, 43(1), '
        '54–62.',
    doi: '10.1007/s00127-007-0265-1',
  ),
  Reference(
    'bruno2024',
    'Bruno, L., Iborra Cuéllar, A., Pasikowski, S., Lindquist, K. A. '
        '(2024). EMOTONGUE, a smartphone application designed to promote '
        'awareness and emotional self-regulation. Pulso, 47, 97–125.',
    doi: '10.58265/pulso.6633',
  ),
  Reference(
    'larsen2011',
    'Larsen, J. T., McGraw, A. P. (2011). Further evidence for mixed '
        'emotions. Journal of Personality and Social Psychology, 100(6), '
        '1095–1110.',
    doi: '10.1037/a0021846',
  ),
  Reference(
    'berrios2015',
    'Berrios, R., Totterdell, P., Kellett, S. (2015). Eliciting mixed '
        'emotions: a meta-analysis comparing models, types, and measures. '
        'Frontiers in Psychology, 6, 428.',
    doi: '10.3389/fpsyg.2015.00428',
  ),
  Reference(
    'verduyn2015',
    'Verduyn, P., Lavrijsen, S. (2015). Which emotions last longest and '
        'why: the role of event importance and rumination. Motivation and '
        'Emotion, 39, 119–127.',
    doi: '10.1007/s11031-014-9445-y',
  ),
  Reference(
    'willcox1982',
    'Willcox, G. (1982). The Feeling Wheel: a tool for expanding awareness '
        'of emotions and increasing spontaneity and intimacy. Transactional '
        'Analysis Journal, 12(4), 274–276.',
    doi: '10.1177/036215378201200411',
  ),
  Reference(
    'roberts2015',
    'Roberts, G. (2015). The Feelings Wheel ("I feel": emotional word '
        'wheel).',
    url: 'https://imgur.com/tCWChf6',
  ),
  Reference(
    'plutchik1980',
    'Plutchik, R. (1980). Emotion: a psychoevolutionary synthesis. Harper '
        '& Row.',
  ),
  Reference(
    'plutchik2001',
    'Plutchik, R. (2001). The nature of emotions. American Scientist, '
        '89(4), 344–350.',
    doi: '10.1511/2001.4.344',
  ),
  Reference(
    'russell1980',
    'Russell, J. A. (1980). A circumplex model of affect. Journal of '
        'Personality and Social Psychology, 39(6), 1161–1178.',
    doi: '10.1037/h0077714',
  ),
  Reference(
    'russell1989',
    'Russell, J. A., Weiss, A., Mendelsohn, G. A. (1989). Affect Grid: a '
        'single-item scale of pleasure and arousal. Journal of Personality and '
        'Social Psychology, 57(3), 493–502.',
    doi: '10.1037/0022-3514.57.3.493',
  ),
  Reference(
    'posner2005',
    'Posner, J., Russell, J. A., Peterson, B. S. (2005). The circumplex '
        'model of affect. Development and Psychopathology, 17(3), 715–734.',
    doi: '10.1017/S0954579405050340',
  ),
  Reference(
    'shaver1987',
    'Shaver, P., Schwartz, J., Kirson, D., O\'Connor, C. (1987). Emotion '
        'knowledge: further exploration of a prototype approach. Journal of '
        'Personality and Social Psychology, 52(6), 1061–1086.',
    doi: '10.1037/0022-3514.52.6.1061',
  ),
  Reference(
    'parrott2001',
    'Parrott, W. G. (Red.) (2001). Emotions in social psychology: essential '
        'readings. Psychology Press.',
  ),
  Reference(
    'barrett2017',
    'Barrett, L. F. (2017). The theory of constructed emotion. Social '
        'Cognitive and Affective Neuroscience, 12(1), 1–23.',
    doi: '10.1093/scan/nsw154',
  ),
  Reference(
    'lindquist2015',
    'Lindquist, K. A., MacCormack, J. K., Shablack, H. (2015). The role of '
        'language in emotion: predictions from psychological constructionism. '
        'Frontiers in Psychology, 6, 444.',
    doi: '10.3389/fpsyg.2015.00444',
  ),
  Reference(
    'huckvale2019',
    'Huckvale, K., Torous, J., Larsen, M. E. (2019). Assessment of the data '
        'sharing and privacy practices of smartphone apps for depression and '
        'smoking cessation. JAMA Network Open, 2(4), e192542.',
    doi: '10.1001/jamanetworkopen.2019.2542',
  ),
];

/// 1-based number of a reference in the list.
int referenceNumber(String id) => references.indexWhere((r) => r.id == id) + 1;
