import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:astro/main.dart';

void main() {
  testWidgets('App loads and shows splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: BhagyaApp()),
    );

    expect(find.text('Bhagya'), findsOneWidget);
    expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
  });
}
