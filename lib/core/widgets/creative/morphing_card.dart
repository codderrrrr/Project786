import 'package:flutter/material.dart';

import 'package:subscription_saas_flutter/app/theme/app_colors.dart';
import 'package:subscription_saas_flutter/app/theme/app_motion.dart';
import 'package:subscription_saas_flutter/app/theme/app_radii.dart';

import '../pressable.dart';

/// Clean, morphing card with subtle elevation animation - less bloated than heavy glows.
class MorphingCard extends StatefulWidget {
  const MorphingCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.borderRadius = AppRadii.rMd,
    this.elevation = 1.0,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final BorderRadius borderRadius;
  final double elevation;

  @override
  State<MorphingCard> createState() => _MorphingCardState();
}

class _MorphingCardState extends State<MorphingCard> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RepaintBoundary(
      child: Pressable(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppMotion.fast,
          curve: AppMotion.emphasized,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: isDark ? AppColors.surface : Colors.white,
            borderRadius: widget.borderRadius,
            border: Border.all(color: AppColors.outlineSoft),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withValues(alpha: widget.elevation * 0.08),
                blurRadius: widget.elevation * 4,
                offset: Offset(0, widget.elevation * 1.5),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
