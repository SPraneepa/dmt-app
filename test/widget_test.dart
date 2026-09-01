import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dmt_app/main.dart';
import 'package:dmt_app/widgets/custom_button.dart';

void main() {
  testWidgets('app launches and shows splash screen content', (tester) async {
    await tester.pumpWidget(const DMTApp());

    expect(find.text('DEPARTMENT OF MOTOR TRAFFIC'), findsOneWidget);
  });

  testWidgets('primary custom buttons use zero padding and centered text', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomButton(text: 'Verify', onPressed: () {}),
        ),
      ),
    );

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.style?.padding?.resolve({}), EdgeInsets.zero);
    expect(
      find.descendant(
        of: find.byType(ElevatedButton),
        matching: find.byType(Center),
      ),
      findsOneWidget,
    );
  });
}
