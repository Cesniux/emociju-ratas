import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'app.dart';
import 'state/app_settings.dart';
import 'state/selection.dart';
import 'state/settings_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(await bootstrap());
}

/// Reads the saved wheel before the first frame, so the app opens straight
/// onto it (no flash of another wheel).
Future<Widget> bootstrap({SettingsStore? store}) async {
  _registerFontLicences();
  final settingsStore = store ?? await PrefsSettingsStore.load();
  return EmocijuRatasApp(
    settings: AppSettings(settingsStore),
    selection: Selection(),
  );
}

bool _licencesRegistered = false;

void _registerFontLicences() {
  if (_licencesRegistered) return;
  _licencesRegistered = true;
  LicenseRegistry.addLicense(() async* {
    const fonts = {
      'Atkinson Hyperlegible Next':
          'assets/fonts/AtkinsonHyperlegibleNext-OFL.txt',
      'Lora': 'assets/fonts/Lora-OFL.txt',
    };
    for (final entry in fonts.entries) {
      yield LicenseEntryWithLineBreaks([
        entry.key,
      ], await rootBundle.loadString(entry.value));
    }
  });
}
