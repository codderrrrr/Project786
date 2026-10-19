import 'package:flutter/material.dart';

import 'package:subscription_saas_flutter/app/theme/app_type.dart';
import 'package:subscription_saas_flutter/features/dashboard/presentation/hide_amounts_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Animated counter for stat values. Respects hide amounts provider.
class AnimatedStat extends ConsumerStatefulWidget {
  const AnimatedStat({
    super.key,
    required this.value,
    this.duration = const Duration(milliseconds: 800),
    this.style,
    this.isAmount = true,
  });

  final double value;
  final Duration duration;
  final TextStyle? style;
  final bool isAmount;

  @override
  ConsumerState<AnimatedStat> createState() => _AnimatedStatState();
}

class _AnimatedStatState extends ConsumerState<AnimatedStat>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(begin: 0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedStat oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = Tween<double>(begin: _animation.value, end: widget.value)
          .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hidden = widget.isAmount ? ref.watch(hideAmountsProvider) : false;
    if (hidden) {
      return Text('••••', style: widget.style ?? AppType.moneyLarge);
    }
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final display = _animation.value;
        return RepaintBoundary(
          child: Text(
            display >= 1000000
                ? '${(display / 1000000).toStringAsFixed(1)}M'
                : display >= 1000
                    ? '${(display / 1000).toStringAsFixed(1)}K'
                    : display.toStringAsFixed(display >= 100 ? 0 : 2),
            style: widget.style ?? AppType.moneyLarge,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }
}
