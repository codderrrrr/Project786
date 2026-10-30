import 'package:flutter/material.dart';

import 'package:subscription_saas_flutter/app/theme/app_radii.dart';

import 'package:subscription_saas_flutter/core/widgets/glass_card.dart';

/// Structured content card — a thin adapter over GlassCard so callers of the
/// redesign batch keep their API (`padding`, `borderColor`, `borderWidth`)
/// while surface colour, border and ink treatment stay governed by the
/// palette-aware core (AppColors), never hardcoded hex values.
class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.color,
    this.borderColor,
    this.borderWidth = 1,
    this.borderRadius = AppRadii.rLg,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Color? borderColor;
  final double borderWidth;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: padding,
      margin: margin,
      color: color,
      border: borderColor == null
          ? null
          : Border.all(color: borderColor!, width: borderWidth),
      borderRadius: borderRadius,
      child: child,
    );
  }
}
