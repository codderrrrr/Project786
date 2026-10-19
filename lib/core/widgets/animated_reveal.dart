import 'package:flutter/material.dart';

import 'package:subscription_saas_flutter/app/theme/app_motion.dart';

/// Staggered entrance for list items and cards. Honours reduced-motion by
/// rendering the final state immediately.
///
/// One-off entrance animations only. After the first reveal the widget stays
/// out of the per-frame rebuild path, so long lists stay at 60 fps on
/// Mid/High tier devices and degrade gracefully on low-end ones.
class AnimatedReveal extends StatefulWidget {
  const AnimatedReveal({
    super.key,
    required this.child,
    this.index = 0,
    this.offset = const Offset(0, 0.06),
    this.duration = AppMotion.slow,
  });

  final Widget child;
  final int index;
  final Offset offset;
  final Duration duration;

  @override
  State<AnimatedReveal> createState() => _AnimatedRevealState();
}

class _AnimatedRevealState extends State<AnimatedReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  late final Animation<double> _fade = CurvedAnimation(
    parent: _c,
    curve: AppMotion.emphasized,
  );

  late final Animation<Offset> _slide = Tween<Offset>(
    begin: widget.offset,
    end: Offset.zero,
  ).animate(_fade);

  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reading MediaQuery is only legal from didChangeDependencies onwards, so
    // the entrance animation is kicked off here rather than in initState.
    if (_started) return;
    _started = true;

    if (AppMotion.reduced(context)) {
      _c.value = 1;
      return;
    }
    final delay = AppMotion.stagger(context, widget.index);
    if (delay == Duration.zero) {
      _c.value = 1;
      return;
    }
    Future.delayed(delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.child;
    if (AppMotion.reduced(context)) {
      return RepaintBoundary(child: child);
    }
    return RepaintBoundary(
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(position: _slide, child: child),
      ),
    );
  }
}
