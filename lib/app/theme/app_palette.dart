import 'package:flutter/material.dart';

/// One complete, self-consistent design language.
/// Token *names* are roles, not colours: `primary` may be violet (Nocturne),
/// red (Nothing) or terracotta (Claude Paper). Nothing in the app should be
/// written against a literal colour, so switching palettes can never produce a
/// surface/text pair that was not contrast-checked (see
/// `test/theme_contrast_test.dart`, which asserts every palette's pairs).
@immutable
class AppPalette {
  const AppPalette({
    required this.id,
    required this.name,
    required this.tagline,
    required this.isDark,
    required this.canvas,
    required this.surface,
    required this.surfaceAlt,
    required this.surfaceHigh,
    required this.outline,
    required this.outlineSoft,
    required this.primary,
    required this.primaryDeep,
    required this.accent,
    required this.accentDeep,
    required this.success,
    required this.successDeep,
    required this.highlight,
    required this.warning,
    required this.danger,
    required this.info,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.onAccent,
    required this.onDanger,
    required this.onHeroInk,
    required this.shadow,
    required this.scrim,
    required this.sheen,
    required this.aurora,
    required this.sunset,
    required this.lagoon,
    required this.ember,
    required this.meadow,
  });

  /// Stable storage key. Never rename once shipped — it is persisted.
  final String id;
  final String name;
  final String tagline;
  final bool isDark;

  // Surfaces
  final Color canvas;
  final Color surface;
  final Color surfaceAlt;
  final Color surfaceHigh;
  final Color outline;
  final Color outlineSoft;

  // Accents (role-named; the historical names live in AppColors)
  final Color primary;
  final Color primaryDeep;
  final Color accent;
  final Color accentDeep;
  final Color success;
  final Color successDeep;
  final Color highlight;
  final Color warning;
  final Color danger;
  final Color info;

  // Text
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;

  /// Ink for text/icons sitting on a filled [primary] or [danger] surface.
  final Color onAccent;
  final Color onDanger;

  /// Ink for the bright hero gradients ([aurora] and friends).
  final Color onHeroInk;

  /// Ambient shadow colour — light palettes need much softer shadows.
  final Color shadow;

  /// Barrier painted behind dialogs and sheets; always dark, in every palette.
  final Color scrim;

  /// Glass highlight painted over cards.
  final LinearGradient sheen;

  // Hero gradients
  final LinearGradient aurora;
  final LinearGradient sunset;
  final LinearGradient lagoon;
  final LinearGradient ember;
  final LinearGradient meadow;

  Brightness get brightness => isDark ? Brightness.dark : Brightness.light;

  /// Every stop of every hero gradient — used to prove [onHeroInk] is legible
  /// on the whole gradient, not just on average.
  List<Color> get heroStops => [
    for (final g in [aurora, sunset, lagoon, ember, meadow]) ...g.colors,
  ];

  /// Surfaces that text is measured against, in the order used by the
  /// contrast test (darkest → lightest for dark themes).
  Map<String, Color> get textSurfaces => {
    'canvas': canvas,
    'surface': surface,
    'surfaceHigh': surfaceHigh,
  };
}

/// The one place colours are defined per theme.
/// Add a palette here and it appears in the picker, in the contrast test and in
/// the per-theme screen sweep automatically.
class AppPalettes {
  AppPalettes._();

  static AppPalette byId(String id) {
    switch (id) {
      case 'pixel_light':
        return pixelLight;
      case 'nocturne_bloom':
        return nocturneBloom;
      case 'nothing_mono':
        return nothingMono;
      case 'dracula':
        return dracula;
      case 'nothing':
        return nothing;
      case 'blue_mist':
        return blueMist;
      case 'skyline_light':
        return skylineLight;
      case 'midnight_blue':
        return midnightBlue;
      default:
        return pixelLight;
    }
  }

