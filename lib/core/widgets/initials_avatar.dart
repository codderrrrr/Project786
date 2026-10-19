import 'package:flutter/material.dart';

import 'package:subscription_saas_flutter/app/theme/app_colors.dart';
import 'package:subscription_saas_flutter/app/theme/app_type.dart';

/// Initials avatar with a deterministic accent derived from the name, so the
/// same person always gets the same colour.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({
    super.key,
    required this.name,
    this.size = 46,
    this.dimmed = false,
  });

  final String name;
  final double size;
  final bool dimmed;

  /// Resolved per build so the avatar follows the active theme.
  static List<Color> get _palette => [
    AppColors.primary,
    AppColors.accent,
    AppColors.success,
    AppColors.warning,
    AppColors.highlight,
    AppColors.info,
  ];

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first).toUpperCase();
  }

  Color get _accent {
    if (name.isEmpty) return AppColors.primary;
    final hash = name.codeUnits.fold<int>(0, (a, b) => (a * 31 + b) & 0x7fffffff);
    return _palette[hash % _palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final accent = dimmed ? AppColors.textTertiary : _accent;
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(size * 0.32),
          border: Border.all(color: accent.withValues(alpha: 0.36)),
        ),
        child: Center(
          child: Text(
            _initials,
            style: AppType.label.copyWith(
              color: accent,
              fontSize: size * 0.36,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
