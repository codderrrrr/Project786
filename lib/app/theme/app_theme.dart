import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_radii.dart';
import 'app_type.dart';

/// Material theme assembled from the active [AppColors] palette.
///
/// Every value comes from a token, so a light palette (Claude Paper, Pixel
/// Light, Solarized Light) is a first-class citizen rather than a dark theme
/// with a white background: brightness, overlays, scrim, shadows, ink on
/// accents and the light/dark of system bars all follow the palette.
class AppTheme {
  AppTheme._();

  /// System bar styling must follow the palette brightness, or a light theme
  /// keeps white status-bar icons on a cream background.
  static SystemUiOverlayStyle get overlay => SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: AppColors.isDark
        ? Brightness.light
        : Brightness.dark,
    statusBarBrightness: AppColors.isDark ? Brightness.dark : Brightness.light,
    systemNavigationBarColor: AppColors.canvas,
    systemNavigationBarIconBrightness: AppColors.isDark
        ? Brightness.light
        : Brightness.dark,
  );

  static ColorScheme scheme() {
    final base = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: AppColors.brightness,
    );
    return base.copyWith(
      primary: AppColors.primary,
      onPrimary: AppColors.onAccent,
      primaryContainer: AppColors.surfaceHigh,
      onPrimaryContainer: AppColors.textPrimary,
      secondary: AppColors.accent,
      onSecondary: AppColors.onAccent,
      secondaryContainer: AppColors.surfaceAlt,
      onSecondaryContainer: AppColors.textPrimary,
      tertiary: AppColors.success,
      onTertiary: AppColors.onAccent,
      tertiaryContainer: AppColors.surfaceAlt,
      onTertiaryContainer: AppColors.textPrimary,
      error: AppColors.danger,
      onError: AppColors.onDanger,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      surfaceDim: AppColors.canvas,
      surfaceBright: AppColors.surfaceHigh,
      surfaceContainerLowest: AppColors.canvas,
      surfaceContainerLow: AppColors.surface,
      surfaceContainer: AppColors.surfaceAlt,
      surfaceContainerHigh: AppColors.surfaceHigh,
      surfaceContainerHighest: AppColors.surfaceHigh,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineSoft,
      inverseSurface: AppColors.textPrimary,
      onInverseSurface: AppColors.canvas,
      shadow: AppColors.shadow,
      scrim: AppColors.scrim,
    );
  }

  static ThemeData current() {
    final cs = scheme();
    final t = AppType.textTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: AppColors.brightness,
      colorScheme: cs,
      scaffoldBackgroundColor: AppColors.canvas,
      canvasColor: AppColors.canvas,
      textTheme: t,
      primaryTextTheme: t,
      // Standard density: `VisualDensity.comfortable` is (-1, -1), which the
      // button styles shrink by 4dp (48 -> 44) and drops controls below the
      // 48dp tap-target guideline.
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textPrimary, size: 22),
        actionsIconTheme: IconThemeData(color: AppColors.textPrimary, size: 22),
        titleTextStyle: AppType.title,
        systemOverlayStyle: overlay,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.rLg,
          side: BorderSide(color: AppColors.outlineSoft),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.outlineSoft,
        thickness: 1,
        space: 1,
      ),
      iconTheme: IconThemeData(color: AppColors.textSecondary, size: 22),
      listTileTheme: ListTileThemeData(
        iconColor: AppColors.textSecondary,
        textColor: AppColors.textPrimary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: AppType.body.copyWith(color: AppColors.textTertiary),
        labelStyle: AppType.caption,
        floatingLabelStyle: AppType.caption.copyWith(color: AppColors.primary),
        prefixIconColor: AppColors.textTertiary,
        suffixIconColor: AppColors.textTertiary,
        errorStyle: AppType.caption.copyWith(color: AppColors.danger),
        border: OutlineInputBorder(
          borderRadius: AppRadii.rMd,
          borderSide: BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.rMd,
          borderSide: BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.rMd,
          borderSide: BorderSide(color: AppColors.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadii.rMd,
          borderSide: BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadii.rMd,
          borderSide: BorderSide(color: AppColors.danger, width: 1.6),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onAccent,
          disabledBackgroundColor: AppColors.surfaceHigh,
          disabledForegroundColor: AppColors.textTertiary,
          textStyle: AppType.label.copyWith(fontSize: 15),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.rPill),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, 52),
          backgroundColor: AppColors.surfaceHigh,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          textStyle: AppType.label,
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.rPill),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 52),
          foregroundColor: AppColors.textPrimary,
          side: BorderSide(color: AppColors.outline),
          textStyle: AppType.label,
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.rPill),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(0, 48),
          foregroundColor: AppColors.primary,
          textStyle: AppType.label,
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.rPill),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: AppColors.textPrimary,
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.rPill),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceAlt,
        selectedColor: AppColors.primary.withValues(alpha: 0.22),
        side: BorderSide(color: AppColors.outline),
        labelStyle: AppType.caption.copyWith(color: AppColors.textPrimary),
        secondaryLabelStyle: AppType.caption,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.rPill),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surfaceHigh,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: AppColors.surfaceHigh,
        modalBarrierColor: AppColors.scrim,
        showDragHandle: true,
        dragHandleColor: AppColors.outline,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.rSheet),
        elevation: 0,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceHigh,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: AppType.title,
        contentTextStyle: AppType.body,
        barrierColor: AppColors.scrim,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.rXl),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceHigh,
        contentTextStyle: AppType.bodyStrong,
        actionTextColor: AppColors.primary,
        elevation: 0,
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.rMd),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.surfaceHigh,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        textStyle: AppType.bodyStrong,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.rMd,
          side: BorderSide(color: AppColors.outline),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.textPrimary,
        unselectedLabelColor: AppColors.textTertiary,
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        labelStyle: AppType.label,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: AppRadii.rSm,
        ),
        textStyle: AppType.caption.copyWith(color: AppColors.textPrimary),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.surfaceHigh,
        circularTrackColor: AppColors.surfaceHigh,
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(
          AppColors.textTertiary.withValues(alpha: 0.5),
        ),
        radius: const Radius.circular(AppRadii.pill),
        thickness: const WidgetStatePropertyAll(4),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.textTertiary,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.surfaceAlt,
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  /// Kept for call sites that predate multi-theme support.
  static ThemeData dark() => current();
}
