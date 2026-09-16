import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pokepoke/main.dart';

void main() {
  testWidgets('App initializes and renders LoadingScreen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
