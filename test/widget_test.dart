import 'package:flutter_test/flutter_test.dart';
import 'package:emociju_ratas/main.dart';

void main() {
  testWidgets('App renders smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const EmocijuRatasApp());
    expect(find.text('Emocijų Ratas'), findsOneWidget);
  });
}
