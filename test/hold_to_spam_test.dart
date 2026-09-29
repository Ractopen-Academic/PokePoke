import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokepoke/core/widgets/hold_to_spam_button.dart';

void main() {
  testWidgets('HoldToSpamButton triggers once on tap and spams on hold', (tester) async {
    int triggerCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: HoldToSpamButton(
              onTrigger: () => triggerCount++,
              initialDelay: const Duration(milliseconds: 100),
              interval: const Duration(milliseconds: 50),
              child: const Text('SPAM ME'),
            ),
          ),
        ),
      ),
    );

    // 1. Single tap test
    await tester.tap(find.text('SPAM ME'));
    await tester.pump();
    expect(triggerCount, 1);

    // 2. Press and hold test
    final gesture = await tester.startGesture(tester.getCenter(find.text('SPAM ME')));
    await tester.pump();
    expect(triggerCount, 2); // Initial press down triggers

    // Advance past initial delay (100ms) + 3 intervals (150ms)
    await tester.pump(const Duration(milliseconds: 260));
    expect(triggerCount, greaterThanOrEqualTo(4));

    // Release hold
    await gesture.up();
    await tester.pump();
    final countAfterRelease = triggerCount;

    // Advance more time to confirm spam stopped
    await tester.pump(const Duration(milliseconds: 200));
    expect(triggerCount, countAfterRelease);
  });
}