  // Light theme palette - main BLUE, darker in light mode
  static const AppPalette pixelLight = AppPalette(
    id: 'pixel_light',
    name: 'Pixel Light',
    tagline: 'Calm blue workspace',
    isDark: false,
    canvas: Color(0xFFF2F6FB),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFE8F0F8),
    surfaceHigh: Color(0xFFF8FBFF),
    outline: Color(0xFFA8B8C8),
    outlineSoft: Color(0xFFD3E0EC),
    primary: Color(0xFF1557A6), // Dark blue for light mode
    primaryDeep: Color(0xFF0B3B85),
    accent: Color(0xFF0B7189),
    accentDeep: Color(0xFF075468),
    success: Color(0xFF227A4B),
    successDeep: Color(0xFF175C38),
    highlight: Color(0xFF5B7DA8),
    warning: Color(0xFFA65E00),
    danger: Color(0xFFBF2F38),
    info: Color(0xFF1769AA),
    textPrimary: Color(0xFF14212D),
    textSecondary: Color(0xFF44586A),
    textTertiary: Color(
      0xFF5A6F81,
    ), // >=4.5:1 on canvas and the aurora tint stops
    onAccent: Color(0xFFFFFFFF),
    onDanger: Color(0xFFFFFFFF),
    onHeroInk: Color(0xFFFFFFFF),
    shadow: Color(0x240B3B85),
    scrim: Color(0x4D000000),
    sheen: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0x08FFFFFF), Color(0x00FFFFFF)],
    ),
    aurora: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF0B3B85), Color(0xFF1557A6), Color(0xFF087BAE)],
    ),
    sunset: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF1557A6), Color(0xFF0B3B85)],
    ),
    lagoon: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF087BAE), Color(0xFF0B568E)],
    ),
    ember: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF0B568E), Color(0xFF1557A6)],
    ),
    meadow: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF0B3B85), Color(0xFF0B7189)],
    ),
  );

  // Dark theme palette - sky blue in dark mode
  static const AppPalette nocturneBloom = AppPalette(
    id: 'nocturne_bloom',
    name: 'Nocturne Bloom',
    tagline: 'Canvas blue, sky blue in dark',
    isDark: true,
    canvas: Color(0xFF0A0A1E),
    surface: Color(0xFF12122A),
    surfaceAlt: Color(0xFF1A1A32),
    surfaceHigh: Color(0xFF24243E),
    outline: Color(0xFF3A3A5A),
    outlineSoft: Color(0xFF2D2D47),
    primary: Color(
      0xFF64B5F6,
    ), // Sky blue for dark mode (review: sky blue in dark mode)
    primaryDeep: Color(0xFF0B70DC), // Deeper sky blue
    accent: Color(0xFFFF8A65), // Coral accent
    accentDeep: Color(0xFFE53935),
    success: Color(0xFF81C784), // Light green
    successDeep: Color(0xFF66BB6A),
    highlight: Color(0xFF7FB3D5),
    warning: Color(0xFFFFB74D), // Amber
    danger: Color(0xFFEF5350), // Red
    info: Color(0xFF64B5F6), // Sky blue info
    textPrimary: Color(0xFFE0E0E0), // Light gray
    textSecondary: Color(0xFFBCBCBC),
    textTertiary: Color(0xFF9E9E9E),
    onAccent: Color(0xFF212121), // Dark on accent
    onDanger: Color(0xFF212121),
    onHeroInk: Color(
      0xFF000000,
    ), // dark ink clears 4.5:1 on every bright hero stop
    shadow: Color(0x59000000),
    scrim: Color(0xCC000000),
    sheen: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0x12FFFFFF), Color(0x04FFFFFF)],
    ),
    aurora: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF03A9F4), Color(0xFF1976D2), Color(0xFFFF8A65)],
    ),
    sunset: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFF8A65), Color(0xFFFF5353)],
    ),
    lagoon: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF00BCD4), Color(0xFF00E5FF)],
    ),
    ember: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFFB74D), Color(0xFFFF6B6B)],
    ),
    meadow: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF81C784), Color(0xFF66BB6A)],
    ),
  );

  // Additional palettes
  static const AppPalette nothingMono = AppPalette(
    id: 'nothing_mono',
    name: 'Nothing Mono',
    tagline: 'True black, white type, red signal',
    isDark: true,
    canvas: Color(0xFF000000),
    surface: Color(0xFF0C0C0C),
    surfaceAlt: Color(0xFF141414),
    surfaceHigh: Color(0xFF1C1C1C),
    outline: Color(0xFF3A3A3A),
    outlineSoft: Color(0xFF232323),
    primary: Color(0xFF72C7FF),
    primaryDeep: Color(0xFF1B83CF),
    accent: Color(0xFFD71921),
    accentDeep: Color(0xFF9E1017),
    success: Color(0xFF69D39C),
    successDeep: Color(0xFF3AA875),
    highlight: Color(0xFFAED0FF),
    warning: Color(0xFFFFB020),
    danger: Color(0xFFD71921),
    info: Color(0xFF72C7FF),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFCFCFCF),
    textTertiary: Color(0xFFA3A3A3),
    onAccent: Color(0xFF06203A),
    onDanger: Color(0xFFFFFFFF),
    onHeroInk: Color(0xFF000000),
    shadow: Color(0x73000000),
    scrim: Color(0xCC05060A),
    sheen: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0x14FFFFFF), Color(0x03FFFFFF)],
    ),
    aurora: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFF2F2F2), Color(0xFFC9C9C9)],
    ),
    sunset: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFEAEAEA), Color(0xFFB5B5B5)],
    ),
    lagoon: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFF5F5F5), Color(0xFFCDCDCD)],
    ),
    ember: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFE6E6E6), Color(0xFFA8A8A8)],
    ),
    meadow: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFAFAFA), Color(0xFFD2D2D2)],
    ),
  );

  static const AppPalette dracula = AppPalette(
    id: 'dracula',
    name: 'Dracula',
    tagline: 'The classic vampire palette',
    isDark: true,
    canvas: Color(0xFF1E1F29),
    surface: Color(0xFF282A36),
    surfaceAlt: Color(0xFF2F3140),
    surfaceHigh: Color(0xFF3A3D4F),
    outline: Color(0xFF44475A),
    outlineSoft: Color(0xFF343748),
    primary: Color(0xFFC9A6FF),
    primaryDeep: Color(0xFF9A6FE0),
    accent: Color(0xFFFF79C6),
    accentDeep: Color(0xFFE0559F),
    success: Color(0xFF50FA7B),
    successDeep: Color(0xFF2FBF57),
    highlight: Color(0xFFF1FA8C),
    warning: Color(0xFFFFB86C),
    danger: Color(0xFFFF5555),
    info: Color(0xFF8BE9FD),
    textPrimary: Color(0xFFF8F8F2),
    textSecondary: Color(0xFFC3C6DA),
    textTertiary: Color(0xFFA9AEC9),
    onAccent: Color(0xFF1E1F29),
    onDanger: Color(0xFF2A0A0A),
    onHeroInk: Color(0xFF12131C),
    shadow: Color(0x59000000),
    scrim: Color(0xCC05060A),
    sheen: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0x12FFFFFF), Color(0x04FFFFFF)],
    ),
    aurora: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFBD93F9), Color(0xFFFF79C6), Color(0xFFFFB86C)],
    ),
    sunset: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFF79C6), Color(0xFFFFB86C)],
    ),
    lagoon: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF8BE9FD), Color(0xFF50FA7B)],
    ),
    ember: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFFB86C), Color(0xFFFF5555)],
    ),
    meadow: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFF1FA8C), Color(0xFF50FA7B)],
    ),
  );

  /// A cooler light variant for users who prefer a brighter, more airy canvas.
  static const AppPalette blueMist = AppPalette(
    id: 'blue_mist',
    name: 'Blue Mist',
    tagline: 'Airy blue workspace',
    isDark: false,
    canvas: Color(0xFFF1F6FC),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFE6EFF8),
    surfaceHigh: Color(0xFFF8FBFF),
    outline: Color(0xFFA4B8CB),
    outlineSoft: Color(0xFFD0DEEA),
    primary: Color(0xFF165DAA),
    primaryDeep: Color(0xFF0D3E82),
    accent: Color(0xFF0F728C),
    accentDeep: Color(0xFF0A5367),
    success: Color(0xFF237A4B),
    successDeep: Color(0xFF175A37),
    highlight: Color(0xFF5A7FA9),
    warning: Color(0xFFA45D00),
    danger: Color(0xFFBE3038),
    info: Color(0xFF1769AA),
    textPrimary: Color(0xFF142333),
    textSecondary: Color(0xFF42596D),
    textTertiary: Color(0xFF5D7285),
    onAccent: Color(0xFFFFFFFF),
    onDanger: Color(0xFFFFFFFF),
    onHeroInk: Color(0xFFFFFFFF),
    shadow: Color(0x240D3E82),
    scrim: Color(0x52050B14),
    sheen: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0x10FFFFFF), Color(0x00FFFFFF)],
    ),
    aurora: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF0D3E82), Color(0xFF165DAA), Color(0xFF087BAE)],
    ),
    sunset: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF165DAA), Color(0xFF0D3E82)],
    ),
    lagoon: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF087BAE), Color(0xFF0B568E)],
    ),
    ember: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF0B568E), Color(0xFF165DAA)],
    ),
    meadow: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF0D3E82), Color(0xFF0F728C)],
    ),
  );

  /// A slightly deeper light variant that keeps blue controls crisp in bright
  /// environments without introducing another accent family.
  static const AppPalette skylineLight = AppPalette(
    id: 'skyline_light',
    name: 'Skyline Light',
    tagline: 'Crisp blue contrast',
    isDark: false,
    canvas: Color(0xFFEFF4FA),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFE2ECF5),
    surfaceHigh: Color(0xFFF7FAFE),
    outline: Color(0xFF9BAFC2),
    outlineSoft: Color(0xFFCBD9E6),
    primary: Color(0xFF124B8D),
    primaryDeep: Color(0xFF0A3268),
    accent: Color(0xFF0C6B81),
    accentDeep: Color(0xFF084A5A),
    success: Color(0xFF206E45),
    successDeep: Color(0xFF164D31),
    highlight: Color(0xFF54769D),
    warning: Color(0xFF955400),
    danger: Color(0xFFB52C35),
    info: Color(0xFF0E5F9D),
    textPrimary: Color(0xFF122131),
    textSecondary: Color(0xFF3F556A),
    textTertiary: Color(0xFF5A7084),
    onAccent: Color(0xFFFFFFFF),
    onDanger: Color(0xFFFFFFFF),
    onHeroInk: Color(0xFFFFFFFF),
    shadow: Color(0x240A3268),
    scrim: Color(0x52050B14),
    sheen: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0x10FFFFFF), Color(0x00FFFFFF)],
    ),
    aurora: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF0A3268), Color(0xFF124B8D), Color(0xFF0C6B81)],
    ),
    sunset: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF124B8D), Color(0xFF0A3268)],
    ),
    lagoon: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF0C6B81), Color(0xFF0E5F9D)],
    ),
    ember: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF0E5F9D), Color(0xFF124B8D)],
    ),
    meadow: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF0A3268), Color(0xFF0C6B81)],
    ),
  );

  /// A dark, blue-first canvas for low-light use.
  static const AppPalette midnightBlue = AppPalette(
    id: 'midnight_blue',
    name: 'Midnight Blue',
    tagline: 'Deep blue, low-light calm',
    isDark: true,
    canvas: Color(0xFF071321),
    surface: Color(0xFF0D2036),
    surfaceAlt: Color(0xFF102B47),
    surfaceHigh: Color(0xFF173A5C),
    outline: Color(0xFF31506E),
    outlineSoft: Color(0xFF213B55),
    primary: Color(0xFF72C7FF),
    primaryDeep: Color(0xFF1B83CF),
    accent: Color(0xFF55D3D6),
    accentDeep: Color(0xFF2FA4A8),
    success: Color(0xFF69D39C),
    successDeep: Color(0xFF3AA875),
    highlight: Color(0xFFAED0FF),
    warning: Color(0xFFFFC56A),
    danger: Color(0xFFFF7780),
    info: Color(0xFF72C7FF),
    textPrimary: Color(0xFFF4F9FF),
    textSecondary: Color(0xFFB7C8D9),
    textTertiary: Color(0xFF91A8BC),
    onAccent: Color(0xFF06203A),
    onDanger: Color(0xFF2C0B0F),
    onHeroInk: Color(0xFFFFFFFF),
    shadow: Color(0x99000000),
    scrim: Color(0xCC02070D),
    sheen: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0x16FFFFFF), Color(0x04FFFFFF)],
    ),
    aurora: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF0A3268), Color(0xFF135D9C), Color(0xFF0B6B82)],
    ),
    sunset: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF124B8D), Color(0xFF0A3268)],
    ),
    lagoon: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF0C6B81), Color(0xFF135D9C)],
    ),
    ember: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF135D9C), Color(0xFF0A3268)],
    ),
    meadow: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF0A3268), Color(0xFF0C6B81)],
    ),
  );

  /// All available palettes.
  static const List<AppPalette> all = [
    pixelLight,
    nocturneBloom,
    nothingMono,
    dracula,
    nothing,
    blueMist,
    skylineLight,
    midnightBlue,
  ];

  static const AppPalette nothing = AppPalette(
    id: 'nothing',
    name: 'Nothing',
    tagline: 'Minimal palette',
    isDark: true,
    canvas: Color(0xFF161616),
    surface: Color(0xFF1D1D1D),
    surfaceAlt: Color(0xFF252525),
    surfaceHigh: Color(0xFF2D2D2D),
    outline: Color(0xFF3A3A3A),
    outlineSoft: Color(0xFF333333),
    primary: Color(0xFF72C7FF),
    primaryDeep: Color(0xFF1B83CF),
    accent: Color(0xFFFF0000),
    accentDeep: Color(0xFFB30000),
    success: Color(0xFF69D39C),
    successDeep: Color(0xFF3AA875),
    highlight: Color(0xFFAED0FF),
    warning: Color(0xFFFFC107),
    danger: Color(0xFFFF0000),
    info: Color(0xFF72C7FF),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFB0B0B0),
    textTertiary: Color(0xFF979797), // 4.5:1 on surfaceHigh #2D2D2D
    onAccent: Color(0xFF06203A),
    onDanger: Color(0xFF000000), // black ink clears 4.5:1 on pure red
    onHeroInk: Color(0xFFFFFFFF),
    shadow: Color(0x73000000),
    scrim: Color(0xCC05060A),
    sheen: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0x14FFFFFF), Color(0x03FFFFFF)],
    ),
    aurora: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF0A3268), Color(0xFF135D9C)],
    ),
    sunset: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF124B8D), Color(0xFF0A3268)],
    ),
    lagoon: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF0C6B81), Color(0xFF135D9C)],
    ),
    ember: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF135D9C), Color(0xFF0A3268)],
    ),
    meadow: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF0A3268), Color(0xFF0C6B81)],
    ),
  );
}
