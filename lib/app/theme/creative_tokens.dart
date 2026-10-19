import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Creative design tokens for a cohesive artistic design system.
/// Focuses on subtle aurora/mesh gradients with performance in mind.
class CreativeTokens {
  CreativeTokens._();

  // Aurora gradients - subtle, low opacity blooms
  static const LinearGradient auroraPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF3B82F6), // blue-500
      Color(0xFF2563EB), // blue-600
    ],
  );

  static LinearGradient auroraSubtle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [
              const Color(0xFF60A5FA).withValues(alpha: 0.8),
              const Color(0xFF3B82F6).withValues(alpha: 0.6),
            ]
          : [
              const Color(0xFF3B82F6).withValues(alpha: 0.9),
              const Color(0xFF2563EB).withValues(alpha: 0.7),
            ],
      stops: const [0.0, 1.0],
    );
  }

  // Mesh gradient backgrounds - very subtle
  static LinearGradient meshBackgroundLight = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF8FAFC),
      Color(0xFFF1F5F9),
    ],
  );

  static LinearGradient meshBackgroundDark = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0F172A),
      Color(0xFF1E293B),
    ],
  );

  // Glow effects - low opacity for performance
  static List<BoxShadow> glowPrimary(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: AppColors.primary.withValues(alpha: isDark ? 0.25 : 0.18),
        blurRadius: 12,
        offset: const Offset(0, 6),
      ),
      BoxShadow(
        color: AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.12),
        blurRadius: 24,
        offset: const Offset(0, 12),
      ),
    ];
  }

  static List<BoxShadow> glowSubtle = [
    BoxShadow(
      color: AppColors.shadow.withValues(alpha: 0.08),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: AppColors.shadow.withValues(alpha: 0.04),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  // Card surface gradients
  static LinearGradient cardSurface(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
}
