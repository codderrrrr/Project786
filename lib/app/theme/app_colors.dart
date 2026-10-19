import 'package:flutter/material.dart';

import 'app_palette.dart';

/// The app's colour tokens, resolved from the active [AppPalette].
///
/// Why a facade over a static palette instead of `Theme.of(context)`: the whole
/// UI is written against named *tokens* (`AppColors.primary`, `AppColors.textTertiary`)
/// rather than Material roles, and there are hundreds of such references. A
/// dynamic facade keeps a single source of truth per palette, lets every theme
/// be defined and contrast-tested in one file, and still guarantees that
/// switching themes repaints everything — the app rebuilds from the root and no
/// widget caches a colour in a `const` expression (see the token test).
///
/// Names are roles: `primary` is violet in Nocturne Bloom, red in Nothing Mono
/// and terracotta in Claude Paper.
class AppColors {
  AppColors._();

  static AppPalette _active = AppPalettes.pixelLight;

  /// The palette currently painting the app.
  static AppPalette get active => _active;

  /// Called once by the theme controller before the tree rebuilds.
  static void apply(AppPalette palette) {
    _active = palette;
  }

  // ── Surfaces ──────────────────────────────────────────────────────────────
  static Color get canvas => _active.canvas;
  static Color get surface => _active.surface;
  static Color get surfaceAlt => _active.surfaceAlt;
  static Color get surfaceHigh => _active.surfaceHigh;
  static Color get outline => _active.outline;
  static Color get outlineSoft => _active.outlineSoft;

  // ── Accents ───────────────────────────────────────────────────────────────
  static Color get primary => _active.primary;
  static Color get primaryDeep => _active.primaryDeep;
  static Color get accent => _active.accent;
  static Color get accentDeep => _active.accentDeep;
  static Color get success => _active.success;
  static Color get successDeep => _active.successDeep;
  static Color get highlight => _active.highlight;
  static Color get warning => _active.warning;
  static Color get danger => _active.danger;
  static Color get info => _active.info;

  // ── Text ──────────────────────────────────────────────────────────────────
  static Color get textPrimary => _active.textPrimary;
  static Color get textSecondary => _active.textSecondary;
  static Color get textTertiary => _active.textTertiary;

  /// Ink for text on a filled [primary] / [danger] surface.
  static Color get onAccent => _active.onAccent;
  static Color get onDanger => _active.onDanger;

  /// Ink for text on the bright hero gradients.
  static Color get onHeroInk => _active.onHeroInk;

  /// Ambient shadow colour (softer in light palettes).
  static Color get shadow => _active.shadow;

  /// Barrier behind dialogs and sheets.
  static Color get scrim => _active.scrim;

  // ── Hero gradients ────────────────────────────────────────────────────────
  static LinearGradient get aurora => _active.aurora;
  static LinearGradient get sunset => _active.sunset;
  static LinearGradient get lagoon => _active.lagoon;
  static LinearGradient get ember => _active.ember;
  static LinearGradient get meadow => _active.meadow;

  /// Glass highlight painted over cards.
  static LinearGradient get sheen => _active.sheen;

  static bool get isDark => _active.isDark;
  static Brightness get brightness => _active.brightness;
}
