import 'package:flutter/material.dart';

import 'package:subscription_saas_flutter/app/theme/app_colors.dart';
import 'package:subscription_saas_flutter/app/theme/app_motion.dart';
import 'package:subscription_saas_flutter/app/theme/app_radii.dart';
import 'package:subscription_saas_flutter/app/theme/app_type.dart';

/// Artistic chip with gradient accent when selected.
class GradientChip extends StatelessWidget {
  const GradientChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RepaintBoundary(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: AnimatedContainer(
          duration: AppMotion.fast,
          curve: AppMotion.emphasized,
          decoration: BoxDecoration(
            gradient: selected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            const Color(0xFF60A5FA).withValues(alpha: 0.3),
                            const Color(0xFF3B82F6).withValues(alpha: 0.2),
                          ]
                        : [
                            const Color(0xFF3B82F6).withValues(alpha: 0.12),
                            const Color(0xFF2563EB).withValues(alpha: 0.08),
                          ],
                  )
                : null,
            color: selected ? null : (isDark ? AppColors.surface : Colors.white),
            borderRadius: AppRadii.rPill,
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.outlineSoft,
            ),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onTap,
              borderRadius: AppRadii.rPill,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(
                        icon,
                        size: 16,
                        color: selected ? AppColors.primary : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      label,
                      style: AppType.label.copyWith(
                        color: selected ? AppColors.primary : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
