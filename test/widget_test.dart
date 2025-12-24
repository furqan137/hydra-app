import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hidra/main.dart';

void main() {
  testWidgets('Hidra app launches successfully',
          (WidgetTester tester) async {

        // Build app
        await tester.pumpWidget(const HidraApp());

        // Allow FutureBuilder / async prefs to resolve
        await tester.pumpAndSettle();

        // App root should exist
        expect(find.byType(MaterialApp), findsOneWidget);
      });
}
