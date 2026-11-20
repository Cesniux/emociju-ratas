import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads the real bundled fonts (Nunito, Material icons) so text is
/// measured and rendered as in the app. The default test font draws every
/// glyph one em wide, which would make every fit test meaningless.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final manifest =
      json.decode(await rootBundle.loadString('FontManifest.json'))
          as List<dynamic>;
  for (final family in manifest.cast<Map<String, dynamic>>()) {
    final loader = FontLoader(family['family'] as String);
    for (final font in (family['fonts'] as List).cast<Map<String, dynamic>>()) {
      loader.addFont(rootBundle.load(font['asset'] as String));
    }
    await loader.load();
  }
  await testMain();
}
