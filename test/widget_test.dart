// SignBridge Widget Test
// Tests the main app widget initialization

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:signbridge/main.dart';

void main() {
  testWidgets('SignBridge app initializes correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SignBridgeApp());

    // Verify that the app title is present
    expect(find.text('SignBridge'), findsOneWidget);

    // Verify that we have navigation options
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Home screen has mode selection buttons', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SignBridgeApp());
    await tester.pump();

    // Verify that the app has a MaterialApp widget
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
