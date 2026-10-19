import 'package:flutter/material.dart';

import 'package:subscription_saas_flutter/app/theme/app_colors.dart';
import 'package:subscription_saas_flutter/app/theme/app_motion.dart';
import 'package:subscription_saas_flutter/app/theme/app_radii.dart';

/// Shimmer block. Loading placeholders preserve layout so the screen does not
/// jump when data arrives, and they are announced once as a single status.
class Shimmer extends StatefulWidget {
  const Shimmer({
    super.key,
    this.width,
    this.height = 16,
    this.radius = AppRadii.rSm,
  });

  final double? width;
  final double height;
  final BorderRadius radius;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 1300),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (AppMotion.reduced(context)) {
      // Stop the ticker as well as the paint: a repeating controller keeps
      // requesting frames on a device that asked for no motion.
      if (_c.isAnimating) _c.stop();
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: widget.radius,
        ),
      );
    }
    if (!_c.isAnimating) _c.repeat();
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = _c.value;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.radius,
            gradient: LinearGradient(
              begin: Alignment(-1 - 2 + 4 * t, 0),
              end: Alignment(1 - 2 + 4 * t, 0),
              colors: [
                AppColors.surfaceAlt,
                AppColors.surfaceHigh,
                AppColors.surfaceAlt,
              ],
              stops: const [0.25, 0.5, 0.75],
            ),
          ),
        );
      },
    );
  }
}

class ListSkeleton extends StatelessWidget {
  const ListSkeleton({super.key, this.rows = 5, this.height = 84});

  final int rows;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading content',
      liveRegion: true,
      child: Column(
        children: List.generate(
          rows,
          (i) => Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Container(
              // minHeight, not a fixed height: the placeholder must never clip
              // or overflow if a caller passes a short row height.
              constraints: BoxConstraints(minHeight: height),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadii.rLg,
                border: Border.all(color: AppColors.outlineSoft),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Shimmer(width: 140, height: 14),
                  SizedBox(height: 10),
                  Shimmer(width: 220, height: 12),
                  SizedBox(height: 8),
                  Shimmer(width: 90, height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class StatSkeleton extends StatelessWidget {
  const StatSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading summary',
      liveRegion: true,
      child: Row(
        children: List.generate(
          2,
          (i) => Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: i == 0 ? 0 : 6, right: i == 0 ? 6 : 0),
              child: Container(
                height: 118,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadii.rLg,
                  border: Border.all(color: AppColors.outlineSoft),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Shimmer(width: 60, height: 12),
                    SizedBox(height: 14),
                    Shimmer(width: 100, height: 26),
                    SizedBox(height: 10),
                    Shimmer(width: 72, height: 12),
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
