import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:subscription_saas_flutter/app/theme/app_motion.dart';

/// Tactile press feedback (scale + haptic) with correct button semantics so
/// screen readers announce and activate the control.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.semanticLabel,
    this.semanticHint,
    this.excludeChildSemantics = false,
    this.pressedScale = 0.97,
    this.haptic = true,
    this.behavior = HitTestBehavior.opaque,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String? semanticLabel;
  final String? semanticHint;
  final bool excludeChildSemantics;
  final double pressedScale;
  final bool haptic;
  final HitTestBehavior behavior;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  bool get _enabled => widget.onTap != null || widget.onLongPress != null;

  @override
  Widget build(BuildContext context) {
    final content = AnimatedScale(
      scale: _down && _enabled ? widget.pressedScale : 1.0,
      duration: AppMotion.scale(context, AppMotion.fast),
      curve: AppMotion.emphasized,
      child: widget.child,
    );

    // By default the tap action comes from the GestureDetector below, which
    // merges into this node. Setting `onTap` here *and* having the gesture
    // detector's own config would make both explicit and split them into two
    // nodes — an unlabeled child that fails the labelled-tap-target guideline.
    // When child semantics are excluded the gesture detector's config is
    // dropped, so this node must carry the action itself.
    return Semantics(
      button: widget.onTap != null,
      enabled: _enabled,
      label: widget.semanticLabel,
      hint: widget.semanticHint,
      excludeSemantics: widget.excludeChildSemantics,
      onTap: widget.excludeChildSemantics ? widget.onTap : null,
      child: GestureDetector(
        behavior: widget.behavior,
        onTapDown: _enabled ? (_) => setState(() => _down = true) : null,
        onTapCancel: _enabled ? () => setState(() => _down = false) : null,
        onTapUp: _enabled ? (_) => setState(() => _down = false) : null,
        onTap: widget.onTap == null
            ? null
            : () {
                if (widget.haptic) HapticFeedback.selectionClick();
                widget.onTap!();
              },
        onLongPress: widget.onLongPress == null
            ? null
            : () {
                if (widget.haptic) HapticFeedback.mediumImpact();
                widget.onLongPress!();
              },
        child: content,
      ),
    );
  }
}
