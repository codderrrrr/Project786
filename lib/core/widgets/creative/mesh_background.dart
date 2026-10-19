import 'package:flutter/material.dart';

import 'package:subscription_saas_flutter/app/theme/creative_tokens.dart';

/// Subtle mesh gradient background for artistic depth.
/// Performance optimized with low opacity and RepaintBoundary.
class MeshBackground extends StatelessWidget {
  const MeshBackground({
    super.key,
    this.child,
    this.opacity = 0.3,
  });

  final Widget? child;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: Theme.of(context).brightness == Brightness.dark
              ? CreativeTokens.meshBackgroundDark
              : CreativeTokens.meshBackgroundLight,
        ),
        child: child != null
            ? Opacity(
                opacity: opacity.clamp(0.0, 1.0),
                child: child,
              )
            : null,
      ),
    );
  }
}
