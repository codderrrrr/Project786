import 'package:flutter/material.dart';

import 'package:subscription_saas_flutter/app/theme/app_colors.dart';
import 'package:subscription_saas_flutter/app/theme/app_radii.dart';
import 'package:subscription_saas_flutter/app/theme/creative_tokens.dart';

import '../pressable.dart';

/// An artistic card with subtle aurora/mesh gradient styling.
/// Designed for performance with RepaintBoundary.
class AuroraCard extends StatelessWidget {
  const AuroraCard({
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
    this.glow = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Gradient? gradient;
  final Color? color;
  final BorderRadius borderRadius;
  final Border? border;
  final String? semanticLabel;
  final String? semanticHint;
  final bool excludeChildSemantics;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    final decorated = Container(
      decoration: _decoration(context),
      padding: padding,
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

  BoxDecoration _decoration(BuildContext context) {
    final baseGradient = gradient ?? CreativeTokens.cardSurface(context);
    return BoxDecoration(
      color: gradient == null ? (color ?? Colors.transparent) : null,
      gradient: baseGradient,
      borderRadius: borderRadius,
      border: border ?? Border.all(color: AppColors.outlineSoft),
      boxShadow: glow ? CreativeTokens.glowSubtle : null,
    );
  }
}
