import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:subscription_saas_flutter/core/storage/secure_storage.dart';

import 'app_colors.dart';
import 'app_palette.dart';

/// Where the chosen theme is remembered between launches.
///
/// An interface (rather than a direct call to the platform keystore) so the
/// preference can be tested without platform channels, and so a storage failure
/// can never stop the app from starting.
abstract class ThemeStore {
  Future<String?> read();
  Future<void> write(String paletteId);
}

class SecureThemeStore implements ThemeStore {
  const SecureThemeStore();

  static const _key = 'appearance.theme.id';

  static const _store = SecureStore();

  @override
  Future<String?> read() async {
    try {
      return await _store.read(_key);
    } catch (_) {
      // No keystore (desktop/test, or a locked device): fall back to default.
      return null;
    }
  }

  @override
  Future<void> write(String paletteId) async {
    try {
      await _store.write(_key, paletteId);
    } catch (_) {
      // A theme preference is convenience, never a hard failure.
    }
  }
}

final themeStoreProvider = Provider<ThemeStore>((ref) => const SecureThemeStore());

/// Holds the active palette and applies it to the token facade.
///
/// Applying before `state` is set means the rebuild triggered by the new state
/// already sees the new tokens — no frame is ever painted half-switched.
class ThemeController extends Notifier<AppPalette> {
  /// Resolved once during startup from [ThemeStore] so the first frame uses the
  /// saved theme instead of flashing the default.
  static String initialId = 'pixel_light';

  @override
  AppPalette build() {
    final palette = AppPalettes.byId(initialId);
    AppColors.apply(palette);
    return palette;
  }

  void select(AppPalette palette) {
    if (palette.id == state.id) return;
    AppColors.apply(palette);
    state = palette;
    initialId = palette.id;
    ref.read(themeStoreProvider).write(palette.id);
  }
}

final themeControllerProvider =
    NotifierProvider<ThemeController, AppPalette>(ThemeController.new);

/// Reads the saved palette before the first frame. Safe to call when storage is
/// unavailable: the default palette is used and nothing throws.
Future<void> loadSavedTheme(ThemeStore store) async {
  final savedId = await store.read();
  // The release UI exposes only the blue light/dark pair. Older builds stored
  // experimental palette ids (Nothing, Dracula, etc.); loading one of those
  // would produce a dark canvas while the user believes they selected light
  // mode. Migrate those ids to the stable light default instead of reviving a
  // mismatched palette.
  ThemeController.initialId = savedId == 'nocturne_bloom'
      ? 'nocturne_bloom'
      : 'pixel_light';
  AppColors.apply(AppPalettes.byId(ThemeController.initialId));
  if (savedId != null && savedId != ThemeController.initialId) {
    await store.write(ThemeController.initialId);
  }
}
