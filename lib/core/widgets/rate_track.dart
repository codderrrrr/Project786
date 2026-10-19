import 'package:flutter/material.dart';

import 'package:subscription_saas_flutter/app/theme/app_colors.dart';
import 'package:subscription_saas_flutter/app/theme/app_motion.dart';
import 'package:subscription_saas_flutter/app/theme/app_radii.dart';
import 'package:subscription_saas_flutter/app/theme/app_type.dart';

/// A rate, stated as a real fraction instead of a decorative progress bar.
///
/// This is the widget to reach for when the number actually means something in
/// this product: how many subscriptions are live, how much of a balance is
/// collected, how close a book is to full. The track is a thin rule with the
/// fraction printed on it, so the metric is legible at a glance and the control
/// does not pretend to be something it is not.
class RateTrack extends StatelessWidget {
  const RateTrack({
    super.key,
    required this.active,
    required this.total,
    this.label,
    this.detail,
    this.tone,
  });

  final int active;
  final int total;
  final String? label;
  final String? detail;
  final Color? tone;

  double get fraction {
    if (total <= 0) return 0;
    return active.clamp(0, total) / total;
  }

  @override
  Widget build(BuildContext context) {
    final reduced = AppMotion.reduced(context);
    final toneColor = tone ?? AppColors.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            // The percentage lives on the track itself — printing it twice
            // makes the metric look like two different numbers.
            Text(label!, style: AppType.caption),
            const SizedBox(height: 8),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (detail != null) ...[
                      Text(detail!, style: AppType.body),
                      const SizedBox(height: 10),
                    ],
                    _Track(
                      fraction: fraction,
                      tone: toneColor,
                      reduced: reduced,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 96),
                child: Semantics(
                  label:
                      '$active of $total active · ${(fraction * 100).toStringAsFixed(0)} percent',
                  excludeSemantics: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$active',
                        style: AppType.moneyHero.copyWith(
                          fontSize: 26,
                          color: toneColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'of $total',
                        style: AppType.overline.copyWith(letterSpacing: 0.2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (detail == null && label == null) ...[
            const SizedBox(height: 8),
            Text('$active of $total active', style: AppType.caption),
          ],
        ],
      ),
    );
  }
}

class _Track extends StatelessWidget {
  const _Track({
    required this.fraction,
    required this.tone,
    required this.reduced,
  });

  final double fraction;
  final Color tone;
  final bool reduced;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          '${(fraction * 100).toStringAsFixed(0)} percent active on a scale of zero to one hundred',
      child: Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: AppRadii.rXs,
          border: Border.all(color: AppColors.outlineSoft, width: 1),
        ),
        // The fill bar's width must come from the *bounded* track width: a
        // `Positioned(left: 0)` without `right` hands its child unbounded
        // constraints, and `width: double.infinity` then crashes layout.
        child: LayoutBuilder(
          builder: (context, constraints) {
            final fillWidth = (constraints.maxWidth * fraction).clamp(
              0.0,
              constraints.maxWidth,
            );
            return Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: AnimatedContainer(
                    duration: reduced
                        ? Duration.zero
                        : const Duration(milliseconds: 360),
                    curve: Curves.easeOutCubic,
                    height: 4,
                    decoration: BoxDecoration(
                      color: tone.withValues(alpha: 0.55),
                      borderRadius: AppRadii.rXs,
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  bottom: 0,
                  child: AnimatedContainer(
                    duration: reduced
                        ? Duration.zero
                        : const Duration(milliseconds: 360),
                    curve: Curves.easeOutCubic,
                    width: fillWidth,
                    height: 4,
                    decoration: BoxDecoration(
                      color: tone,
                      borderRadius: AppRadii.rXs,
                    ),
                  ),
                ),
                // The fraction never disappears inside the bar: it stays on the
                // surface so the metric is readable without decoding colour.
                Align(
                  alignment: Alignment.center,
                  child: FractionallySizedBox(
                    alignment: Alignment.centerRight,
                    widthFactor: 0.96,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Text(
                        '${(fraction * 100).toStringAsFixed(0)}%',
                        style: AppType.overline.copyWith(
                          color: tone,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
