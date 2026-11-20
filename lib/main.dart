import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'app.dart';
import 'state/app_settings.dart';
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
  return EmocijuRatasApp(settings: AppSettings(settingsStore));
}

bool _licencesRegistered = false;

void _registerFontLicences() {
  if (_licencesRegistered) return;
  _licencesRegistered = true;
  LicenseRegistry.addLicense(() async* {
    const fonts = {'Nunito': 'assets/fonts/Nunito-OFL.txt'};
    for (final entry in fonts.entries) {
      yield LicenseEntryWithLineBreaks([
        entry.key,
      ], await rootBundle.loadString(entry.value));
    }
  });
}
