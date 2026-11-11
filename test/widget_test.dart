import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laundry_app/main.dart';
import 'package:laundry_app/page/monthly_recap_screen.dart';

void main() {
  testWidgets('App boots and renders splash screen header', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Housekeeping Logbook'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2000));
    await tester.pumpAndSettle();
  });

  testWidgets('Monthly recap screen renders PIN lock for confidential hotel records', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: MonthlyRecapScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Hotel Staff Verification'), findsOneWidget);
    expect(find.text('Unlock Records'), findsOneWidget);
  });
}
