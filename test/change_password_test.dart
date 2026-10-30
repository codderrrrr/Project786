import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:subscription_saas_flutter/features/settings/presentation/change_password_screen.dart';

void main() {
  GoRouter? router;

  // AppScaffold asks the router whether it can pop, and the screen pops after
  // saving, so the harness pushes the screen over a placeholder rather than
  // mounting it as the only route.
  Widget wrap(Widget child) {
    final localRouter = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Placeholder()),
        ),
        GoRoute(path: '/change', builder: (_, _) => child),
      ],
    );
    router = localRouter;
    return MaterialApp.router(routerConfig: localRouter);
  }

  testWidgets('submit validates instead of being permanently disabled', (
    tester,
  ) async {
    // Regression: the old implementation evaluated the enabled state at build
    // time, so the button could never become tappable even with all fields
    // filled.
    await tester.pumpWidget(wrap(const ChangePasswordScreen()));
    router!.push('/change');
    await tester.pump();
    await tester.pump();

    final save = find.widgetWithText(FilledButton, 'Save');
    expect(save, findsOneWidget);
    expect(
      tester.widget<FilledButton>(save).onPressed,
      isNotNull,
      reason: 'Save starts enabled',
    );

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'currentpass1');
    await tester.enterText(fields.at(1), 'short');
    await tester.enterText(fields.at(2), 'different');
    await tester.tap(save);
    await tester.pump();

    expect(
      find.text('Password should be at least 8 characters long'),
      findsOneWidget,
    );
    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  testWidgets('a matching 8+ character password succeeds', (tester) async {
    await tester.pumpWidget(wrap(const ChangePasswordScreen()));
    router!.push('/change');
    await tester.pump();
    await tester.pump();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'current1!');
    await tester.enterText(fields.at(1), 'betterpass1');
    await tester.enterText(fields.at(2), 'betterpass1');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pump(const Duration(milliseconds: 500));

    expect(
      find.text('Password changed successfully'),
      findsOneWidget,
      reason: 'Happy path still records success feedback and pops',
    );
  });

  testWidgets('every password field has a visibility toggle', (tester) async {
    await tester.pumpWidget(wrap(const ChangePasswordScreen()));
    router!.push('/change');
    await tester.pump();
    await tester.pump();

    expect(find.byTooltip('Show password'), findsNWidgets(3));
  });
}
