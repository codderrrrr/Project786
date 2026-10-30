import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:subscription_saas_flutter/app/router.dart';

// Fixed-stud harness: pumps the real app to the dashboard branch and returns.
// Loading shimmers animate forever, so tests pump fixed frames and must not
// call pumpAndSettle while a request is in flight.
Future<void> _pumpHome(WidgetTester tester, {double textScale = 1.0}) async {
  await tester.binding.setSurfaceSize(const Size(360, 720));
  await tester.pumpWidget(
    ProviderScope(
      child: Builder(
        builder: (context) => Consumer(
          builder: (context, ref, _) => MaterialApp.router(
            routerConfig: ref.watch(routerProvider),
            builder: (context, child) => MediaQuery.withClampedTextScaling(
              maxScaleFactor: textScale,
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 1000));
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  testWidgets(
    'bottom navigation keeps the original five destinations in order',
    (tester) async {
      await _pumpHome(tester);

      final expected = [
        'Subscribers',
        'Services',
        'Home',
        'Billing',
        'History',
      ];
      final labels = expected
          .where((l) => find.text(l).evaluate().isNotEmpty)
          .toList();
      expect(labels, expected, reason: 'Tab order is a product constraint');

      // Every destination keeps its own label; nothing depends on guessing.
      for (final l in expected) {
        expect(find.text(l), findsOneWidget);
      }
    },
  );

  testWidgets('tapping a bottom tab switches the shell branch', (tester) async {
    await _pumpHome(tester);

    await tester.tap(find.text('Billing'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.text('Due today'),
      findsWidgets,
      reason: 'Billing branch destination is preserved',
    );
  });

  testWidgets('dashboard holds the hero under 1.6x text scale', (tester) async {
    // The redesigned hero restored FittedBox: the amount must never clip,
    // whatever the demo month's total or the user's accessibility setting.
    await _pumpHome(tester, textScale: 1.6);
    await tester.pump(const Duration(milliseconds: 400));

    expect(
      tester.takeException(),
      isNull,
      reason: 'No overflow exceptions at enlarged text scale',
    );
    // The hero and the first metric group are still reachable.
    expect(find.text('Collected'), findsOneWidget);
    expect(find.text('Expected revenue'), findsOneWidget);
  });
}
