// All short interface text in one place (Lithuanian, "tu").

abstract final class S {
  static const appName = 'Emocijų ratas';

  // Home
  static const prompt = 'Kaip dabar jautiesi?';
  static const howToUse = 'Kaip naudotis';
  static const changeWheel = 'Keisti ratą';
  static const settings = 'Nustatymai';
  static const back = 'Grįžti';
  static const resetZoom = 'Atstatyti';

  // Word form
  static const formMasculine = 'pavargęs';
  static const formFeminine = 'pavargusi';

  // Wheel menu
  static const wheelMenuTitle = 'Kurį ratą naudoti?';
  static const wordFormTitle = 'Kaip apie save kalbi?';
  static const selectedWheel = 'Naudojamas dabar';
  static const themeTitle = 'Spalvos';
  static const themeLight = 'Šviesios';
  static const themeDark = 'Tamsios';
  static const themeSystem = 'Kaip telefone';

  // Reading page
  static const sources = 'Šaltiniai';
  static const openSite = 'Atidaryti svetainę';
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
