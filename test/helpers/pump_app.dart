import 'package:emociju_ratas/main.dart';
import 'package:emociju_ratas/state/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps the real app on a phone-sized screen (iPhone 17: 402 × 874 dp).
Future<MemorySettingsStore> pumpApp(
  WidgetTester tester, {
  MemorySettingsStore? store,
  Size size = const Size(402, 874),
  Brightness brightness = Brightness.light,
  double textScale = 1,
}) async {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  tester.platformDispatcher.platformBrightnessTestValue = brightness;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearAllTestValues);
  final s = store ?? MemorySettingsStore();
  await tester.pumpWidget(await bootstrap(store: s));
  return s;
}
