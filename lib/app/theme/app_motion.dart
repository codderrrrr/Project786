import 'package:flutter/material.dart';

/// Central motion tokens. Every animation in the app reads its duration from
/// here so that reduced-motion support is a single switch.
///
/// Entrance animations are kept short and deterministic so they animate once on
/// first paint, then stay out of the hot repaint path. The stagger curve is
/// used only for the initial reveal; ongoing scroll-linked motion is avoided so
/// payers never fight per-frame rasterization on low-end devices.
///
/// Durational budgets: instant <= 60 ms fits inside a single frame budget;
/// fast <= 140 ms is still imperceptible as a continuous motion most of the
/// time; slow at ~320 ms is the longest useful entrance.
///
/// The stagger step is intentionally small (45 ms) so the first few items on a
/// list feel responsive while still giving the eye a rhythm to follow. Longer
/// lists cap the stagger at 12 items so the tail items do not fall outside the
/// user's first scroll.
class AppMotion {
  AppMotion._();

  static const Duration instant = Duration(milliseconds: 60);
  static const Duration fast = Duration(milliseconds: 140);
  static const Duration base = Duration(milliseconds: 220);
  static const Duration slow = Duration(milliseconds: 320);
  static const Duration bloom = Duration(milliseconds: 720);

  static const Curve emphasized = Curves.easeOutCubic;
  static const Curve standard = Curves.easeInOut;
  static const Curve overshoot = Curves.easeOutBack;

  /// True when the OS asks for reduced motion or the user enabled
  /// "remove animations" in accessibility settings.
  static bool reduced(BuildContext context) {
    final mq = MediaQuery.maybeOf(context);
    if (mq == null) return false;
    return mq.disableAnimations || mq.accessibleNavigation;
  }

  static Duration scale(BuildContext context, Duration d) =>
      reduced(context) ? Duration.zero : d;

  static Duration stagger(BuildContext context, int index,
      {Duration step = const Duration(milliseconds: 45)}) {
    if (reduced(context)) return Duration.zero;
    return Duration(milliseconds: index.clamp(0, 12) * step.inMilliseconds);
  }
}
