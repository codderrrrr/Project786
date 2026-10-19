import 'package:flutter/material.dart';

import 'package:subscription_saas_flutter/app/theme/app_colors.dart';

/// The app canvas: a quiet blue-tinted wash that adds depth without competing
/// with records, amounts, or status colours. The opacity stays deliberately
/// low so every screen still reads as a product workspace, not a wallpaper.
class AuroraBackground extends StatelessWidget {
  const AuroraBackground({
    super.key,
    required this.child,
    this.intensity = 1.0,
  });

  /// Scales the ambient tint for dense screens that need a calmer backdrop.
  final double intensity;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final safeIntensity = intensity.clamp(0.0, 1.0).toDouble();
    // A BoxDecoration paints `color` and `gradient` through the *same* paint,
    // and Skia ignores `color` entirely once a shader is attached — so the
    // canvas has to live inside the gradient stops themselves. Every stop is
    // blended against the canvas and fully opaque, otherwise the screen shows
    // whatever sits behind the app (black in tests, the platform window in
    // production) instead of the light theme's backdrop.
    final canvas = AppColors.canvas;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(canvas, AppColors.primary, 0.035 * safeIntensity)!,
            canvas,
            Color.lerp(canvas, AppColors.surfaceAlt, 0.18)!,
          ],
          stops: const [0.0, 0.48, 1.0],
        ),
      ),
      child: child,
    );
  }
}
