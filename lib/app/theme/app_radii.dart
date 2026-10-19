import 'package:flutter/widgets.dart';

/// Corner radii. Kept deliberately modest: large radii are what make a product
/// read as a stack of generic rounded boxes, so the scale stays between 8 and
/// 20 for content and is only pill-shaped for controls that are genuinely
/// pill-shaped (filters, chips, avatars).
class AppRadii {
  AppRadii._();

  static const double xs = 6;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double pill = 999;

  static const BorderRadius rXs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius rSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius rMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius rLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius rXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius rPill = BorderRadius.all(Radius.circular(pill));
  static const BorderRadius rSheet = BorderRadius.vertical(top: Radius.circular(xl));
}

/// The spacing scale: 4 / 8 / 12 / 16 / 24 / 32. Nothing else.
class Gap {
  Gap._();

  /// Page gutter used by every screen, so text edges align across the app.
  static const double gutter = 16;

  static const SizedBox h4 = SizedBox(height: 4);
  static const SizedBox h8 = SizedBox(height: 8);
  static const SizedBox h12 = SizedBox(height: 12);
  static const SizedBox h16 = SizedBox(height: 16);
  static const SizedBox h24 = SizedBox(height: 24);
  static const SizedBox h32 = SizedBox(height: 32);
  static const SizedBox w4 = SizedBox(width: 4);
  static const SizedBox w8 = SizedBox(width: 8);
  static const SizedBox w12 = SizedBox(width: 12);
  static const SizedBox w16 = SizedBox(width: 16);

  /// Horizontal insets only — for strips that sit inside another scrollable.
  static const EdgeInsets section = EdgeInsets.symmetric(horizontal: gutter);

  /// Standard scroll padding: a 16dp gutter and enough tail room to clear the
  /// floating navigation bar (~90dp tall, 12dp above the bottom edge) so the
  /// last row can always scroll into view above it.
  static const EdgeInsets pageInset = EdgeInsets.fromLTRB(gutter, 8, gutter, 116);
}
