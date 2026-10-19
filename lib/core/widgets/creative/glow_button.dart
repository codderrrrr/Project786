import 'package:flutter/material.dart';

import 'package:subscription_saas_flutter/app/theme/app_colors.dart';
import 'package:subscription_saas_flutter/app/theme/app_motion.dart';
import 'package:subscription_saas_flutter/app/theme/app_radii.dart';
import 'package:subscription_saas_flutter/app/theme/creative_tokens.dart';

/// Artistic button with subtle glow effect.
class GlowButton extends StatelessWidget {
  const GlowButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.variant = GlowButtonVariant.primary,
    this.semanticLabel,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final GlowButtonVariant variant;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Semantics(
        button: true,
        label: semanticLabel,
        enabled: onPressed != null,
        child: AnimatedContainer(
          duration: AppMotion.fast,
          curve: AppMotion.emphasized,
          decoration: BoxDecoration(
            gradient: _gradient(context),
            borderRadius: AppRadii.rMd,
            boxShadow: onPressed != null ? CreativeTokens.glowPrimary(context) : null,
            border: Border.all(
              color: variant == GlowButtonVariant.primary
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : AppColors.outlineSoft,
            ),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onPressed,
              borderRadius: AppRadii.rMd,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: DefaultTextStyle(
                  style: TextStyle(
                    color: _textColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                  child: Center(child: child),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Gradient _gradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (variant == GlowButtonVariant.primary) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? [
                const Color(0xFF60A5FA),
                const Color(0xFF3B82F6),
              ]
            : [
                const Color(0xFF3B82F6),
                const Color(0xFF2563EB),
              ],
      );
    }
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [
              const Color(0xFF1E293B),
              const Color(0xFF0F172A),
            ]
          : [
              Colors.white,
              const Color(0xFFFAFAFA),
            ],
    );
  }

  Color _textColor(BuildContext context) {
    if (variant == GlowButtonVariant.primary) {
      return AppColors.onAccent;
    }
    return AppColors.textPrimary;
  }
}

enum GlowButtonVariant { primary, secondary }
