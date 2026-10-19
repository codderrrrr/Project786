import 'package:flutter/material.dart';

import 'package:subscription_saas_flutter/app/theme/app_colors.dart';
import 'package:subscription_saas_flutter/app/theme/app_radii.dart';
import 'package:subscription_saas_flutter/app/theme/app_type.dart';

/// Clean badge for counts and indicators.
class Badge extends StatelessWidget {
  const Badge({
    super.key,
    required this.count,
    this.color = AppColors.primary,
    this.size = 16,
  });

  final int count;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color,
          borderRadius: AppRadii.rPill,
        ),
        child: Text(
          count > 99 ? '99+' : count.toString(),
          style: AppType.overline.copyWith(
            color: AppColors.onAccent,
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}
