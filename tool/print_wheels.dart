// Prints every wheel's words as Markdown for proofreading:
//   ~/fvm/versions/3.44.0/bin/dart run tool/print_wheels.dart > design/WORDS.md
// Pure Dart: only imports lib/data.

import 'package:emociju_ratas/data/models.dart';
import 'package:emociju_ratas/data/sources.dart';
import 'package:emociju_ratas/data/wheels.dart';

void main() {
  final out = StringBuffer()
    ..writeln('# Žodžiai visuose ratuose')
    ..writeln()
    ..writeln('Sugeneruota iš `lib/data/` (`dart run tool/print_wheels.dart`). '
        'Kiekvienas žodis paimtas iš esamo lietuviško rato ar sąrašo '
        '(stulpelis „Šaltinis“). Moteriškos formos sudarytos gramatiškai. '
        'Stulpelis „EN“ rodo, kurį originalo žodį atitinka, ir programėlėje '
        'nerodomas.')
    ..writeln();

  final notes = <String>[];

  for (final wheel in allWheels) {
    out
      ..writeln('## ${wheel.title}')
      ..writeln()
      ..writeln('${wheel.byline}. ${wheel.whenToUse}')
      ..writeln()
      ..writeln('| Lygis | Vyr. | Mot. | EN | Šaltinis | Pastaba |')
      ..writeln('|---|---|---|---|---|---|');

    void row(String level, Feeling f) {
      final w = f.word;
      out.writeln('| $level | ${w.masculine} | '
          '${w.isGendered ? w.feminine : '·'} | ${f.en ?? ''} | '
          '${wordSources[f.src]?.name ?? f.src} | ${f.note ?? ''} |');
      if (f.note != null) notes.add('${wheel.title}: **${w.masculine}**. ${f.note}');
    }

    switch (wheel) {
      case SunburstWheel(:final roots):
        for (final r in roots) {
          row('**šeima**', r.core);
          for (final m in r.children) {
            row('vidurys', m.feeling);
            for (final o in m.children) {
              row('kraštas', o.feeling);
            }
          }
        }
      case PetalWheel(:final petals, :final dyads):
        for (final p in petals) {
          row('silpnas', p.mild);
          row('**pagrindinis**', p.basic);
          row('stiprus', p.intense);
        }
        for (final d in dyads) {
          row('mišinys ${petals[d.a].basic.word.masculine} + '
              '${petals[d.b].basic.word.masculine}', d.feeling);
        }
      case CircumplexWheel(:final points):
        for (final p in points) {
          row('${p.clockDeg.round()}°, ${p.radius}', p.feeling);
        }
    }
    out.writeln();
  }

  if (notes.isNotEmpty) {
    out
      ..writeln('## Pakeitimai ir abejonės')
      ..writeln();
    for (final n in notes) {
      out.writeln('- $n');
    }
    out.writeln();
  }

  out
    ..writeln('## Šaltiniai')
    ..writeln();
  for (final s in wordSources.values) {
    out.writeln('- **${s.name}**. ${s.description}'
        '${s.url == null ? '' : ' ${s.url}'}');
  }

  // ignore: avoid_print
  print(out.toString().trimRight());
}
