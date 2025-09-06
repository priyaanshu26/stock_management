// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:stock_management/main.dart';

void main() {
  testWidgets('Stock Management App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const StockManagementApp());

    // Verify that our app displays the initial text.
    expect(find.text('Stock Management App\nFirebase Initialized'), findsOneWidget);
  });
}
