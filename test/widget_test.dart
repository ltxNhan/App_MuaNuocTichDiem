import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dailycup/core/widgets/custom_button.dart';

void main() {
  testWidgets('CustomButton renders text and triggers callback', (WidgetTester tester) async {
    bool pressed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomButton(
            text: 'TIẾP TỤC',
            onPressed: () => pressed = true,
          ),
        ),
      ),
    );

    expect(find.text('TIẾP TỤC'), findsOneWidget);
    await tester.tap(find.text('TIẾP TỤC'));
    await tester.pump();
    expect(pressed, isTrue);
  });
}
