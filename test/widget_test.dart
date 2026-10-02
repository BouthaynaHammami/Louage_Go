import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:louage_go/features/auth/auth_providers.dart';
import 'package:louage_go/main.dart';

void main() {
  testWidgets('affiche LouageGo sur le splash', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserProvider.overrideWith((ref) => Stream.value(null)),
        ],
        child: const LouageGoApp(),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('LouageGo'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
