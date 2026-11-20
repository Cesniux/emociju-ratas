import 'package:flutter/widgets.dart';

import 'app_settings.dart';

/// Gives every screen and sheet the app's settings. Lives
/// above MaterialApp so bottom sheets see it too.
class AppScope extends InheritedWidget {
  const AppScope({super.key, required this.settings, required super.child});

  final AppSettings settings;

  static AppScope of(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope missing above this context');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) => settings != oldWidget.settings;
}
