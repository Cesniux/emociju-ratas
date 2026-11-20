import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'copy/strings.dart';
import 'state/app_scope.dart';
import 'state/app_settings.dart';
import 'theme/app_theme.dart';
import 'ui/home_screen.dart';

class EmocijuRatasApp extends StatelessWidget {
  const EmocijuRatasApp({super.key, required this.settings});

  final AppSettings settings;

  static const locale = Locale('lt');

  @override
  Widget build(BuildContext context) {
    return AppScope(
      settings: settings,
      child: ListenableBuilder(
        listenable: settings,
        builder: (context, _) => MaterialApp(
          title: S.appName,
          debugShowCheckedModeBanner: false,
          theme: buildTheme(Brightness.light),
          darkTheme: buildTheme(Brightness.dark),
          themeMode: settings.themeMode,
          locale: locale,
          supportedLocales: const [locale],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          // Screen readers use a Lithuanian voice even on an English phone.
          builder: (context, child) => Semantics(
            container: true,
            localeForSubtree: locale,
            child: child ?? const SizedBox.shrink(),
          ),
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
