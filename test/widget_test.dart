import 'package:flutter_test/flutter_test.dart';
import 'package:laundry_app/main.dart';

void main() {
  testWidgets('App boots and renders splash screen header', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Housekeeping Logbook'), findsOneWidget);
    await tester.pumpAndSettle();
  });
}
