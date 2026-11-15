// All short interface text in one place (Lithuanian, "tu").

abstract final class S {
  static const appName = 'Emocijų ratas';

  // Home
  static const prompt = 'Kaip dabar jautiesi?';
  static const howToUse = 'Kaip naudotis';
  static const wheelPillHint = 'Pakeisti ratą';
  static const resetZoom = 'Atstatyti';
  static const familyHint = 'Atveria šios šeimos žodžius';
  static String chosenValue(int n) => 'Pasirinkta: $n';

  // Tray
  static const trayEmpty = 'Čia atsiras žodžiai, kuriuos pasirinksi.';
  static const trayTitle = 'Tavo žodžiai';
  static const clear = 'Išvalyti';
  static const cleared = 'Žodžiai išvalyti.';
  static const undo = 'Atšaukti';
  static String remove(String word) => 'Pašalinti „$word“';

  // Sheet
  static const close = 'Uždaryti';
  static const formQuestion = 'Kaip tau patogiau?';
  static const formMasculine = 'pavargęs';
  static const formFeminine = 'pavargusi';
  static const chosen = 'pasirinkta';
  static const generalFeeling = 'Bendras jausmas';
  static const plutchikLadder = 'Nuo silpno iki stipraus';
  static const plutchikMixes = 'Mišiniai su kaimynais';
  static const plutchikOpposite = 'Priešingybė';
  static const showOpposite = 'Rodyti priešingą jausmą';
  static const nearYourPoint = 'Arti tavo taško';
  static const nearYourPointHint =
      'Pasirink žodį, kuris tinka. Gali paliesti ratą dar kartą kitoje vietoje.';

  // Wheel menu
  static const wheelMenuTitle = 'Kurį ratą naudoti?';
  static const wordFormTitle = 'Kaip apie save kalbi?';
  static const selectedWheel = 'Naudojamas dabar';

  // Reading page
  static const sources = 'Šaltiniai';
  static const call = 'Skambinti';
  static const callFailed = 'Nepavyko atidaryti skambinimo. Numeris:';
  static const linkFailed = 'Nepavyko atidaryti nuorodos:';
}

/// Lithuanian plural: 1 žodis, 2 žodžiai, 10 žodžių, 21 žodis.
String ltPlural(int n, String one, String few, String many) {
  final mod10 = n % 10;
  final mod100 = n % 100;
  if (mod10 == 1 && mod100 != 11) return one;
  if (mod10 >= 2 && mod10 <= 9 && (mod100 < 11 || mod100 > 19)) return few;
  return many;
}
