import 'package:flutter/material.dart';

import 'app_colors.dart';

/// The product's type system.
///
/// Two families, deliberately split by role:
///
/// * **Space Grotesk** — the product's voice. Screen titles, section labels and
///   every money figure. Its slightly squared, tightly-tracked letterforms are
///   what make a page of amounts recognisably *this* app rather than a generic
///   dashboard.
/// * **the platform face** (Roboto on Android) — everything you read in
///   sentences: row titles, descriptions, field labels, helper text. Native
///   text stays comfortable at small sizes and matches the keyboard, dialogs
///   and system UI.
///
/// Space Grotesk is a variable font, so weights are set through the `wght` axis
/// rather than relying on `fontWeight` interpolation — the two are kept in
/// sync so layout metrics and rendered weight always agree.
///
/// Colours come from the active palette, so switching theme repaints every
/// piece of text. Styles that sit on top of a coloured panel are re-tinted at
/// the call site.
class AppType {
  AppType._();

  static const String displayFamily = 'SpaceGrotesk';

  /// Tabular figures: amounts sit in a column and do not jitter when a value
  /// animates.
  static const List<FontFeature> tabular = [FontFeature.tabularFigures()];

  static List<FontVariation> _wght(double weight) =>
      [FontVariation('wght', weight)];

  /// A display-family style at an exact variable weight.
  static TextStyle display({
    required double size,
    required double weight,
    double tracking = -0.2,
    double height = 1.15,
    Color? color,
    bool figures = false,
  }) =>
      TextStyle(
        fontFamily: displayFamily,
        fontSize: size,
        fontWeight: FontWeight.values[((weight / 100).round() - 1).clamp(0, 8).toInt()],
        fontVariations: _wght(weight),
        letterSpacing: tracking,
        height: height,
        color: color ?? AppColors.textPrimary,
        fontFeatures: figures ? tabular : null,
      );

  // ── Money ─────────────────────────────────────────────────────────────────
  // The largest type on any working screen is a single amount. Nothing else in
  // the interface is allowed to compete with it.
  static TextStyle get moneyHero => display(
    size: 34,
    weight: 700,
    tracking: -1.0,
    height: 1.08,
    figures: true,
  );

  static TextStyle get displayLarge => display(
    size: 34,
    weight: 700,
    tracking: -1.0,
    height: 1.08,
    figures: true,
  );

  /// A value that leads a panel or a grouped list total.
  static TextStyle get moneyLarge => display(
    size: 21,
    weight: 600,
    tracking: -0.5,
    height: 1.15,
    figures: true,
  );

  /// Row-level amounts, aligned right in a money column.
  static TextStyle get money => display(
    size: 15.5,
    weight: 600,
    tracking: -0.2,
    height: 1.2,
    figures: true,
  );

  /// Small figures inside chips and inline summaries.
  static TextStyle get moneySmall => display(
    size: 13,
    weight: 600,
    tracking: -0.1,
    height: 1.15,
    figures: true,
  );

  // ── Headings ──────────────────────────────────────────────────────────────
  /// Screen titles. Sentence case, tight, unmistakably the product's face.
  static TextStyle get screenTitle => display(
    size: 23,
    weight: 600,
    tracking: -0.5,
    height: 1.15,
  );

  static TextStyle get headline => screenTitle;

  /// Section labels above a group of rows.
  static TextStyle get title => display(
    size: 15,
    weight: 600,
    tracking: -0.1,
    height: 1.25,
  );

  /// Counts, group totals and other small figures in the display face, so a
  /// list of amounts reads as one system.
  static TextStyle get figureLabel => display(
    size: 12.5,
    weight: 600,
    tracking: 0.1,
    height: 1.2,
    color: AppColors.textSecondary,
    figures: true,
  );

  // ── Platform-face text ────────────────────────────────────────────────────
  /// The first line of a record: a subscriber name, a service, a device.
  static TextStyle get subtitle => TextStyle(
    fontSize: 15.5,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  static TextStyle get body => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: AppColors.textSecondary,
  );

  static TextStyle get bodyStrong => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  /// Secondary line under a record: dates, service names, counts.
  static TextStyle get caption => TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w400,
    height: 1.35,
    color: AppColors.textSecondary,
  );

  /// Field labels and small status text. Never used as decoration.
  static TextStyle get overline => TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.3,
    color: AppColors.textTertiary,
  );

  static TextStyle get label => TextStyle(
    fontSize: 13.5,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.05,
    color: AppColors.textPrimary,
  );

  /// Button and control text: platform face, medium weight, no tracking games.
  static TextStyle get control => TextStyle(
    fontSize: 14.5,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  static TextTheme textTheme() => TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayLarge,
    headlineMedium: screenTitle,
    headlineSmall: title,
    titleLarge: screenTitle,
    titleMedium: subtitle,
    titleSmall: label,
    bodyLarge: bodyStrong,
    bodyMedium: body,
    bodySmall: caption,
    labelLarge: control,
    labelMedium: label,
    labelSmall: overline,
  );
}
