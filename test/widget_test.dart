import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mubin/app/views/widgets/quran_option_card.dart';

void main() {
  testWidgets('QuranOptionCard builds and triggers onTap', (WidgetTester tester) async {
    bool tapped = false;

    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuranOptionCard(
            title: 'Test Title',
            subtitle: 'Test Subtitle',
            icon: Icons.book,
            onTap: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    // Verify title and subtitle are present
    expect(find.text('Test Title'), findsOneWidget);
    expect(find.text('Test Subtitle'), findsOneWidget);

    // Tap the card and verify action
    await tester.tap(find.byType(QuranOptionCard));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
