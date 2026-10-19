import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subscription_saas_flutter/app/app.dart';
import 'package:subscription_saas_flutter/app/theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(const [DeviceOrientation.portraitUp]);

  // Resolve the saved appearance before the first frame so the app never opens
  // on the default palette and then jumps. Storage failures fall back safely.
  const store = SecureThemeStore();
  await loadSavedTheme(store);

  runApp(
    ProviderScope(
      overrides: [themeStoreProvider.overrideWithValue(store)],
      child: const App(),
    ),
  );
}
