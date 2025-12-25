import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Simple text widget test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Hello RENTVERSE'),
          ),
        ),
      ),
    );

    expect(find.text('Hello RENTVERSE'), findsOneWidget);
  });

  testWidgets('Button tap test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('Click Me'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Click Me'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
  });

  testWidgets('Icon test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Icon(Icons.home),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.home), findsOneWidget);
  });

  test('Simple unit test', () {
    final result = 2 + 2;
    expect(result, 4);
  });
}
