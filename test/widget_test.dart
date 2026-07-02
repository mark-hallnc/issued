import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:issued_app/app.dart';

void main() {
  testWidgets('Issued shell shows dashboard and navigates tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const IssuedApp());

    expect(find.text('Issued'), findsWidgets);
    expect(find.text('Tool crib and shop inventory'), findsOneWidget);
    expect(find.text('Low Stock'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.qr_code_scanner_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Scan Item'), findsOneWidget);
    expect(find.text('Issue'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.inventory_2_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Cutting Disc 4.5 in'), findsOneWidget);
    expect(find.text('Low'), findsOneWidget);

    await tester.tap(find.text('Torque Wrench'));
    await tester.pumpAndSettle();
    expect(find.text('Item Detail'), findsOneWidget);
    expect(find.text('Unit cost'), findsOneWidget);
    expect(find.text('Check Out'), findsOneWidget);
    expect(find.text('Mark Lost/Damaged'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.fact_check_outlined));
    await tester.pumpAndSettle();
    expect(find.text('July Tool Crib Count'), findsOneWidget);
    expect(find.text('Assigned'), findsOneWidget);
  });
}
