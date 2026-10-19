import 'package:flutter/material.dart';

/// Right-hand cluster of a list row (amount, status chip, small action).
///
/// Why this exists: on a narrow phone an unbounded trailing widget competes
/// with the flexible middle column, and the middle column loses — the name
/// gets squeezed to a few pixels and the row overflows off-screen. Capping the
/// cluster keeps the *identity* of the row (who/what) readable and guarantees
/// the layout can never overflow horizontally.
///
/// Use [FitWidth] around a single-line value inside the cluster so a long
/// amount is scaled down to the cap instead of being clipped or ellipsised —
/// a truncated money value is worse than a slightly smaller one.
class TrailingCluster extends StatelessWidget {
  const TrailingCluster({
    super.key,
    required this.child,
    this.maxWidth = 132,
  });

  final Widget child;

  /// Hard width cap in logical pixels. Keep this well under half the row so
  /// the flexible middle still gets a readable share.
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    );
  }
}

/// Scales a single-line child down until it fits the width it is given.
///
/// The child must be inside a width-bounded parent (e.g. [TrailingCluster]);
/// with unbounded width it renders at its natural size.
class FitWidth extends StatelessWidget {
  const FitWidth({
    super.key,
    required this.child,
    this.alignment = Alignment.centerRight,
  });

  final Widget child;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: alignment,
      child: child,
    );
  }
}
