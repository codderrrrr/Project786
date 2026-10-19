import 'package:flutter/material.dart';

import 'package:subscription_saas_flutter/app/theme/app_colors.dart';
import 'package:subscription_saas_flutter/app/theme/app_radii.dart';

import '../pressable.dart';

/// Minimal, clean card - reduces visual bloat.
class MinimalCard extends StatelessWidget {
  const MinimalCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.borderRadius = AppRadii.rMd,
    this.showBorder = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final BorderRadius borderRadius;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RepaintBoundary(
      child: Pressable(
        onTap: onTap,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: isDark ? AppColors.surface : Colors.white,
            borderRadius: borderRadius,
            border: showBorder ? Border.all(color: AppColors.outlineSoft) : null,
          ),
          child: child,
        ),
      ),
    );
  }
}
