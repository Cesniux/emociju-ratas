import 'package:emociju_ratas/emotion_wheel.dart';
import 'package:emociju_ratas/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App renders smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const EmocijuRatasApp());
    expect(find.text('Emocijų Ratas'), findsOneWidget);
  });

  testWidgets('defaults to the interactive wheel on first launch', (
    WidgetTester tester,
  ) async {
    // Fresh install: no saved selection.
    await tester.pumpWidget(const EmocijuRatasApp());
    await tester.pumpAndSettle();

    expect(find.byType(EmotionWheelView), findsOneWidget);
  });

  testWidgets('selecting an image then the wheel switches the body', (
    WidgetTester tester,
  ) async {
    // Start from a saved image selection so the wheel is not shown initially.
    SharedPreferences.setMockInitialValues({'selectedImage': 0});
    await tester.pumpWidget(const EmocijuRatasApp());
    await tester.pumpAndSettle();
    expect(find.byType(EmotionWheelView), findsNothing);

    // Open the picker and choose the interactive wheel entry.
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text(kWheelName));
    await tester.pumpAndSettle();

    expect(find.byType(EmotionWheelView), findsOneWidget);
  });
}
