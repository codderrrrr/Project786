import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:subscription_saas_flutter/app/theme/app_colors.dart';
import 'package:subscription_saas_flutter/app/theme/app_motion.dart';
import 'package:subscription_saas_flutter/app/theme/app_radii.dart';
import 'package:subscription_saas_flutter/app/theme/app_type.dart';

class BarDatum {
  BarDatum(this.label, this.value);
  final String label;
  final double value;
}

/// Labelled bar chart. Bars are a single accent colour; every bar carries its
/// value in the semantics tree and as a visible label, so the chart is
/// readable without relying on colour.
class MiniBarChart extends StatelessWidget {
  const MiniBarChart({
    super.key,
    required this.data,
    this.height = 120,
    this.gradient,
    this.valueFormatter,
  });

  final List<BarDatum> data;
  final double height;

  /// Retained for call sites that want a custom fill; defaults to the accent.
  final Gradient? gradient;
  final String Function(double value)? valueFormatter;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();
    final maxV = data.map((d) => d.value).reduce(math.max);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: data.map((d) {
              final factor = maxV == 0 ? 0.0 : d.value / maxV;
              return Expanded(
                child: Semantics(
                  label: '${d.label}: ${valueFormatter?.call(d.value) ?? d.value.toStringAsFixed(0)}',
                  excludeSemantics: true,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          valueFormatter?.call(d.value) ?? d.value.toStringAsFixed(0),
                          style: AppType.overline.copyWith(fontSize: 9.5, letterSpacing: 0),
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                        ),
                        const SizedBox(height: 4),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: factor == 0 ? 0.02 : factor),
                          duration: AppMotion.scale(context, const Duration(milliseconds: 650)),
                          curve: Curves.easeOutCubic,
                          builder: (context, v, _) => Container(
                            height: (height - 30) * v,
                            decoration: BoxDecoration(
                              gradient: gradient,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(AppRadii.xs),
                              ),
                              border: Border.all(
                                color: AppColors.outlineSoft,
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: data
              .map((d) => Expanded(
                    child: Text(
                      d.label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppType.overline.copyWith(letterSpacing: 0.2),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class LegendDot extends StatelessWidget {
  const LegendDot({super.key, required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppType.overline.copyWith(letterSpacing: 0.2)),
      ],
    );
  }
}
