import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:subscription_saas_flutter/app/router.dart';
import 'package:subscription_saas_flutter/app/theme/app_theme.dart';
import 'package:subscription_saas_flutter/app/theme/theme_controller.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    // Watched so the whole tree rebuilds when the palette changes; the tokens
    // are applied by the controller before this frame is built.
    final palette = ref.watch(themeControllerProvider);
    final theme = AppTheme.current();

    return MaterialApp.router(
      title: 'Subscription SaaS',
      debugShowCheckedModeBanner: false,
      // Both slots carry the active palette: the app's brightness follows the
      // theme, not the platform, so a light theme is light even at night.
      theme: theme,
      darkTheme: theme,
      themeMode: palette.isDark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
      builder: (context, child) {
        // Clamp text scaling to a range the layouts below are verified against,
        // and report the real brightness so system widgets (keyboard, dialogs)
        // match the palette.
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(
            textScaler: mq.textScaler.clamp(minScaleFactor: 0.9, maxScaleFactor: 1.6),
            platformBrightness: palette.brightness,
            // The system chrome has to be told which way it is, or a light
            // palette keeps white status-bar icons on a cream background.
            devicePixelRatio: mq.devicePixelRatio,
          ),
          child: AnnotatedRegion(
            value: AppTheme.overlay,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
