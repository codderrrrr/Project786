import 'package:flutter/material.dart';

import 'package:subscription_saas_flutter/app/theme/app_colors.dart';
import 'package:subscription_saas_flutter/app/theme/app_radii.dart';

import 'pressable.dart';

/// A flat surface panel: solid fill, hairline border, small radius.
///
/// Cards are reserved for genuinely independent blocks of content. Repeated
/// records belong in [SurfaceSection]/[SurfaceRow], which align into columns
/// instead of stacking as separate floating boxes. There is no sheen, no glow
/// and no drop shadow by default — a single hairline is enough to separate a
/// panel from the canvas.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
    this.onLongPress,
    this.gradient,
    this.color,
    this.borderRadius = AppRadii.rMd,
    this.border,
    this.semanticLabel,
    this.semanticHint,
    this.excludeChildSemantics = false,
    this.shadow = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Only for surfaces that genuinely need a colour field (e.g. a hero panel).
  final Gradient? gradient;
  final Color? color;
  final BorderRadius borderRadius;
  final Border? border;
  final String? semanticLabel;
  final String? semanticHint;
  final bool excludeChildSemantics;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final decorated = Container(
      decoration: _decoration,
      padding: padding,
      // ListTile/InkWell paint their ink on the nearest Material ancestor;
      // without one here the DecoratedBox background hides every splash and
      // Flutter fires its "ink splashes may be invisible" assertion.
      child: Material(type: MaterialType.transparency, child: child),
    );

    final content = onTap == null && onLongPress == null
        ? decorated
        : Pressable(
            onTap: onTap,
            onLongPress: onLongPress,
            semanticLabel: semanticLabel,
            semanticHint: semanticHint,
            excludeChildSemantics: excludeChildSemantics,
            child: decorated,
          );

    final wrapped = margin == null
        ? content
        : Padding(padding: margin!, child: content);
    return RepaintBoundary(child: wrapped);
  }

  BoxDecoration get _decoration {
    return BoxDecoration(
      color: gradient == null ? (color ?? AppColors.surface) : null,
      gradient: gradient,
      borderRadius: borderRadius,
      border: border ?? Border.all(color: AppColors.outlineSoft),
      boxShadow: shadow
          ? [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ]
          : null,
    );
  }
}
